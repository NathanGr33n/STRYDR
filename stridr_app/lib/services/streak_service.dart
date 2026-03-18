import '../models/streak_data.dart';
import 'storage_service.dart';

class StreakService {
  final StorageService _storage;

  StreakService(this._storage);

  StreakData getStreak() {
    final streak = _storage.getStreak();
    return _checkAndResetIfNeeded(streak);
  }

  Future<StreakData> recordRun(DateTime runDate) async {
    var streak = _storage.getStreak();
    final today = _dateOnly(runDate);

    if (streak.lastRunDate != null) {
      final lastDate = _dateOnly(streak.lastRunDate!);

      if (today.isAtSameMomentAs(lastDate)) {
        // Already ran today, no change
        return streak;
      }

      final yesterday = today.subtract(const Duration(days: 1));
      if (lastDate.isAtSameMomentAs(yesterday)) {
        // Consecutive day — increment streak
        final newStreak = streak.currentStreak + 1;
        streak = streak.copyWith(
          currentStreak: newStreak,
          lastRunDate: today,
          longestStreak:
              newStreak > streak.longestStreak ? newStreak : streak.longestStreak,
        );
      } else {
        // Missed day(s) — reset streak
        streak = streak.copyWith(
          currentStreak: 1,
          lastRunDate: today,
        );
      }
    } else {
      // First run ever
      streak = streak.copyWith(
        currentStreak: 1,
        lastRunDate: today,
        longestStreak: 1,
      );
    }

    await _storage.saveStreak(streak);
    return streak;
  }

  StreakData _checkAndResetIfNeeded(StreakData streak) {
    if (streak.lastRunDate == null) return streak;

    final today = _dateOnly(DateTime.now());
    final lastDate = _dateOnly(streak.lastRunDate!);
    final diff = today.difference(lastDate).inDays;

    // If more than 1 day since last run, streak is broken
    if (diff > 1) {
      final reset = streak.copyWith(currentStreak: 0);
      _storage.saveStreak(reset);
      return reset;
    }
    return streak;
  }

  int getConsecutiveRunDays() {
    final runs = _storage.getAllRuns();
    if (runs.isEmpty) return 0;

    int count = 0;
    DateTime checkDate = _dateOnly(DateTime.now());

    final runDates = runs
        .map((r) => _dateOnly(r.startTime))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));

    for (final date in runDates) {
      if (date.isAtSameMomentAs(checkDate)) {
        count++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else if (date.isBefore(checkDate)) {
        break;
      }
    }
    return count;
  }

  DateTime _dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);
}
