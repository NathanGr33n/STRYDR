import 'package:hive/hive.dart';

part 'streak_data.g.dart';

@HiveType(typeId: 2)
class StreakData extends HiveObject {
  @HiveField(0)
  final int currentStreak;

  @HiveField(1)
  final DateTime? lastRunDate;

  @HiveField(2)
  final int longestStreak;

  StreakData({
    required this.currentStreak,
    this.lastRunDate,
    required this.longestStreak,
  });

  StreakData copyWith({
    int? currentStreak,
    DateTime? lastRunDate,
    int? longestStreak,
  }) {
    return StreakData(
      currentStreak: currentStreak ?? this.currentStreak,
      lastRunDate: lastRunDate ?? this.lastRunDate,
      longestStreak: longestStreak ?? this.longestStreak,
    );
  }

  factory StreakData.initial() {
    return StreakData(currentStreak: 0, longestStreak: 0);
  }
}
