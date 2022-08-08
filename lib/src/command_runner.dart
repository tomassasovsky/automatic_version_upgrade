import 'dart:async';

import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:automatic_version_upgrader/automatic_version_upgrader.dart';
import 'package:automatic_version_upgrader/src/version.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:pub_updater/pub_updater.dart';
import 'package:usage/usage_io.dart';

// The Google Analytics tracking ID.
const _gaTrackingId = 'UA-236818148-1';

// The Google Analytics Application Name.
const _gaAppName = 'automatic-version-upgrader';

/// The package name.
const packageName = 'automatic_version_upgrader';

/// {@template automatic_version_upgrader_command_runner}
/// A [CommandRunner] for the Automatic Version Upgrader CLI.
/// {@endtemplate}
class AutomaticVersionUpgraderCommandRunner extends CommandRunner<int> {
  /// {@macro automatic_version_upgrader_command_runner}
  AutomaticVersionUpgraderCommandRunner({
    Analytics? analytics,
    Logger? logger,
    PubUpdater? pubUpdater,
  })  : _logger = logger ?? Logger(),
        _analytics =
            analytics ?? AnalyticsIO(_gaTrackingId, _gaAppName, packageVersion),
        _pubUpdater = pubUpdater ?? PubUpdater(),
        super(
          'automatic_version_upgrader',
          'A command line interface to upgrade your app version automatically in a CI/CD flow.',
        ) {
    argParser
      ..addFlag(
        'version',
        negatable: false,
        help: 'Print the current version.',
      )
      ..addOption(
        'analytics',
        help: 'Toggle anonymous usage statistics.',
        allowed: ['true', 'false'],
        allowedHelp: {
          'true': 'Enable anonymous usage statistics',
          'false': 'Disable anonymous usage statistics',
        },
      )
      ..addFlag(
        'verbose',
        help: 'Noisy logging, including all shell commands executed.',
      );
    addCommand(
      UpdateCommand(
        logger: _logger,
        pubUpdater: _pubUpdater,
        packageName: packageName,
      ),
    );
    addCommand(GooglePlayVersionCommand(logger: _logger));
    addCommand(AppStoreVersionCommand(logger: _logger));
  }

  final Logger _logger;
  final Analytics _analytics;
  final PubUpdater _pubUpdater;

  @override
  Future<int> run(Iterable<String> args) async {
    try {
      if (_analytics.firstRun) {
        final response = _logger.prompt(
          lightGray.wrap(
            '''
+---------------------------------------------------+
|    Welcome to the Automatic Version Upgrader!     |
+---------------------------------------------------+
| We would like to collect anonymous                |
| usage statistics in order to improve the tool.    |
| Would you like to opt-into help us improve? [y/n] |
+---------------------------------------------------+\n''',
          ),
        );
        final normalizedResponse = response.toLowerCase().trim();
        _analytics.enabled =
            normalizedResponse == 'y' || normalizedResponse == 'yes';
      }
      final _argResults = parse(args);
      if (_argResults['verbose'] == true) {
        _logger.level = Level.verbose;
      }
      return await runCommand(_argResults) ?? ExitCode.success.code;
    } on FormatException catch (e, stackTrace) {
      _logger
        ..err(e.message)
        ..err('$stackTrace')
        ..info('')
        ..info(usage);
      return ExitCode.usage.code;
    } on UsageException catch (e) {
      _logger
        ..err(e.message)
        ..info('')
        ..info(e.usage);
      return ExitCode.usage.code;
    }
  }

  @override
  Future<int?> runCommand(ArgResults topLevelResults) async {
    _logger
      ..detail('Argument information:')
      ..detail('  Top level options:');
    for (final option in topLevelResults.options) {
      if (topLevelResults.wasParsed(option)) {
        _logger.detail('  - $option: ${topLevelResults[option]}');
      }
    }
    if (topLevelResults.command != null) {
      final commandResult = topLevelResults.command!;
      _logger
        ..detail('  Command: ${commandResult.name}')
        ..detail('    Command options:');
      for (final option in commandResult.options) {
        if (commandResult.wasParsed(option)) {
          _logger.detail('    - $option: ${commandResult[option]}');
        }
      }
    }

    if (_analytics.enabled) {
      _logger.detail('Running with analytics enabled.');
    }

    int? exitCode = ExitCode.unavailable.code;
    if (topLevelResults['version'] == true) {
      _logger.info(packageVersion);
      exitCode = ExitCode.success.code;
    } else if (topLevelResults['analytics'] != null) {
      final optIn = topLevelResults['analytics'] == 'true';
      _analytics.enabled = optIn;
      _logger.info('analytics ${_analytics.enabled ? 'enabled' : 'disabled'}.');
      exitCode = ExitCode.success.code;
    } else {
      exitCode = await super.runCommand(topLevelResults);
    }
    await _checkForUpdates();
    return exitCode;
  }

  Future<void> _checkForUpdates() async {
    try {
      final latestVersion = await _pubUpdater.getLatestVersion(packageName);
      final isUpToDate = packageVersion == latestVersion;
      if (!isUpToDate) {
        _logger
          ..info('')
          ..info(
            '''
${lightYellow.wrap('Update available!')} ${lightCyan.wrap(packageVersion)} \u2192 ${lightCyan.wrap(latestVersion)}
${lightYellow.wrap('Changelog:')} ${lightCyan.wrap('https://github.com/tomassasovsky/automatic_version_upgrader.dart/releases/tag/v$latestVersion')}
Run ${lightCyan.wrap('automatic_version_upgrader update')} to update''',
          );
      }
    } catch (_) {}
  }

  /// Standard timeout duration for the CLI.
  static const timeout = Duration(milliseconds: 500);
}
