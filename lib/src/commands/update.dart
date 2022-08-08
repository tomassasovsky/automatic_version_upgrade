import 'package:args/command_runner.dart';
import 'package:automatic_version_upgrader/src/version.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:pub_updater/pub_updater.dart';

/// {@template update_command}
/// `automatic_version_upgrader update`
/// command which updates automatic_version_upgrader cli.
/// {@endtemplate}
class UpdateCommand extends Command<int> {
  /// {@macro update_command}
  UpdateCommand({
    required Logger logger,
    PubUpdater? pubUpdater,
    required String packageName,
  })  : _logger = logger,
        _pubUpdater = pubUpdater ?? PubUpdater(),
        _packageName = packageName;

  final Logger _logger;
  final PubUpdater _pubUpdater;
  final String _packageName;

  @override
  String get description => 'Update Automatic Version Upgrader CLI.';

  @override
  String get name => 'update';

  @override
  Future<int> run() async {
    final updateCheckProgress = _logger.progress('Checking for updates');
    late final String latestVersion;
    try {
      latestVersion = await _pubUpdater.getLatestVersion(_packageName);
    } catch (error) {
      updateCheckProgress.fail();
      _logger.err('$error');
      return ExitCode.software.code;
    }
    updateCheckProgress.complete('Checked for updates');

    final isUpToDate = packageVersion == latestVersion;
    if (isUpToDate) {
      _logger.info(
        'Automatic Version Upgrader CLI is already at the latest version.',
      );
      return ExitCode.success.code;
    }

    final updateProgress = _logger.progress('Updating to $latestVersion');
    try {
      await _pubUpdater.update(packageName: _packageName);
    } catch (error) {
      updateProgress.fail();
      _logger.err('$error');
      return ExitCode.software.code;
    }
    updateProgress.complete('Updated to $latestVersion');

    return ExitCode.success.code;
  }
}
