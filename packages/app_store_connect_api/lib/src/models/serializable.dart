import 'package:meta/meta.dart';

/// {@template serializable}
/// A serializable base class.
/// {@endtemplate}
@internal
abstract class Serializable {
  /// {@macro serializable}
  const Serializable();

  /// Convert this object to a JSON map.
  String toJson();

  /// Convert this object to a JSON string.
  Map<String, dynamic> toMap();
}
