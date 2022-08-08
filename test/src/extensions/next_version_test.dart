import 'package:automatic_version_upgrader/automatic_version_upgrader.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

void main() {
  group('Next Version', () {
    test('Next from string', () {
      expect(
        Version.parse('1.0.0').next(NextVersion.major),
        Version.parse('2.0.0'),
      );
      expect(
        Version.parse('1.0.0').next(NextVersion.minor),
        Version.parse('1.1.0'),
      );
      expect(
        Version.parse('1.0.0').next(NextVersion.patch),
        Version.parse('1.0.1'),
      );
      expect(
        Version.parse('1.0.0').next(NextVersion.build),
        Version.parse('1.0.0+1'),
      );
      expect(
        Version.parse('1.0.0').next(NextVersion.breaking),
        Version.parse('2.0.0'),
      );
    });
  });
}
