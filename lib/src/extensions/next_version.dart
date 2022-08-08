import 'package:app_store_connect_api/app_store_connect_api.dart';
import 'package:pub_semver/pub_semver.dart';

/// What to do upgrade in the app's version:
/// major, minor, patch, build, or breaking.
extension NextFromString on Version {
  /// The next version from the given string.
  Version next(NextVersion nextVersion) {
    switch (nextVersion) {
      case NextVersion.major:
        return nextMajor;
      case NextVersion.minor:
        return nextMinor;
      case NextVersion.patch:
        return nextPatch;
      case NextVersion.build:
        final currentBuildNumber = int.tryParse(build.join()) ?? 0;
        return copy(
          build: (currentBuildNumber + 1).toString(),
        );
      case NextVersion.breaking:
        return nextBreaking;
    }
  }
}

/// What version to upgrade to.
enum NextVersion {
  /// Upgrade to the next patch version.
  major,

  /// Upgrade to the next minor version.
  minor,

  /// Upgrade to the next patch version.
  patch,

  /// Upgrade to the next breaking version.
  breaking,

  /// Upgrade to the next build version.
  build,
}

/// Whether to upgrade the app to the latest version.
enum UpgradeMode {
  /// Always upgrade the app to the latest version.
  always,

  /// Upgrade the app to the latest version if
  /// there's a newer version available.
  outdated,

  /// Never upgrade the app to the latest version.
  never,
}
