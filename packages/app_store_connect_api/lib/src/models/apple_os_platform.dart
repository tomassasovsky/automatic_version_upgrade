// ignore_for_file: public_member_api_docs
/// The OS the version is for.
enum ApplePlatform {
  ios,
  macOS,
  tvOS;

  const ApplePlatform();

  static ApplePlatform? fromString(String? value) {
    final nameToValue = {
      'IOS': ApplePlatform.ios,
      'MAC_OS': ApplePlatform.macOS,
      'TV_OS': ApplePlatform.tvOS,
    };

    return nameToValue[value];
  }

  @override
  String toString() {
    final nameToValue = {
      ApplePlatform.ios: 'IOS',
      ApplePlatform.macOS: 'MAC_OS',
      ApplePlatform.tvOS: 'TV_OS',
    };

    return nameToValue[this]!;
  }
}
