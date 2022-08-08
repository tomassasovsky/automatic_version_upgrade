part of 'response.dart';

/// {@template app_store_version_metadata}
/// The metadata of a generic response in the App Store Connect API.
/// {@endtemplate}
class Meta extends Serializable {
  /// {@macro app_store_version_metadata}
  const Meta({this.paging});

  /// {@macro app_store_version_metadata}
  factory Meta.fromMap(Map<dynamic, dynamic> map) {
    return Meta(
      paging: map['paging'] == null
          ? null
          : Paging.fromMap(map['paging'] as Map? ?? {}),
    );
  }

  /// The pagination information of the response.
  final Paging? paging;

  @override
  Map<String, dynamic> toMap() {
    return {
      if (paging != null) 'paging': paging?.toMap(),
    };
  }

  @override
  String toJson() => json.encode(toMap());
}
