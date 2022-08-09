import 'package:googleapis/androidpublisher/v3.dart';

/// Returns the latest version available in the response.
extension LatestVersion on TracksListResponse {
  /// Returns the latest version code available in the response.
  int get latestVersionCode => tracks?.latestVersionCode ?? 1;
}

/// Returns the latest version code of the tracks available.
extension LatestTrackVersion on List<Track>? {
  /// Returns the latest code version of the tracks available.
  int get latestVersionCode {
    final versionCodes = <int>[];

    this?.forEach((element) {
      final versionCode = element.releases?.latestVersionCode;
      if (versionCode != null) {
        versionCodes.add(versionCode);
      }
    });

    versionCodes.sort();
    try {
      return versionCodes.last;
    } catch (_) {
      return 0;
    }
  }
}

/// Returns the latest version code of the tracks available.
extension LatestTrackReleaseVersion on List<TrackRelease>? {
  /// Returns the latest version code of the app.
  int get latestVersionCode {
    final versionCodes = <int>{};

    this?.forEach((element) {
      final buildList = (element.versionCodes ?? []).map(int.parse).toList()
        ..sort();
      try {
        versionCodes.add(buildList.last);
      } catch (_) {}
    });

    try {
      return versionCodes.last;
    } catch (_) {
      return 0;
    }
  }
}
