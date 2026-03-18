import '../core/constants/app_constants.dart';
import '../models/weekly_goal.dart';
import 'storage_service.dart';

class GoalService {
  final StorageService _storage;

  GoalService(this._storage);

  WeeklyGoal getOrCreateGoal() {
    final existing = _storage.getCurrentGoal();
    if (existing != null) {
      // Check if we need a new week
      final currentWeekStart = _getWeekStart(DateTime.now());
      if (existing.weekStart.isBefore(currentWeekStart)) {
        final newGoal = WeeklyGoal(
          targetMiles: existing.targetMiles,
          weekStart: currentWeekStart,
        );
        _storage.saveGoal(newGoal);
        return newGoal;
      }
      return existing;
    }
    final newGoal = WeeklyGoal(
      targetMiles: AppConstants.defaultWeeklyGoalMiles,
      weekStart: _getWeekStart(DateTime.now()),
    );
    _storage.saveGoal(newGoal);
    return newGoal;
  }

  Future<void> updateGoalTarget(double targetMiles) async {
    final goal = getOrCreateGoal();
    final updated = goal.copyWith(targetMiles: targetMiles);
    await _storage.saveGoal(updated);
  }

  double getCurrentWeekMiles() {
    final weekStart = _getWeekStart(DateTime.now());
    final runs = _storage.getRunsForWeek(weekStart);
    double total = 0;
    for (final run in runs) {
      total += run.distanceMiles;
    }
    return total;
  }

  double getProgress() {
    final goal = getOrCreateGoal();
    final current = getCurrentWeekMiles();
    if (goal.targetMiles <= 0) return 0;
    return (current / goal.targetMiles).clamp(0.0, 1.0);
  }

  bool isGoalReached() {
    return getCurrentWeekMiles() >= getOrCreateGoal().targetMiles;
  }

  DateTime _getWeekStart(DateTime date) {
    final weekday = date.weekday; // Monday = 1
    final monday = date.subtract(Duration(days: weekday - 1));
    return DateTime(monday.year, monday.month, monday.day);
  }
}
