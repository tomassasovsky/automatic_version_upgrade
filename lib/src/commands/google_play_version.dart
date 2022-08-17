import 'dart:convert';
import 'dart:math';

import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:automatic_version_upgrader/automatic_version_upgrader.dart';
import 'package:googleapis/androidpublisher/v3.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:meta/meta.dart';
import 'package:universal_io/io.dart';

final RegExp _packageNameRegExp =
    RegExp(r'^([A-Za-z]{1}[A-Za-z\d_]*\.)+[A-Za-z][A-Za-z\d_]*$');

/// {@template update_command}
/// `automatic_version_upgrader google-play-version-code` command which gets the
/// current (latest) version code of the app from the Google Play Store.
/// {@endtemplate}
class GooglePlayVersionCommand extends Command<int> {
  /// {@macro update_command}
  GooglePlayVersionCommand({
    Logger? logger,
  }) : _logger = logger ?? Logger() {
    argParser
      ..addOption(
        'package-name',
        abbr: 'p',
        help: 'The package name of the app.',
        mandatory: true,
      )
      ..addOption(
        'credentials',
        defaultsTo: Platform.environment['GCLOUD_SERVICE_ACCOUNT_CREDENTIALS'],
        help: 'The credentials for the Google Cloud Service Account.',
      )
      ..addFlag(
        'upgrade',
        abbr: 'u',
        help: "Updates the Android app's version code to the oldest plus one.",
      );
  }

  final Logger _logger;

  @override
  String get description =>
      'Gets the latest version code of the app from the Google Play Console.';

  @override
  String get summary => '$invocation\n$description';

  @override
  String get name => 'google-play-version-code';

  @override
  String get invocation =>
      'automatic_version_upgrader google-play-version-code';

  /// [ArgResults] which can be overridden for testing.
  @visibleForTesting
  ArgResults? argResultOverrides;

  ArgResults get _argResults => argResultOverrides ?? argResults!;

  static const _invalidCredentialsError =
      'The account credentials are required. '
      'You can set the environment variable as '
      'GCLOUD_SERVICE_ACCOUNT_CREDENTIALS or '
      'pass it with the option --credentials.\n';

  @override
  Future<int> run() async {
    final accountCredentialsArg = _credentials;
    final packageName = _packageName;
    final upgrade = _upgrade;
    final outputDir = _outputDirectory;

    _logger.write('\n');

    late AutoRefreshingAuthClient baseClient;

    try {
      baseClient = await clientViaServiceAccount(
        ServiceAccountCredentials.fromJson(
          (json.decode(accountCredentialsArg) as Map).cast<String, dynamic>(),
        ),
        [AndroidPublisherApi.androidpublisherScope],
      );
    } catch (e) {
      _logger.err('Error getting client: $e');
      usageException(_invalidCredentialsError);
    }

    // Get the latest version code from the Google Play Console.
    final appLatestVersionProgress =
        _logger.progress('Getting latest version...');

    final publisherApi = AndroidPublisherApi(baseClient);
    final edit = await _createAppEdit(publisherApi, packageName);

    final bundles = await publisherApi.edits.bundles.list(
      packageName,
      edit.id!,
    );

    final defaultBundleList = <Bundle>[Bundle(versionCode: 1)];

    final versionCodes =
        (bundles.bundles ?? defaultBundleList).map((e) => e.versionCode ?? 1);

    final latestVersionCode = versionCodes.reduce(max);

    appLatestVersionProgress.update('Cleaning up');
    await _deleteAppEdit(publisherApi, packageName, edit);

    appLatestVersionProgress.complete(
      'The latest version in Google Play Console is ${green.wrap(
        latestVersionCode.toString(),
      )}',
    );

    if (!upgrade) {
      exit(ExitCode.success.code);
    }

    final versionUpgradingProgress =
        _logger.progress('Upgrading the app to the latest version...');

    try {
      final pubspecVersionChanger = PubspecVersionChanger(logger: _logger);
      final currentVersion = pubspecVersionChanger.currentVersion(outputDir);
      final currentVersionCode = int.tryParse(currentVersion.build.join()) ?? 1;

      final newVersionCode = latestVersionCode + 1;

      if (currentVersionCode >= newVersionCode) {
        versionUpgradingProgress.complete(
          'The app version is already at the latest version. '
          'No need to upgrade.',
        );
        exit(ExitCode.success.code);
      }

      final newVersion = currentVersion.copy(build: newVersionCode.toString());

      pubspecVersionChanger.updateVersionCode(
        outputDir,
        newVersion.toString(),
      );

      versionUpgradingProgress.complete();
      _logger.success('The app version has been upgraded to $newVersion.');
    } catch (e) {
      versionUpgradingProgress.fail(
        'An error occured updating the pubspec.yaml file. '
        'Check that you are in the root of the project and '
        'that the file is properly formatted.',
      );

      exit(ExitCode.ioError.code);
    }

    exit(ExitCode.success.code);
  }

  /// Gets the credentials for the Google Play Console Service Account.
  String get _credentials {
    final cred = _argResults['credentials'] as String?;
    _validateCredentials(cred);
    return cred!;
  }

  /// Whether or not the app version code should be upgraded.
  bool get _upgrade {
    return _argResults['upgrade'] as bool? ?? false;
  }

  /// Gets the package name for the app.
  String get _packageName {
    final packageName = _argResults['package-name'] as String? ?? '';
    _validatepackageName(packageName);
    return packageName;
  }

  Directory get _outputDirectory {
    final rest = List<String>.from(_argResults.rest);
    _validateOutputDirectoryArg(rest);
    return Directory(rest.first);
  }

  void _validateOutputDirectoryArg(List<String> args) {
    _logger.detail('Validating output directory args: $args');

    if (args.isEmpty) {
      args.add(Directory.current.path);
    }

    if (args.length > 1) {
      usageException('Multiple output directories specified.');
    }
  }

  void _validatepackageName(String name) {
    _logger.detail('Validating name; $name');
    final isValidpackageName = _isValidpackageName(name);
    if (!isValidpackageName) {
      usageException(
        '"$name" is not a valid package name.\n\n'
        'A valid package name has 3 parts separated by "."\n'
        'Each part must start with a letter and only include '
        'alphanumeric characters (A-Z, a-z, 0-9), underscores (_), '
        'and hyphens (-)\n'
        '(ex. automatic.versioning.org)',
      );
    }
  }

  void _validateCredentials(String? credentials) {
    /// make sure the credentials are present
    if (credentials == null || !_isValidJson(credentials)) {
      usageException(_invalidCredentialsError);
    }
  }

  bool _isValidpackageName(String name) {
    return _packageNameRegExp.hasMatch(name);
  }

  Future<AppEdit> _createAppEdit(
    AndroidPublisherApi client,
    String packageName,
  ) async {
    final edits = client.edits;
    return edits.insert(AppEdit(), packageName);
  }

  Future<void> _deleteAppEdit(
    AndroidPublisherApi client,
    String packageName,
    AppEdit appEdit,
  ) async {
    final edits = client.edits;
    await edits.delete(packageName, appEdit.id!);
  }

  /// Checks whether the JSON is valid.
  bool _isValidJson(String input) {
    try {
      final parsed = json.decode(input);
      return parsed is Map;
    } catch (e) {
      return false;
    }
  }
}
