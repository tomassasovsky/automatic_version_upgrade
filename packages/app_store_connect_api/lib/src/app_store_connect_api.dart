import 'package:app_store_connect_api/app_store_connect_api.dart';
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';

/// {@template app_store_connect_api}
/// A Very Good Project created by Very Good CLI.
/// {@endtemplate}
class AppStoreConnectApi extends AppStoreConnectApiBase {
  /// {@macro app_store_connect_api}
  const AppStoreConnectApi({
    required http.Client client,
    required AppStoreCredentials credentials,
  })  : _httpClient = client,
        _credentials = credentials;

  /// The host URL used for all API requests.
  ///
  /// Only exposed for testing purposes. Do not use directly.
  @visibleForTesting
  static const String authority = 'api.appstoreconnect.apple.com';

  final http.Client _httpClient;

  final AppStoreCredentials _credentials;

  @override
  Future<AppStoreGenericResponse<AppStoreVersion, AppStoreBuild>>
      appStoreVersions(
    String appId,
  ) async {
    final url = Uri.https(
      authority,
      '/v1/apps/$appId/appStoreVersions',
      {
        'filter[platform]': 'IOS',
        'include': 'build',
      },
    );

    if (_credentials.isExpired) _credentials.sign();

    final response = await _httpClient.get(
      url,
      headers: {
        'Authorization': 'Bearer ${_credentials.currentToken}',
      },
    );

    return AppStoreGenericResponse.fromJson(
      AppStoreVersion.fromMap,
      response.body,
      includedParser: AppStoreBuild.fromMap,
    );
  }

  @override
  Future<AppStoreGenericResponse<AppStorePreReleaseVersion, AppStoreBuild>>
      preReleaseVersions(
    String appId,
  ) async {
    final url = Uri.https(
      authority,
      '/v1/preReleaseVersions',
      {
        'filter[app]': 'id,$appId',
        'include': 'builds',
        'sort': '-version',
        'fields[preReleaseVersions]': 'version',
      },
    );

    if (_credentials.isExpired) _credentials.sign();

    final response = await _httpClient.get(
      url,
      headers: {
        'Authorization': 'Bearer ${_credentials.currentToken}',
      },
    );

    return AppStoreGenericResponse.fromJson(
      AppStorePreReleaseVersion.fromMap,
      response.body,
      includedParser: AppStoreBuild.fromMap,
    );
  }
}
