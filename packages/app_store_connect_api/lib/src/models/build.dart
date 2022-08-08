import 'dart:convert';
import 'package:app_store_connect_api/src/models/models.dart';
import 'package:pub_semver/pub_semver.dart';

/// {@template app_store_version}
/// A build of a version of an app in App Store Connect.
/// Applies to pre-release versions of an app as well as to the latest release
/// of an app.
/// {@endtemplate}
class AppStoreBuild extends Serializable {
  /// {@macro app_store_version}
  const AppStoreBuild({
    this.type,
    this.id,
    this.attributes,
  });

  /// {@macro app_store_version}
  factory AppStoreBuild.fromMap(Map<dynamic, dynamic> map) {
    map = map.cast<String, dynamic>();

    return AppStoreBuild(
      type: map['type'] as String?,
      id: map['id'] as String?,
      attributes: map['attributes'] == null
          ? null
          : AppStoreBuildAttributes.fromMap(map['attributes'] as Map? ?? {}),
    );
  }

  /// The type of the version.
  final String? type;

  /// The id of the version.
  final String? id;

  /// The attributes of the version.
  final AppStoreBuildAttributes? attributes;

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
}

/// {@template app_store_version}
/// A version of an app in the App Store Connect API.
/// {@endtemplate}
class AppStoreBuildAttributes extends Serializable {
  /// {@macro app_store_version}
  const AppStoreBuildAttributes({
    this.expired,
    this.iconAssetToken,
    this.minOsVersion,
    this.processingState,
    this.version,
    this.usesNonExemptEncryption,
    this.uploadedDate,
    this.expirationDate,
    this.buildAudienceType,
    this.computedMinMacOsVersion,
    this.lsMinimumSystemVersion,
  });

  /// {@macro app_store_version}
  factory AppStoreBuildAttributes.fromMap(Map<dynamic, dynamic> map) {
    map = map.cast<String, dynamic>();

    return AppStoreBuildAttributes(
      expired: map['expired'] as bool?,
      iconAssetToken: map['iconAssetToken'] != null
          ? AppStoreConnectImageAsset.fromMap(map['iconAssetToken'] as Map)
          : null,
      minOsVersion: map['minOsVersion'] as String?,
      processingState:
          ProcessingState.fromMatcher(map['processingState'] as String?),
      version: map['version'] as String?,
      usesNonExemptEncryption: map['usesNonExemptEncryption'] as bool?,
      uploadedDate: DateTime.tryParse(map['uploadedDate'] as String? ?? ''),
      expirationDate: DateTime.tryParse(map['expirationDate'] as String? ?? ''),
      buildAudienceType: BuildAudienceType.fromMatcher(
        map['buildAudienceType'] as String?,
      ),
      computedMinMacOsVersion: map['computedMinMacOsVersion'] as String?,
      lsMinimumSystemVersion: map['lsMinimumSystemVersion'] as String?,
    );
  }

  /// A Boolean value that indicates if the build has expired.
  /// An expired build is unavailable for testing.
  final bool? expired;

  /// The icon of the uploaded build.
  final AppStoreConnectImageAsset? iconAssetToken;

  /// The minimum operating system version needed to test a build.
  final String? minOsVersion;

  /// The processing state of the build indicating that it is
  /// not yet available for testing.
  final ProcessingState? processingState;

  /// The version number of the uploaded build (build number).
  final String? version;

  /// A Boolean value that indicates whether the build
  /// uses non-exempt encryption.
  final bool? usesNonExemptEncryption;

  /// The date and time the build was uploaded to App Store Connect.
  final DateTime? uploadedDate;

  /// The date and time the build will auto-expire and
  /// no longer be available for testing.
  final DateTime? expirationDate;

  /// A string that represents the App Store Connect audience for a build.
  final BuildAudienceType? buildAudienceType;

  // ignore: public_member_api_docs
  final String? computedMinMacOsVersion;

  // ignore: public_member_api_docs
  final String? lsMinimumSystemVersion;

  @override
  String toJson() => json.encode(toMap());

  @override
  Map<String, dynamic> toMap() {
    return {
      if (expired != null) 'expired': expired,
      if (iconAssetToken != null) 'iconAssetToken': iconAssetToken?.toMap(),
      if (minOsVersion != null) 'minOsVersion': minOsVersion,
      if (processingState != null) 'processingState': processingState?.matcher,
      if (version != null) 'version': version,
      if (usesNonExemptEncryption != null)
        'usesNonExemptEncryption': usesNonExemptEncryption,
      if (uploadedDate != null) 'uploadedDate': uploadedDate?.toIso8601String(),
      if (expirationDate != null)
        'expirationDate': expirationDate?.toIso8601String(),
      if (buildAudienceType != null)
        'buildAudienceType': buildAudienceType?.matcher,
      if (computedMinMacOsVersion != null)
        'computedMinMacOsVersion': computedMinMacOsVersion,
      if (lsMinimumSystemVersion != null)
        'lsMinimumSystemVersion': lsMinimumSystemVersion,
    };
  }
}

/// Possible values: PROCESSING, FAILED, INVALID, VALID
enum ProcessingState {
  /// The app is currently being processed.
  processing('PROCESSING'),

  /// The app failed to process.
  failed('FAILED'),

  /// The app is invalid.
  invalid('INVALID'),

  /// The app is valid.
  valid('VALID');

  /// {@macro build_audience_type}
  const ProcessingState(this.matcher);

  /// The string that matches the value of the processing state.
  final String? matcher;

  /// {@macro build_audience_type}
  static ProcessingState fromMatcher(String? matcher) => values.firstWhere(
        (element) => element.matcher == matcher,
        orElse: () => ProcessingState.invalid,
      );
}

/// Possible values: PROCESSING, FAILED, INVALID, VALID
enum BuildAudienceType {
  /// The build of your app is only available
  /// to members of your development team.
  internalOnly('INTERNAL_ONLY'),

  /// The build of your app is eligible
  /// for submission and release on the App Store.
  appStoreElegible('APP_STORE_ELIGIBLE');

  /// {@macro build_audience_type}
  const BuildAudienceType(this.matcher);

  /// The string that matches the value of the Build Audience Type.
  final String? matcher;

  /// {@macro build_audience_type}
  static BuildAudienceType fromMatcher(String? matcher) => values.firstWhere(
        (element) => element.matcher == matcher,
        orElse: () => BuildAudienceType.internalOnly,
      );
}

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
}

/// Get the latest version of an app that's published in the App Store.
extension LatestBuildVersion
    on AppStoreGenericResponse<AppStoreVersion, AppStoreBuild> {
  /// The latest version of the app.
  AppStoreVersion get latestVersion {
    final lastVersion = items.first;
    final lastVersionAttributes = lastVersion.attributes;
    final latestVersion = lastVersion.attributes.version;

    final latestBuild = included?.first;

    final latestBuildNumber = int.tryParse(
      latestBuild?.attributes?.version ?? latestVersion.build.join(),
    );

    return lastVersion.copy(
      attributes: lastVersionAttributes?.copy(
        versionString: latestVersion
            .copy(
              build: latestBuildNumber?.toString(),
            )
            .toString(),
      ),
    );
  }
}

/// Get the latest version of an app that's published in the App Store.
extension LatestPreReleaseBuildVersion
    on AppStoreGenericResponse<AppStorePreReleaseVersion, AppStoreBuild> {
  /// The latest version of the app.
  AppStorePreReleaseVersion get latestVersion {
    final lastVersion = items.first;
    final lastVersionAttributes = lastVersion.attributes;
    final latestVersion = lastVersion.attributes.version;

    final latestBuild = included?.first;

    final latestBuildNumber = int.tryParse(
      latestBuild?.attributes?.version ?? latestVersion.build.join(),
    );

    return lastVersion.copy(
      attributes: lastVersionAttributes?.copy(
        versionString:
            latestVersion.copy(build: latestBuildNumber?.toString()).toString(),
      ),
    );
  }
}
