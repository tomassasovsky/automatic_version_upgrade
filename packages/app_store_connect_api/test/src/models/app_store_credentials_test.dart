import 'package:app_store_connect_api/app_store_connect_api.dart';
import 'package:jose/jose.dart';
import 'package:test/test.dart';

const issuerId = '57246542-96fe-1a63-e053-0824d011072a';

const keyId = '2X9R4HXF34';

const privateKey = '''
-----BEGIN PRIVATE KEY-----
MIGHAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBG0wawIBAQQgevZzL1gdAFr88hb2
OF/2NxApJCzGCEDdfSp6VQO30hyhRANCAAQRWz+jn65BtOMvdyHKcvjBeBSDZH2r
1RTwjmYSi9R/zpBnuQ4EiMnCqfMPWiZqB4QdbAd0E7oH50VpuZ1P087G
-----END PRIVATE KEY-----''';

void main() {
  group('[AppStoreCredentials tests]:', () {
    test('Creating an Instance', () {
      final credentials = AppStoreCredentials(
        privateKey: privateKey,
        issuerId: issuerId,
        keyId: keyId,
      );

      expect(credentials.privateKey, privateKey);
      expect(credentials.issuerId, issuerId);
      expect(credentials.keyId, keyId);
      expect(credentials.audience, 'appstoreconnect-v1');
    });

    test('Validating the generated token', () async {
      final credentials = AppStoreCredentials(
        privateKey: privateKey,
        issuerId: issuerId,
        keyId: keyId,
      );

      final token = credentials.currentToken;
      final isValid = await JsonWebToken.unverified(token).verify(
        JsonWebKeyStore()
          ..addKey(
            JsonWebKey.fromPem(
              privateKey,
              keyId: keyId,
            ),
          ),
      );

      expect(isValid, isTrue);
    });

    test('Making sure validation with incorrect key fails', () async {
      final credentials = AppStoreCredentials(
        privateKey: privateKey,
        issuerId: issuerId,
        keyId: keyId,
      );

      final token = credentials.currentToken;
      final isValid =
          await JsonWebToken.unverified(token).verify(JsonWebKeyStore());

      expect(isValid, isFalse);
    });

    test('Regenerating the token', () async {
      final credentials = AppStoreCredentials(
        privateKey: privateKey,
        issuerId: issuerId,
        keyId: keyId,
      );

      final token = credentials.currentToken;
      credentials.sign();
      final newToken = credentials.currentToken;

      expect(token, isNot(newToken));
    });
  });
}
