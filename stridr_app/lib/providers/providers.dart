import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/run_record.dart';
import '../models/weekly_goal.dart';
import '../models/streak_data.dart';
import '../models/suggestion.dart';
import '../services/storage_service.dart';
import '../services/run_tracking_service.dart';
import '../services/goal_service.dart';
import '../services/streak_service.dart';
import '../services/suggestion_service.dart';

// --- Storage ---
final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

// --- Run Tracking ---
final runTrackingServiceProvider = Provider<RunTrackingService>((ref) {
  final service = RunTrackingService();
  ref.onDispose(() => service.dispose());
  return service;
});

final runStateProvider =
    StreamProvider<RunState>((ref) {
  final service = ref.watch(runTrackingServiceProvider);
  return service.stateStream;
});

// --- Goal ---
final goalServiceProvider = Provider<GoalService>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return GoalService(storage);
});

final weeklyGoalProvider =
    StateNotifierProvider<WeeklyGoalNotifier, WeeklyGoalState>((ref) {
  final goalService = ref.watch(goalServiceProvider);
  return WeeklyGoalNotifier(goalService);
});

class WeeklyGoalState {
  final WeeklyGoal goal;
  final double currentMiles;
  final double progress;
  final bool goalReached;

  WeeklyGoalState({
    required this.goal,
    required this.currentMiles,
    required this.progress,
    required this.goalReached,
  });
}

class WeeklyGoalNotifier extends StateNotifier<WeeklyGoalState> {
  final GoalService _goalService;

  WeeklyGoalNotifier(this._goalService)
      : super(WeeklyGoalState(
          goal: _goalService.getOrCreateGoal(),
          currentMiles: _goalService.getCurrentWeekMiles(),
          progress: _goalService.getProgress(),
          goalReached: _goalService.isGoalReached(),
        ));

  void refresh() {
    state = WeeklyGoalState(
      goal: _goalService.getOrCreateGoal(),
      currentMiles: _goalService.getCurrentWeekMiles(),
      progress: _goalService.getProgress(),
      goalReached: _goalService.isGoalReached(),
    );
  }

  Future<void> updateTarget(double target) async {
    await _goalService.updateGoalTarget(target);
    refresh();
  }
}

// --- Streak ---
final streakServiceProvider = Provider<StreakService>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return StreakService(storage);
});

final streakProvider =
    StateNotifierProvider<StreakNotifier, StreakData>((ref) {
  final streakService = ref.watch(streakServiceProvider);
  return StreakNotifier(streakService);
});

class StreakNotifier extends StateNotifier<StreakData> {
  final StreakService _streakService;

  StreakNotifier(this._streakService) : super(_streakService.getStreak());

  void refresh() {
    state = _streakService.getStreak();
  }

  Future<void> recordRun(DateTime runDate) async {
    state = await _streakService.recordRun(runDate);
  }
}

// --- Suggestions ---
final suggestionServiceProvider = Provider<SuggestionService>((ref) {
  final storage = ref.watch(storageServiceProvider);
  final streakService = ref.watch(streakServiceProvider);
  return SuggestionService(storage, streakService);
});

final suggestionsProvider =
    StateNotifierProvider<SuggestionsNotifier, List<Suggestion>>((ref) {
  final suggestionService = ref.watch(suggestionServiceProvider);
  return SuggestionsNotifier(suggestionService);
});

class SuggestionsNotifier extends StateNotifier<List<Suggestion>> {
  final SuggestionService _suggestionService;

  SuggestionsNotifier(this._suggestionService)
      : super(_suggestionService.generateSuggestions());

  void refresh() {
    state = _suggestionService.generateSuggestions();
  }

  void dismiss(int index) {
    if (index < state.length) {
      state = List.from(state)..removeAt(index);
    }
  }
}

// --- Run History ---
final runHistoryProvider =
    StateNotifierProvider<RunHistoryNotifier, List<RunRecord>>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return RunHistoryNotifier(storage);
});

class RunHistoryNotifier extends StateNotifier<List<RunRecord>> {
  final StorageService _storage;

  RunHistoryNotifier(this._storage) : super(_storage.getAllRuns());

  Future<void> saveRun({
    required RunState runState,
    required DateTime startTime,
  }) async {
    const uuid = Uuid();
    final routePoints = <double>[];
    for (final point in runState.route) {
      routePoints.add(point.latitude);
      routePoints.add(point.longitude);
    }

    final record = RunRecord(
      id: uuid.v4(),
      startTime: startTime,
      endTime: DateTime.now(),
      distanceMeters: runState.distanceMeters,
      durationSeconds: runState.elapsed.inSeconds,
      avgPaceSecondsPerMile: runState.currentPaceSecondsPerMile,
      routePoints: routePoints,
    );

    await _storage.saveRun(record);
    state = _storage.getAllRuns();
  }

  void refresh() {
    state = _storage.getAllRuns();
  }
}
