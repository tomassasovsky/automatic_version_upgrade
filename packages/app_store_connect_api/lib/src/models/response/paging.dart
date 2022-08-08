part of 'response.dart';

/// {@template app_store_version_paging}
/// Paging information for data responses.
/// {@endtemplate}
class Paging extends Serializable {
  /// {@macro app_store_version_paging}
  const Paging({
    this.total,
    this.limit,
  });

  /// {@macro app_store_version_paging}
  factory Paging.fromMap(Map<dynamic, dynamic> map) {
    map = map.cast<String, dynamic>();

    return Paging(
      total: map['total'] as int?,
      limit: map['limit'] as int?,
    );
  }

  /// The total number of resources matching your request.
  final int? total;

  /// The number of results returned per page.
  final int? limit;

  @override
  Map<String, dynamic> toMap() {
    return {
      if (total != null) 'total': total,
      if (limit != null) 'limit': limit,
    };
  }

  @override
  String toJson() => json.encode(toMap());
}
