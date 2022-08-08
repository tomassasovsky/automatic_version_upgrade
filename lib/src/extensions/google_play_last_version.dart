import 'package:automatic_version_upgrader/src/extensions/extensions.dart';
import 'package:googleapis/androidpublisher/v3.dart';
import 'package:pub_semver/pub_semver.dart';

/// Returns the latest version available in the response.
extension LatestVersion on TracksListResponse {
  /// Returns the latest version available in the response.
  Version get latestVersion => tracks?.latestVersion ?? Version.none;
}

/// Returns the latest version of the tracks available.
extension LatestTrackVersion on List<Track>? {
  /// Returns the latest version of the tracks available.
  Version get latestVersion {
    final strippedToVersion = <Version, Version>{};

    this?.forEach((element) {
      strippedToVersion.addAll({
        element.releases.latestVersion.stripPreRelease():
            element.releases.latestVersion,
      });
    });

    final version = Version.primary(strippedToVersion.keys.toList());
    return strippedToVersion[version]!;
  }
}

/// Returns the latest version of the tracks available.
extension LatestTrackReleaseVersion on List<TrackRelease>? {
  /// Returns the latest version of the app.
  Version get latestVersion {
    final strippedToVersion = <Version, Version>{};

    this?.forEach((element) {
      final name = element.name ?? Version.none.toString();
      final buildList = (element.versionCodes ?? []).map(int.parse).toList()
        ..sort();

      var latestBuildNumber = 0;
      try {
        latestBuildNumber = buildList.last;
      } catch (_) {}

      if (name.contains('(')) {
        final versionStr = name.substring(
          name.indexOf('(') + 1,
          name.indexOf(')'),
        );

        if (versionStr.isNotEmpty) {
          final version = Version.parse(versionStr).copy(
            build: latestBuildNumber.toString(),
          );

          strippedToVersion.addAll({
            version.stripPreRelease(): version,
          });
        }
      } else {
        final version = Version.parse(name).copy(
          build: latestBuildNumber.toString(),
        );

        strippedToVersion.addAll({
          version.stripPreRelease(): version,
        });
      }
    });

    final primary = Version.primary(strippedToVersion.keys.toList());
    return strippedToVersion[primary] ?? Version.none;
  }
}
