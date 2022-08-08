import 'package:pub_semver/pub_semver.dart';

/// Creates a copy of this version overriding the old values
/// if new ones are provided.
extension VersionCopy on Version {
  /// Creates a copy of this version overriding the old values
  Version copy({
    int? major,
    int? minor,
    int? patch,
    String? preRelease,
    String? build,
    String? text,
  }) {
    String? currentBuild = this.build.join().trim();
    if (currentBuild.isEmpty) {
      currentBuild = build;
    }

    String? currentPre = this.preRelease.join().trim();
    if (currentPre.isEmpty) {
      currentPre = preRelease;
    }

    return Version(
      major ?? this.major,
      minor ?? this.minor,
      patch ?? this.patch,
      pre: preRelease ?? currentPre,
      build: build ?? currentBuild,
    );
  }

  /// Returns the latest version of the app.
  /// Strips the pre-release from the version.
  Version stripPreRelease() {
    return Version(
      major,
      minor,
      patch,
      build: build.isEmpty ? null : build.join(),
    );
  }

  /// Returns the latest version of the app.
  /// Strips the pre-release from the version.
  Version stripBuild() {
    return Version(
      major,
      minor,
      patch,
      pre: preRelease.isEmpty ? null : preRelease.join(),
    );
  }
}
