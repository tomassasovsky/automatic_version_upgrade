import 'dart:convert';
import 'package:app_store_connect_api/src/models/models.dart';

/// {@template app_store_version}
/// An image asset, including its height, width, and template URL.
/// {@endtemplate}
class AppStoreConnectImageAsset extends Serializable {
  /// {@macro app_store_version}
  const AppStoreConnectImageAsset({
    this.height,
    this.width,
    this.templateUrl,
  });

  /// {@macro app_store_version}
  factory AppStoreConnectImageAsset.fromMap(Map<dynamic, dynamic> map) {
    map = map.cast<String, dynamic>();

    return AppStoreConnectImageAsset(
      templateUrl: map['templateUrl'] as String?,
      height: map['height'] as int?,
      width: map['width'] as int?,
    );
  }

  /// The url of the image.
  final String? templateUrl;

  /// The height of the image.
  final int? height;

  /// The width of the image.
  final int? width;

  @override
  String toJson() => json.encode(toMap());

  @override
  Map<String, dynamic> toMap() {
    return {
      if (templateUrl != null) 'templateUrl': templateUrl,
      if (height != null) 'height': height,
      if (width != null) 'width': width,
    };
  }
}
