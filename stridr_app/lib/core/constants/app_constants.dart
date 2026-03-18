class AppConstants {
  AppConstants._();

  // Hive box names
  static const String runsBox = 'runs';
  static const String goalsBox = 'goals';
  static const String streaksBox = 'streaks';

  // Default values
  static const double defaultWeeklyGoalMiles = 10.0;
  static const double maxWeeklyGoalMiles = 100.0;
  static const double minWeeklyGoalMiles = 1.0;

  // GPS
  static const int gpsDistanceFilter = 5; // meters
  static const int gpsIntervalMs = 1000;

  // Suggestions thresholds
  static const int consecutiveDaysForRestSuggestion = 4;
  static const double paceImprovementThreshold = 0.05; // 5% improvement

  // Animation durations
  static const Duration quickAnimation = Duration(milliseconds: 200);
  static const Duration normalAnimation = Duration(milliseconds: 400);
  static const Duration slowAnimation = Duration(milliseconds: 800);
}
