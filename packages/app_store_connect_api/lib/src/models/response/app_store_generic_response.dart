part of 'response.dart';

/// {@template app_store_connect_generic_response}
/// A generic response from the App Store Connect API.
/// {@endtemplate}
class AppStoreGenericResponse<T1 extends Serializable, T2 extends Serializable>
    extends Serializable with EquatableMixin {
  /// {@macro app_store_connect_generic_response}
  const AppStoreGenericResponse({
    this.meta = const Meta(),
    this.items = const [],
    this.included = const [],
    this.links = const [],
  });

  /// {@macro app_store_connect_generic_response}
  /// A parser for the App Store Connect API response.
  /// Accepts a JSON Map and returns a [AppStoreGenericResponse] object.
  factory AppStoreGenericResponse.fromMap(
    T1 Function(Map<dynamic, dynamic> map) itemParser,
    Map<dynamic, dynamic> json, {
    T2 Function(Map<dynamic, dynamic> map)? includedParser,
  }) {
    // make sure we're dealing with a JSON map
    json = json.cast<String, dynamic>();

    // extract the results from the map
    late final List<Map<String, dynamic>> items;
    List<Map<String, dynamic>>? included;

    final mapData = json['data'];

    if (mapData is List) {
      items = mapData
          .cast<Map<dynamic, dynamic>>()
          .map((Map<dynamic, dynamic> item) => item.cast<String, dynamic>())
          .toList();
    } else if (mapData is Map) {
      items = [mapData.cast<String, dynamic>()];
    } else {
      items = [];
    }

    final mapIncluded = json['included'];

    if (mapIncluded is List) {
      included = mapIncluded
          .cast<Map<dynamic, dynamic>>()
          .map((Map<dynamic, dynamic> item) => item.cast<String, dynamic>())
          .toList();
    } else if (mapIncluded is Map) {
      included = [mapIncluded.cast<String, dynamic>()];
    }

    // parse the results into a list of objects
    final parsedItems = items.map(itemParser).toList();
    List<T2>? parsedIncluded;

    if (includedParser != null) {
      // parse the results into a list of objects
      parsedIncluded = included?.map(includedParser).toList();
    }

    return AppStoreGenericResponse(
      meta: Meta.fromMap(json['meta'] as Map? ?? {}),
      items: parsedItems,
      included: parsedIncluded,
    );
  }

  /// {@macro app_store_connect_generic_response}
  /// A parser for the App Store Connect API response.
  /// Accepts a JSON String and returns a [AppStoreGenericResponse] object.
  factory AppStoreGenericResponse.fromJson(
    T1 Function(Map<dynamic, dynamic> map) itemParser,
    String source, {
    T2 Function(Map<dynamic, dynamic> map)? includedParser,
  }) =>
      AppStoreGenericResponse.fromMap(
        itemParser,
        json.decode(source) as Map,
        includedParser: includedParser,
      );

  @override
  Map<String, dynamic> toMap() {
    return {
      'meta': meta.toMap(),
      'items': items.map((x) => x.toMap()).toList(),
      'links': links,
    };
  }

  @override
  String toJson() => json.encode(toMap());

  /// An object containing the pagination information returned from the API.
  final Meta meta;

  /// A response that contains a list of App Store [T1] resources.
  final List<T1> items;

  /// A response that contains a list of App Store [T2] resources
  /// related to T1.
  final List<T2>? included;

  /// Links related to the response document, including paging links.
  final List<dynamic> links;

  @override
  List<Object?> get props => [meta, items, links];

  @override
  String toString() => '''
AppStoreGenericResponse(
    meta: $meta,
    items: $items,
    links: $links
)''';
}
