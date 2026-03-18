import '../core/constants/app_constants.dart';
import '../models/suggestion.dart';
import 'storage_service.dart';
import 'streak_service.dart';

class SuggestionService {
  final StorageService _storage;
  final StreakService _streakService;

  SuggestionService(this._storage, this._streakService);

  List<Suggestion> generateSuggestions() {
    final suggestions = <Suggestion>[];

    final longerRun = _checkLongerRunSuggestion();
    if (longerRun != null) suggestions.add(longerRun);

    final restDay = _checkRestDaySuggestion();
    if (restDay != null) suggestions.add(restDay);

    return suggestions;
  }

  Suggestion? _checkLongerRunSuggestion() {
    final runs = _storage.getRecentRuns(5);
    if (runs.length < 3) return null;

    // Compare average pace of last 3 runs vs previous runs
    final recentPaces = runs.take(3).map((r) => r.avgPaceSecondsPerMile).toList();
    final olderPaces = runs.skip(3).map((r) => r.avgPaceSecondsPerMile).toList();

    if (olderPaces.isEmpty) return null;

    final recentAvg = recentPaces.reduce((a, b) => a + b) / recentPaces.length;
    final olderAvg = olderPaces.reduce((a, b) => a + b) / olderPaces.length;

    // Lower pace = faster (fewer seconds per mile)
    if (recentAvg < olderAvg * (1 - AppConstants.paceImprovementThreshold)) {
      return Suggestion(
        type: SuggestionType.longerRun,
        title: 'Push further!',
        message:
            'Your pace has improved recently. Try adding an extra mile to your next run.',
      );
    }
    return null;
  }

  Suggestion? _checkRestDaySuggestion() {
    final consecutiveDays = _streakService.getConsecutiveRunDays();
    if (consecutiveDays >= AppConstants.consecutiveDaysForRestSuggestion) {
      return Suggestion(
        type: SuggestionType.restDay,
        title: 'Take a rest day',
        message:
            'You\'ve run $consecutiveDays days in a row. Recovery helps you get stronger.',
      );
    }
    return null;
  }
}
