import 'package:hive_flutter/hive_flutter.dart';
import '../core/constants/app_constants.dart';
import '../models/run_record.dart';
import '../models/weekly_goal.dart';
import '../models/streak_data.dart';

class StorageService {
  late Box<RunRecord> _runsBox;
  late Box<WeeklyGoal> _goalsBox;
  late Box<StreakData> _streaksBox;

  Future<void> init() async {
    await Hive.initFlutter();

    Hive.registerAdapter(RunRecordAdapter());
    Hive.registerAdapter(WeeklyGoalAdapter());
    Hive.registerAdapter(StreakDataAdapter());

    _runsBox = await Hive.openBox<RunRecord>(AppConstants.runsBox);
    _goalsBox = await Hive.openBox<WeeklyGoal>(AppConstants.goalsBox);
    _streaksBox = await Hive.openBox<StreakData>(AppConstants.streaksBox);
  }

  // --- Runs ---

  Future<void> saveRun(RunRecord run) async {
    await _runsBox.put(run.id, run);
  }

  List<RunRecord> getAllRuns() {
    final runs = _runsBox.values.toList();
    runs.sort((a, b) => b.startTime.compareTo(a.startTime));
    return runs;
  }

  List<RunRecord> getRunsForWeek(DateTime weekStart) {
    final weekEnd = weekStart.add(const Duration(days: 7));
    return _runsBox.values.where((run) {
      return run.startTime.isAfter(weekStart) &&
          run.startTime.isBefore(weekEnd);
    }).toList();
  }

  List<RunRecord> getRecentRuns(int count) {
    final all = getAllRuns();
    return all.take(count).toList();
  }

  // --- Goals ---

  Future<void> saveGoal(WeeklyGoal goal) async {
    await _goalsBox.put('current', goal);
  }

  WeeklyGoal? getCurrentGoal() {
    return _goalsBox.get('current');
  }

  // --- Streaks ---

  Future<void> saveStreak(StreakData streak) async {
    await _streaksBox.put('current', streak);
  }

  StreakData getStreak() {
    return _streaksBox.get('current') ?? StreakData.initial();
  }
}
