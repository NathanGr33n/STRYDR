import 'package:hive/hive.dart';

part 'weekly_goal.g.dart';

@HiveType(typeId: 1)
class WeeklyGoal extends HiveObject {
  @HiveField(0)
  final double targetMiles;

  @HiveField(1)
  final DateTime weekStart;

  WeeklyGoal({
    required this.targetMiles,
    required this.weekStart,
  });

  WeeklyGoal copyWith({
    double? targetMiles,
    DateTime? weekStart,
  }) {
    return WeeklyGoal(
      targetMiles: targetMiles ?? this.targetMiles,
      weekStart: weekStart ?? this.weekStart,
    );
  }
}
