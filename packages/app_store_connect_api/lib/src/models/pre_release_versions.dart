import 'dart:convert';

import 'package:app_store_connect_api/src/models/models.dart';
import 'package:pub_semver/pub_semver.dart';

/// {@template app_store_version}
/// A version of an app in the App Store Connect API.
/// {@endtemplate}
class AppStorePreReleaseVersion extends Serializable {
  /// {@macro app_store_version}
  const AppStorePreReleaseVersion({
    this.type,
    this.id,
    this.attributes,
  });

  /// {@macro app_store_version}
  factory AppStorePreReleaseVersion.fromMap(Map<dynamic, dynamic> map) {
    map = map.cast<String, dynamic>();

    return AppStorePreReleaseVersion(
      type: map['type'] as String?,
      id: map['id'] as String?,
      attributes: map['attributes'] == null
          ? null
          : AppStorePreReleaseVersionAttributes.fromMap(
              map['attributes'] as Map? ?? {},
            ),
    );
  }

  /// The type of the version.
  final String? type;

  /// The id of the version.
  final String? id;

  /// The attributes of the version.
  final AppStorePreReleaseVersionAttributes? attributes;

  @override
  Map<String, dynamic> toMap() {
    return {
      if (type != null) 'type': type,
      if (id != null) 'id': id,
      if (attributes != null) 'attributes': attributes?.toMap(),
    };
  }

  @override
  String toJson() => json.encode(toMap());

  /// Creates a copy of this version overriding the old values
  /// if new ones are provided.
  AppStorePreReleaseVersion copy({
    String? type,
    String? id,
    AppStorePreReleaseVersionAttributes? attributes,
  }) {
    return AppStorePreReleaseVersion(
      type: type ?? this.type,
      id: id ?? this.id,
      attributes: attributes ?? this.attributes,
    );
  }
}

/// {@template app_store_version_attributes}
/// The attributes of a version of an app in the App Store Connect API.
/// {@endtemplate}
class AppStorePreReleaseVersionAttributes extends Serializable {
  /// {@macro app_store_version_attributes}
  const AppStorePreReleaseVersionAttributes({
    this.platform,
    this.versionString,
  });

  /// {@macro app_store_version_attributes}
  factory AppStorePreReleaseVersionAttributes.fromMap(
    Map<dynamic, dynamic> map,
  ) {
    map = map.cast<String, dynamic>();

    return AppStorePreReleaseVersionAttributes(
      platform: ApplePlatform.fromString(map['platform'] as String?),
      versionString: map['version'] as String?,
    );
  }

  /// The platform of the build.
  final ApplePlatform? platform;

  /// The version string of the version.
  final String? versionString;

  @override
  Map<String, dynamic> toMap() {
    return {
      if (platform != null) 'platform': platform,
      if (versionString != null) 'version': versionString,
    };
  }

  @override
  String toJson() => json.encode(toMap());

  /// Creates a copy of this version overriding the old values
  /// if new ones are provided.
  AppStorePreReleaseVersionAttributes copy({
    ApplePlatform? platform,
    String? versionString,
  }) {
    return AppStorePreReleaseVersionAttributes(
      platform: platform ?? this.platform,
      versionString: versionString ?? this.versionString,
    );
  }
}

/// Parses the versionString of a version to a Version object.
/// Returns [Version.none] if the versionString is null.
extension DefaultPreReleaseVersion on AppStorePreReleaseVersionAttributes? {
  /// The version of the app.
  Version get version {
    try {
      return Version.parse(this!.versionString!);
    } catch (e) {
      return Version.none;
    }
  }
}

/// Get the latest version of an app that's published in the App Store.
extension LatestPreReleaseVersion
    on AppStoreGenericResponse<AppStorePreReleaseVersion, Serializable> {
  /// The latest version of the app.
  AppStorePreReleaseVersion get latestVersion {
    final sortedItems = items.toList()
      ..sort(
        (a, b) {
          final aVersion = a.attributes.version;
          final bVersion = b.attributes.version;

          return aVersion.compareTo(bVersion);
        },
      );

    return sortedItems.last;
  }
}
