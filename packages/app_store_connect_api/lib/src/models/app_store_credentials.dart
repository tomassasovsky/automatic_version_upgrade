import 'package:jose/jose.dart';

/// {@template app_store_credentials}
/// Create a JWT token with the given payload and algorithm
/// {@endtemplate}
class AppStoreCredentials {
  /// {@macro app_store_credentials}
  AppStoreCredentials({
    required this.issuerId,
    required this.keyId,
    required String privateKey,
    this.audience = 'appstoreconnect-v1',
  }) : privateKey = privateKey.replaceAll(r'\n', '\n') {
    sign();
  }

  /// Signs the JWT with the private key and returns the token.
  void sign() {
    final payload = <String, dynamic>{
      'iss': issuerId,
      'exp': _createExpirationTimeAsUnixEpochTime(DateTime.now()),
      'aud': audience,
    };

    final claims = JsonWebTokenClaims.fromJson(payload);

    final builder = JsonWebSignatureBuilder()
      ..jsonContent = claims.toJson()
      ..addRecipient(
        JsonWebKey.fromPem(privateKey, keyId: keyId),
        algorithm: 'ES256',
      );

    _jws = builder.build();
    _currentToken = _jws.toCompactSerialization();
  }

  /// Your issuer ID from the API Keys page in App Store Connect;
  /// for example, 57246542-96fe-1a63-e053-0824d011072a.
  final String issuerId;

  /// Your key ID from the API Keys page in App Store Connect;
  final String audience;

  /// Your private key ID from App Store Connect; for example 2X9R4HXF34.
  final String keyId;

  /// Your private key from App Store Connect.
  final String privateKey;

  /// Get the last JWT token generated.
  String get currentToken => _currentToken;

  /// Whether the token is expired.
  bool get isExpired {
    final payload = <String, dynamic>{
      'iss': issuerId,
      'exp': _createExpirationTimeAsUnixEpochTime(DateTime.now()),
      'aud': audience,
    };

    final claims = JsonWebTokenClaims.fromJson(payload);
    return claims.issuedAt?.add(maximumTokenLifeTime).isAfter(DateTime.now()) ??
        true;
  }

  late JsonWebSignature _jws;

  /// The last JWT token generated.
  late String _currentToken;

  /// The time the JWT token lasts.
  static const maximumTokenLifeTime = Duration(minutes: 15);

  int _createExpirationTimeAsUnixEpochTime(DateTime currentTime) {
    final expirationTime = currentTime.add(maximumTokenLifeTime);
    final unixEpochTime = expirationTime.millisecondsSinceEpoch ~/ 1000;

    return unixEpochTime;
  }
}
