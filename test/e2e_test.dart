@Tags(['e2e'])
import 'package:automatic_version_upgrader/src/command_runner.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:universal_io/io.dart';
import 'package:usage/usage.dart';

class _MockAnalytics extends Mock implements Analytics {}

class _MockLogger extends Mock implements Logger {}

class _MockProgress extends Mock implements Progress {}

void main() {
  group(
    'E2E',
    () {
      late Analytics analytics;
      late Logger logger;
      late Progress progress;
      // ignore: unused_local_variable
      late AutomaticVersionUpgraderCommandRunner commandRunner;

      void _removeTemporaryFiles() {
        try {
          Directory('.tmp').deleteSync(recursive: true);
        } catch (_) {}
      }

      setUpAll(_removeTemporaryFiles);
      tearDownAll(_removeTemporaryFiles);

      setUp(() {
        analytics = _MockAnalytics();
        logger = _MockLogger();

        when(() => analytics.firstRun).thenReturn(false);
        when(() => analytics.enabled).thenReturn(false);
        when(
          () => analytics.sendEvent(any(), any(), label: any(named: 'label')),
        ).thenAnswer((_) async {});
        when(
          () => analytics.waitForLastPing(timeout: any(named: 'timeout')),
        ).thenAnswer((_) async {});

        logger = _MockLogger();
        progress = _MockProgress();
        when(() => logger.progress(any())).thenReturn(progress);

        commandRunner = AutomaticVersionUpgraderCommandRunner(
          analytics: analytics,
          logger: logger,
        );

        // TODO(tomassasovsky): add command runner tests
        test(
          'version check',
          () async {
            final result = await commandRunner.run(
              ['--version'],
            );

            expect(result, equals(ExitCode.success.code));
          },
          tags: const Tags(['e2e']),
        );
      });
    },
    timeout: const Timeout(Duration(seconds: 90)),
  );
}
