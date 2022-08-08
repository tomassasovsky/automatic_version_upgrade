import 'dart:convert';

import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:automatic_version_upgrader/automatic_version_upgrader.dart';
import 'package:googleapis/androidpublisher/v3.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:meta/meta.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:pubspec/pubspec.dart';
import 'package:universal_io/io.dart';

final RegExp _packageNameRegExp =
    RegExp(r'^([A-Za-z]{1}[A-Za-z\d_]*\.)+[A-Za-z][A-Za-z\d_]*$');

/// {@template update_command}
/// `automatic_version_upgrader google-play-version` command which gets the
/// current version of the app from the Google Play Store.
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
      ..addOption(
        'next',
        allowed: ['major', 'minor', 'patch', 'breaking', 'build'],
        allowedHelp: {
          'major': 'Gets the next major version number that follows this one. '
              'If this version is a pre-release of a major version '
              'release (i.e. the minor and patch versions are zero), then it '
              'just strips the pre-release suffix. Otherwise, it increments '
              'the major version and resets the minor and patch.',
          'minor': 'Gets the next minor version number that follows this one. '
              'If this version is a pre-release of a minor version '
              'release (i.e. the patch version is zero), then it just strips '
              'the pre-release suffix. Otherwise, it increments the minor '
              'version and resets the patch. ',
          'patch': 'Gets the next patch version number that follows this one. '
              'If this version is a pre-release, then it just strips the '
              'pre-release suffix. Otherwise, it increments the patch version.',
          'breaking': 'Gets the next breaking version number that follows '
              "this one. Increments [major] if it's greater than zero, "
              'otherwise [minor], resets subsequent digits to zero, '
              'and strips any [preRelease] or [build] suffix.',
          'build': 'Gets the next build number that follows this one. '
              'If this version is a pre-release, then it just strips the '
              'pre-release suffix. Otherwise, it increments the build. '
              'Note: If the latest version is actually bigger than the latest '
              'build, then the build number is reset to zero and the version '
              'grabbed will be the next patch to the latest version.',
        },
        help: 'Updates the version number.',
        defaultsTo: 'build',
        valueHelp: 'major|minor|patch|breaking|build',
      )
      ..addOption(
        'upgrade-mode',
        abbr: 'u',
        valueHelp: 'always|never|outdated',
        defaultsTo: 'never',
        help: "Updates the version in your app's pubspec.yaml file.",
        allowedHelp: {
          'always': "Updates the app's version to the oldest plus a patch.",
          'never': "Doesn't update the version.",
          'outdated': "Updates the app's version if there's a "
              'newer one available. Otherwise, does nothing. ',
        },
      );
  }

  final Logger _logger;

  @override
  String get description =>
      'Gets the latest version of the app from the Google Play Store.';

  @override
  String get summary => '$invocation\n$description';

  @override
  String get name => 'google-play-version';

  @override
  String get invocation => 'automatic_version_upgrader google-play-version';

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
    final upgradeMode = _upgradeMode;
    final next = _next;
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

    final appLatestVersionProgress =
        _logger.progress('Getting latest version...');

    final publisherApi = AndroidPublisherApi(baseClient);
    final edit = await _createAppEdit(publisherApi, packageName);

    final list = await publisherApi.edits.tracks.list(
      packageName,
      edit.id!,
    );

    final latestVersion = list.latestVersion;

    appLatestVersionProgress.update('Cleaning up');
    await _deleteAppEdit(publisherApi, packageName, edit);

    appLatestVersionProgress.complete(
      'The latest version in Google Play Console is ${green.wrap(
        list.latestVersion.toString(),
      )}',
    );

    if (upgradeMode == UpgradeMode.never) {
      exit(ExitCode.success.code);
    }

    late final PubSpec pubspec;

    try {
      pubspec = await PubSpec.load(outputDir);
    } catch (e) {
      _logger.err(
        'An error occured loading the pubspec.yaml file. '
        'Check that you are in the root of the project and '
        'that the file is properly formatted.',
      );
      exit(ExitCode.ioError.code);
    }

    final currentVersion = pubspec.version ?? Version.none;
    final hasNewerVersion = currentVersion <= latestVersion;
    final shouldUpgrade = upgradeMode == UpgradeMode.always ||
        hasNewerVersion && upgradeMode == UpgradeMode.outdated;

    final latestIsPreRelease = latestVersion.isPreRelease;

    if (!shouldUpgrade) {
      _logger.success(
        'The app version is already higher than the one '
        'in Google Cloud Console.',
      );
      exit(ExitCode.success.code);
    }

    final versionUpgradingProgress =
        _logger.progress('Upgrading the app to the latest version');

    late final Version nextVersion;
    if (next == NextVersion.build) {
      if (latestIsPreRelease) {
        nextVersion = latestVersion.next(next);
      } else {
        nextVersion = latestVersion.next(NextVersion.patch).next(next);
      }
    } else {
      nextVersion = latestVersion.next(next).next(next);
    }

    try {
      final updatedPubspc = pubspec.copy(version: nextVersion);
      await updatedPubspc.save(outputDir);

      versionUpgradingProgress
          .complete(green.wrap('Version upgraded to $nextVersion'));
      // _logger.success('The app version has been upgraded to $nextVersion.');
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

  /// Gets the upgrade mode for App Store Connect.
  UpgradeMode get _upgradeMode {
    return UpgradeMode.values
        .byName(_argResults['upgrade-mode'] as String? ?? 'never');
  }

  /// Gets the package name for the app.
  String get _packageName {
    final packageName = _argResults['package-name'] as String? ?? '';
    _validatepackageName(packageName);
    return packageName;
  }

  /// Gets the next version for App Store Connect.
  NextVersion get _next =>
      NextVersion.values.byName(_argResults['next'] as String? ?? 'never');

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
