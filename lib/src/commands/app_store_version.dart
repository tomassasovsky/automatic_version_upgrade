import 'package:app_store_connect_api/app_store_connect_api.dart';
import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:automatic_version_upgrader/automatic_version_upgrader.dart';
import 'package:http/http.dart' as http;
import 'package:mason_logger/mason_logger.dart';
import 'package:meta/meta.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:pubspec/pubspec.dart';
import 'package:universal_io/io.dart';

final _privateKeyRegExp = RegExp(r'-{3,}\n([\s\S]*?)\n-{3,}');

/// {@template app_store_version_command}
/// `automatic_version_upgrader app-store-version` command which gets the
/// current version of the app from App Store Connect.
/// {@endtemplate}
class AppStoreVersionCommand extends Command<int> {
  /// {@macro app_store_version_command}
  AppStoreVersionCommand({
    Logger? logger,
  }) : _logger = logger ?? Logger() {
    argParser
      ..addOption(
        'app-id',
        help: 'The identifier of the app.',
        mandatory: true,
      )
      ..addOption(
        'private-key',
        defaultsTo: Platform.environment['APP_STORE_CONNECT_PRIVATE_KEY'],
        help: 'The private key from the App Store Connect account.',
      )
      ..addOption(
        'key-id',
        defaultsTo: Platform.environment['APP_STORE_CONNECT_KEY_IDENTIFIER'],
        help: 'The key id from the App Store Connect account.',
      )
      ..addOption(
        'issuer-id',
        defaultsTo: Platform.environment['APP_STORE_CONNECT_ISSUER_ID'],
        help: "The private key's issuer id from the App Store Connect account.",
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
      'Gets the latest version of the app from the App Store.';

  @override
  String get name => 'app-store-version';

  /// [ArgResults] which can be overridden for testing.
  @visibleForTesting
  ArgResults? argResultOverrides;

  ArgResults get _argResults => argResultOverrides ?? argResults!;

  static const _invalidCredentialsError = 'The account credentials are '
      'required. You can set the environment variables as '
      'APP_STORE_CONNECT_PRIVATE_KEY, APP_STORE_CONNECT_KEY_IDENTIFIER, '
      'APP_STORE_CONNECT_ISSUER_ID, or pass it with their respective '
      'parameters. Use the command --help for more information.\n';

  @override
  Future<int> run() async {
    final privateKey = _privateKey;
    final keyId = _keyId;
    final issuer = _issuerId;
    final appId = _appId;
    final upgradeMode = _upgradeMode;
    final next = _next;

    late AppStoreCredentials credentials;

    _logger.write('\n');

    try {
      credentials = AppStoreCredentials(
        privateKey: privateKey,
        keyId: keyId,
        issuerId: issuer,
      );
    } catch (e) {
      _logger.err('Error signing credentials: $e');
      usageException(_invalidCredentialsError);
    }

    final client = AppStoreConnectApi(
      client: http.Client(),
      credentials: credentials,
    );

    late final AppStoreGenericResponse<AppStoreVersion, AppStoreBuild>
        appStoreVersionResponse;
    late final AppStoreGenericResponse<AppStorePreReleaseVersion, AppStoreBuild>
        appStorePreReleaseVersionResponse;

    final appStoreVersionChecking =
        _logger.progress('Getting the latest version from App Store Connect');

    try {
      appStoreVersionResponse = await client.appStoreVersions(appId);
      appStorePreReleaseVersionResponse =
          await client.preReleaseVersions(appId);
    } catch (e) {
      appStoreVersionChecking
          .fail('Error getting the latest version from App Store Connect: $e');
      _logger
          .err('Error getting the latest version from App Store Connect: $e');
      exit(1);
    }

    final latestAppStoreVersion =
        appStoreVersionResponse.latestVersion.attributes.version;

    final latestPreReleaseVersion =
        appStorePreReleaseVersionResponse.latestVersion.attributes.version;

    final latestIsPreRelease = latestPreReleaseVersion > latestAppStoreVersion;

    final latestVersion = Version.primary([
      latestAppStoreVersion,
      latestPreReleaseVersion,
    ]);

    appStoreVersionChecking.complete(
      'The latest version from App Store Connect is $latestVersion',
    );

    if (upgradeMode == UpgradeMode.never) {
      exit(ExitCode.success.code);
    }

    late final PubSpec pubspec;

    try {
      pubspec = await PubSpec.load(Directory.current);
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

    if (!shouldUpgrade) {
      _logger.success(
        'The app version is already higher than the one in the App Store.',
      );
      exit(ExitCode.success.code);
    }

    final versionUpgradingProgress =
        _logger.progress('Upgrading the app to the latest version...');

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
      await updatedPubspc.save(Directory.current);

      versionUpgradingProgress.complete();
      _logger.success('The app version has been upgraded to $nextVersion.');
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

  /// Gets the private key for App Store Connect.
  String get _privateKey {
    final key = _argResults['private-key'] as String?;
    _validatePrivateKey(key);
    return key!;
  }

  /// Gets the key id for App Store Connect.
  String get _keyId => _argResults['key-id'] as String? ?? '';

  /// Gets the issuer id for App Store Connect.
  String get _issuerId => _argResults['issuer-id'] as String? ?? '';

  /// Gets the app id for App Store Connect.
  String get _appId => _argResults['app-id'] as String? ?? '';

  /// Gets the upgrade mode for App Store Connect.
  UpgradeMode get _upgradeMode => UpgradeMode.values
      .byName(_argResults['upgrade-mode'] as String? ?? 'never');

  /// Gets the next version for App Store Connect.
  NextVersion get _next =>
      NextVersion.values.byName(_argResults['next'] as String? ?? 'never');

  void _validatePrivateKey(String? key) {
    _logger.detail('Validating private key; $key');
    final isValidPrivateKey = _isValidPrivateKey(key ?? '');
    if (!isValidPrivateKey) {
      usageException('The private key is invalid.');
    }
  }

  bool _isValidPrivateKey(String key) {
    return _privateKeyRegExp.hasMatch(key);
  }
}
