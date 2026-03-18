import 'package:hive/hive.dart';

part 'run_record.g.dart';

@HiveType(typeId: 0)
class RunRecord extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime startTime;

  @HiveField(2)
  final DateTime endTime;

  @HiveField(3)
  final double distanceMeters;

  @HiveField(4)
  final int durationSeconds;

  @HiveField(5)
  final double avgPaceSecondsPerMile;

  /// Stored as flat list: [lat1, lng1, lat2, lng2, ...]
  @HiveField(6)
  final List<double> routePoints;

  RunRecord({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.distanceMeters,
    required this.durationSeconds,
    required this.avgPaceSecondsPerMile,
    required this.routePoints,
  });

  double get distanceMiles => distanceMeters / 1609.344;
  Duration get duration => Duration(seconds: durationSeconds);
}
