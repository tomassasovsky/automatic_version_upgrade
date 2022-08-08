// ignore_for_file: prefer_const_constructors
import 'package:app_store_connect_api/app_store_connect_api.dart';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

const _issuerId = '57246542-96fe-1a63-e053-0824d011072a';

const _keyId = '2X9R4HXF34';

const _privateKey =
    '''
-----BEGIN PRIVATE KEY-----
MIGHAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBG0wawIBAQQgevZzL1gdAFr88hb2
OF/2NxApJCzGCEDdfSp6VQO30hyhRANCAAQRWz+jn65BtOMvdyHKcvjBeBSDZH2r
1RTwjmYSi9R/zpBnuQ4EiMnCqfMPWiZqB4QdbAd0E7oH50VpuZ1P087G
-----END PRIVATE KEY-----''';

void main() {
  group('AppStoreConnectApi', () {
    test('can be instantiated', () {
      expect(
        AppStoreConnectApi(
          client: http.Client(),
          credentials: AppStoreCredentials(
            privateKey: _privateKey,
            issuerId: _issuerId,
            keyId: _keyId,
          ),
        ),
        isNotNull,
      );
    });
  });
}
