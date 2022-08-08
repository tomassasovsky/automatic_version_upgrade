/// {@template app_store_version_paging}
/// Links related to the response document, including paging links.
/// {@endtemplate}
class PageDocumentLinks {
  /// {@macro app_store_version_paging}
  const PageDocumentLinks({
    this.first,
    this.next,
    this.self,
  });

  /// {@macro app_store_version_paging}
  factory PageDocumentLinks.fromMap(Map<dynamic, dynamic> map) {
    map = map.cast<String, dynamic>();

    return PageDocumentLinks(
      first: map['first'] as String?,
      next: map['next'] as String?,
      self: map['self'] as String?,
    );
  }

  /// The link to the first page of documents.
  final String? first;

  /// The link to the next page of documents.
  final String? next;

  /// The link that produced the current document.
  final String? self;
}
