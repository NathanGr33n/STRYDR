class Formatters {
  Formatters._();

  /// Formats meters to miles string (e.g. "3.21")
  static String distanceMiles(double meters) {
    final miles = meters / 1609.344;
    return miles.toStringAsFixed(2);
  }

  /// Converts meters to miles as double
  static double metersToMiles(double meters) {
    return meters / 1609.344;
  }

  /// Converts miles to meters
  static double milesToMeters(double miles) {
    return miles * 1609.344;
  }

  /// Formats duration as HH:MM:SS or MM:SS
  static String duration(Duration d) {
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60);
    final seconds = d.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:'
          '${minutes.toString().padLeft(2, '0')}:'
          '${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  /// Formats pace as min:sec /mi (e.g. "8:32")
  /// [secondsPerMile] is the pace in seconds per mile
  static String pace(double secondsPerMile) {
    if (secondsPerMile <= 0 || secondsPerMile.isInfinite || secondsPerMile.isNaN) {
      return '--:--';
    }
    final minutes = (secondsPerMile / 60).floor();
    final seconds = (secondsPerMile % 60).floor();
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  /// Calculates pace in seconds per mile from distance (meters) and duration
  static double calculatePace(double distanceMeters, Duration elapsed) {
    if (distanceMeters <= 0 || elapsed.inSeconds <= 0) return 0;
    final miles = distanceMeters / 1609.344;
    return elapsed.inSeconds / miles;
  }
}
