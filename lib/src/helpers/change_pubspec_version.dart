import 'package:mason_logger/mason_logger.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:universal_io/io.dart';

/// {@template pubspec_version_changer_template}
/// The [PubspecVersionChanger] class is used to change the version code of the
/// and version name in a pubspec.yaml file.
class PubspecVersionChanger {
  /// {@macro pubspec_version_changer_template}
  PubspecVersionChanger({
    Logger? logger,
  }) : _logger = logger ?? Logger();

  final Logger _logger;
  final _pubspecFile = File('pubspec.yaml');

  /// Updates the version of the pubspec.yaml file.
  void updateVersionCode(
    Directory pubspecRoot,
    String newVersion,
  ) {
    if (!_pubspecFile.existsSync()) {
      _logger.err('pubspec.yaml not found');
      exit(ExitCode.osFile.code);
    }

    final pubspecLines = _pubspecFile.readAsLinesSync();

    final pubspecVersionLine = pubspecLines.asMap().entries.firstWhere(
          (element) => element.value.startsWith('version:'),
        );

    final _newVersion = Version.parse(newVersion);

    pubspecLines[pubspecVersionLine.key] = 'version: $_newVersion';
    _pubspecFile.writeAsStringSync(pubspecLines.join('\n'));
  }

  /// Gets the current version of the pubspec.yaml file.
  Version currentVersion(
    Directory pubspecRoot,
  ) {
    final pubspecLines = _pubspecFile.readAsLinesSync();
    final pubspecVersionLine = pubspecLines.asMap().entries.firstWhere(
          (element) => element.value.startsWith('version:'),
        );
    final currentVersionStr =
        pubspecVersionLine.value.substring('version:'.length).trim();
    return Version.parse(currentVersionStr);
  }
}
