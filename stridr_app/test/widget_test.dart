import 'package:flutter_test/flutter_test.dart';
import 'package:stryder/core/utils/formatters.dart';
import 'package:stryder/models/run_record.dart';
import 'package:stryder/models/suggestion.dart';
import 'package:stryder/services/storage_service.dart';
import 'package:stryder/services/streak_service.dart';
import 'package:stryder/services/suggestion_service.dart';

class FakeStorageService extends StorageService {
  FakeStorageService(this._recentRuns);

  final List<RunRecord> _recentRuns;

  @override
  List<RunRecord> getRecentRuns(int count) {
    return _recentRuns.take(count).toList();
  }
}

class FakeStreakService extends StreakService {
  FakeStreakService(this._consecutiveDays) : super(FakeStorageService([]));

  final int _consecutiveDays;

  @override
  int getConsecutiveRunDays() {
    return _consecutiveDays;
  }
}

RunRecord buildRun({required String id, required double paceSecondsPerMile}) {
  final start = DateTime(2026, 1, 1, 7, 0);
  return RunRecord(
    id: id,
    startTime: start,
    endTime: start.add(Duration(seconds: paceSecondsPerMile.round())),
    distanceMeters: 1609.344,
    durationSeconds: paceSecondsPerMile.round(),
    avgPaceSecondsPerMile: paceSecondsPerMile,
    routePoints: const [],
  );
}

void main() {
  group('Formatters', () {
    test('formats distance in miles', () {
      expect(Formatters.distanceMiles(1609.344), '1.00');
    });

    test('formats duration with and without hours', () {
      expect(Formatters.duration(const Duration(minutes: 8, seconds: 32)), '08:32');
      expect(
        Formatters.duration(const Duration(hours: 1, minutes: 2, seconds: 3)),
        '01:02:03',
      );
    });

    test('formats pace and handles invalid pace values', () {
      expect(Formatters.pace(512), '8:32');
      expect(Formatters.pace(0), '--:--');
      expect(Formatters.pace(double.nan), '--:--');
    });

    test('calculates pace from distance and duration', () {
      expect(
        Formatters.calculatePace(
          1609.344,
          const Duration(minutes: 8),
        ),
        closeTo(480, 0.001),
      );
    });
  });

  group('SuggestionService', () {
    test('returns longer-run suggestion after sustained pace improvement', () {
      final storage = FakeStorageService([
        buildRun(id: 'run_1', paceSecondsPerMile: 450),
        buildRun(id: 'run_2', paceSecondsPerMile: 455),
        buildRun(id: 'run_3', paceSecondsPerMile: 460),
        buildRun(id: 'run_4', paceSecondsPerMile: 500),
        buildRun(id: 'run_5', paceSecondsPerMile: 510),
      ]);
      final streakService = FakeStreakService(2);
      final suggestions = SuggestionService(storage, streakService).generateSuggestions();

      expect(
        suggestions.where((s) => s.type == SuggestionType.longerRun).length,
        1,
      );
    });

    test('returns rest-day suggestion after four consecutive days', () {
      final storage = FakeStorageService([]);
      final streakService = FakeStreakService(4);
      final suggestions = SuggestionService(storage, streakService).generateSuggestions();

      expect(
        suggestions.where((s) => s.type == SuggestionType.restDay).length,
        1,
      );
    });

    test('returns no suggestions when thresholds are not met', () {
      final storage = FakeStorageService([
        buildRun(id: 'run_1', paceSecondsPerMile: 500),
        buildRun(id: 'run_2', paceSecondsPerMile: 499),
      ]);
      final streakService = FakeStreakService(1);
      final suggestions = SuggestionService(storage, streakService).generateSuggestions();

      expect(suggestions, isEmpty);
    });
  });
}
