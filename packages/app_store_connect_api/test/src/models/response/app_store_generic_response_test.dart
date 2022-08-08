import 'dart:convert';

import 'package:app_store_connect_api/src/models/models.dart';
import 'package:equatable/equatable.dart';
import 'package:test/test.dart';

const source = {
  'data': [
    {'value': 1},
    {'value': 2},
    {'value': 3},
  ],
  'meta': {
    'paging': {
      'limit': 3,
      'total': 100,
    }
  }
};

class MockSerializable extends Serializable with EquatableMixin {
  const MockSerializable(this.value);

  factory MockSerializable.fromJson(String json) {
    final map = jsonDecode(json) as Map;
    return MockSerializable.fromMap(map);
  }

  factory MockSerializable.fromMap(Map<dynamic, dynamic> map) {
    return MockSerializable(map['value'] as int);
  }

  final int value;

  @override
  Map<String, dynamic> toMap() => {};

  @override
  String toJson() => '';

  @override
  List<Object?> get props => [value];
}

void main() {
  group('[AppStoreGenericResponse tests]:', () {
    test('Creating an Instance', () {
      const response = AppStoreGenericResponse<Serializable, Serializable>(
        items: [
          MockSerializable(1),
          MockSerializable(2),
          MockSerializable(3),
        ],
        meta: Meta(
          paging: Paging(
            limit: 3,
            total: 100,
          ),
        ),
      );

      expect(response.items.length, 3);
      expect(
        response.items,
        equals(const [
          MockSerializable(1),
          MockSerializable(2),
          MockSerializable(3),
        ]),
      );

      expect(response.meta, isNotNull);
      expect(response.meta, isA<Meta>());
      expect(response.meta.paging, isNotNull);
      expect(response.meta.paging, isA<Paging>());
      expect(response.meta.paging?.limit, equals(3));
      expect(response.meta.paging?.total, equals(100));
    });

    test('Creating an Instance from a map', () {
      final response =
          AppStoreGenericResponse<Serializable, Serializable>.fromMap(
        MockSerializable.fromMap,
        source,
      );

      expect(response.items.length, 3);
      expect(
        response.items,
        equals(const [
          MockSerializable(1),
          MockSerializable(2),
          MockSerializable(3),
        ]),
      );

      expect(response.meta, isNotNull);
      expect(response.meta, isA<Meta>());
      expect(response.meta.paging, isNotNull);
      expect(response.meta.paging, isA<Paging>());
      expect(response.meta.paging?.limit, equals(3));
      expect(response.meta.paging?.total, equals(100));
    });
  });
}
