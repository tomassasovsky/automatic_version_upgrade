import 'dart:convert';

import 'package:app_store_connect_api/src/models/models.dart';
import 'package:pub_semver/pub_semver.dart';

/// {@template app_store_version}
/// A version of an app in the App Store Connect API.
/// {@endtemplate}
class AppStoreVersion extends Serializable {
  /// {@macro app_store_version}
  const AppStoreVersion({
    this.type,
    this.id,
    this.attributes,
  });

  /// {@macro app_store_version}
  factory AppStoreVersion.fromMap(Map<dynamic, dynamic> map) {
    map = map.cast<String, dynamic>();

    return AppStoreVersion(
      type: map['type'] as String?,
      id: map['id'] as String?,
      attributes: map['attributes'] == null
          ? null
          : AppStoreVersionAttributes.fromMap(map['attributes'] as Map? ?? {}),
    );
  }

  /// The type of the version.
  final String? type;

  /// The id of the version.
  final String? id;

  /// The attributes of the version.
  final AppStoreVersionAttributes? attributes;

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
  AppStoreVersion copy({
    String? type,
    String? id,
    AppStoreVersionAttributes? attributes,
  }) {
    return AppStoreVersion(
      type: type ?? this.type,
      id: id ?? this.id,
      attributes: attributes ?? this.attributes,
    );
  }
}

/// {@template app_store_version_attributes}
/// The attributes of a version of an app in the App Store Connect API.
/// {@endtemplate}
class AppStoreVersionAttributes extends Serializable {
  /// {@macro app_store_version_attributes}
  const AppStoreVersionAttributes({
    this.platform,
    this.versionString,
    this.appStoreState,
    this.copyright,
    this.releaseType,
    this.earliestReleaseDate,
    this.downloadable,
    this.createdDate,
  });

  /// {@macro app_store_version_attributes}
  factory AppStoreVersionAttributes.fromMap(Map<dynamic, dynamic> map) {
    map = map.cast<String, dynamic>();

    return AppStoreVersionAttributes(
      platform: map['platform'] as String?,
      versionString: (map['versionString'] ?? map['version']) as String?,
      appStoreState: map['appStoreState'] as String?,
      copyright: map['copyright'] as String?,
      releaseType:
          AppStoreVersionReleaseType.fromString(map['releaseType'] as String?),
      earliestReleaseDate:
          DateTime.tryParse(map['earliestReleaseDate'] as String? ?? ''),
      downloadable: map['downloadable'] as bool?,
      createdDate: DateTime.tryParse(map['createdDate'] as String? ?? ''),
    );
  }

  /// The platform of the version.
  final String? platform;

  /// The version string of the version.
  final String? versionString;

  /// The state of the version.
  final String? appStoreState;

  /// The copyright of the version.
  final String? copyright;

  /// The release type of the version.
  final AppStoreVersionReleaseType? releaseType;

  /// The earliest release date of the version.
  final DateTime? earliestReleaseDate;

  /// Whether the version is downloadable.
  final bool? downloadable;

  /// The date the version was created.
  final DateTime? createdDate;

  @override
  Map<String, dynamic> toMap() {
    return {
      if (platform != null) 'platform': platform,
      if (versionString != null) 'versionString': versionString,
      if (appStoreState != null) 'appStoreState': appStoreState,
      if (copyright != null) 'copyright': copyright,
      if (releaseType != null) 'releaseType': releaseType.toString(),
      if (earliestReleaseDate != null)
        'earliestReleaseDate': earliestReleaseDate?.toIso8601String(),
      if (downloadable != null) 'downloadable': downloadable,
      if (createdDate != null) 'createdDate': createdDate?.toIso8601String(),
    };
  }

  @override
  String toJson() => json.encode(toMap());

  /// Creates a copy of this version overriding the old values
  /// if new ones are provided.
  AppStoreVersionAttributes copy({
    String? platform,
    String? versionString,
    String? appStoreState,
    String? copyright,
    AppStoreVersionReleaseType? releaseType,
    DateTime? earliestReleaseDate,
    bool? downloadable,
    DateTime? createdDate,
  }) {
    return AppStoreVersionAttributes(
      platform: platform ?? this.platform,
      versionString: versionString ?? this.versionString,
      appStoreState: appStoreState ?? this.appStoreState,
      copyright: copyright ?? this.copyright,
      releaseType: releaseType ?? this.releaseType,
      earliestReleaseDate: earliestReleaseDate ?? this.earliestReleaseDate,
      downloadable: downloadable ?? this.downloadable,
      createdDate: createdDate ?? this.createdDate,
    );
  }
}

/// How that the version was released.
enum AppStoreVersionReleaseType {
  /// The version was released to the App Store.
  manual,

  /// The version was released automatically.
  afterApproval,

  /// The version was released automatically.
  scheduled;

  // ignore: public_member_api_docs
  const AppStoreVersionReleaseType();

  // ignore: public_member_api_docs
  static AppStoreVersionReleaseType? fromString(String? value) {
    final nameToValue = {
      'MANUAL': AppStoreVersionReleaseType.manual,
      'AFTER_APPROVAL': AppStoreVersionReleaseType.afterApproval,
      'SCHEDULED': AppStoreVersionReleaseType.scheduled,
    };

    return nameToValue[value];
  }

  @override
  String toString() {
    final nameToValue = {
      AppStoreVersionReleaseType.manual: 'MANUAL',
      AppStoreVersionReleaseType.afterApproval: 'AFTER_APPROVAL',
      AppStoreVersionReleaseType.scheduled: 'SCHEDULED',
    };

    return nameToValue[this]!;
  }
}

/// Parses the versionString of a version to a Version object.
/// Returns [Version.none] if the versionString is null.
extension DefaultAppStoreVersion on AppStoreVersionAttributes? {
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
extension LatestAppStoreVersion
    on AppStoreGenericResponse<AppStoreVersion, Serializable> {
  /// The latest version of the app.
  AppStoreVersion get latestVersion {
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
