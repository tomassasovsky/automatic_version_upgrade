import 'package:automatic_version_upgrader/automatic_version_upgrader.dart';
import 'package:test/test.dart';

void main() {
  group('AutomaticVersionUpgrader', () {
    test('can be instantiated', () {
      expect(AutomaticVersionUpgraderCommandRunner(), isNotNull);
    });
  });
}
