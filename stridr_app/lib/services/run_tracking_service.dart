import 'dart:async';
import 'dart:math';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

enum RunStatus { idle, running, paused }

class RunState {
  final RunStatus status;
  final double distanceMeters;
  final Duration elapsed;
  final double currentPaceSecondsPerMile;
  final List<LatLng> route;
  final LatLng? currentPosition;

  const RunState({
    this.status = RunStatus.idle,
    this.distanceMeters = 0,
    this.elapsed = Duration.zero,
    this.currentPaceSecondsPerMile = 0,
    this.route = const [],
    this.currentPosition,
  });

  RunState copyWith({
    RunStatus? status,
    double? distanceMeters,
    Duration? elapsed,
    double? currentPaceSecondsPerMile,
    List<LatLng>? route,
    LatLng? currentPosition,
  }) {
    return RunState(
      status: status ?? this.status,
      distanceMeters: distanceMeters ?? this.distanceMeters,
      elapsed: elapsed ?? this.elapsed,
      currentPaceSecondsPerMile:
          currentPaceSecondsPerMile ?? this.currentPaceSecondsPerMile,
      route: route ?? this.route,
      currentPosition: currentPosition ?? this.currentPosition,
    );
  }
}

class RunTrackingService {
  StreamSubscription<Position>? _positionSub;
  Timer? _timer;
  DateTime? _startTime;
  DateTime? _pauseTime;
  Duration _pausedDuration = Duration.zero;

  final _stateController = StreamController<RunState>.broadcast();
  Stream<RunState> get stateStream => _stateController.stream;

  RunState _state = const RunState();
  RunState get currentState => _state;

  Future<bool> requestPermissions() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return false;
    }
    if (permission == LocationPermission.deniedForever) return false;
    return true;
  }

  Future<void> startRun() async {
    _startTime = DateTime.now();
    _pausedDuration = Duration.zero;
    _state = RunState(
      status: RunStatus.running,
      currentPosition: _state.currentPosition,
    );
    _emit();

    _startTimer();
    _startGPS();
  }

  void pauseRun() {
    _pauseTime = DateTime.now();
    _timer?.cancel();
    _positionSub?.pause();
    _state = _state.copyWith(status: RunStatus.paused);
    _emit();
  }

  void resumeRun() {
    if (_pauseTime != null) {
      _pausedDuration += DateTime.now().difference(_pauseTime!);
      _pauseTime = null;
    }
    _startTimer();
    _positionSub?.resume();
    _state = _state.copyWith(status: RunStatus.running);
    _emit();
  }

  RunState endRun() {
    _timer?.cancel();
    _positionSub?.cancel();
    _positionSub = null;
    final finalState = _state.copyWith(status: RunStatus.idle);
    _state = const RunState();
    return finalState;
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_startTime == null) return;
      final now = DateTime.now();
      final totalElapsed = now.difference(_startTime!);
      final activeElapsed = totalElapsed - _pausedDuration;

      final pace = _calculatePace(_state.distanceMeters, activeElapsed);
      _state = _state.copyWith(
        elapsed: activeElapsed,
        currentPaceSecondsPerMile: pace,
      );
      _emit();
    });
  }

  void _startGPS() {
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5,
    );

    _positionSub = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen(_onPositionUpdate);
  }

  void _onPositionUpdate(Position position) {
    final newPoint = LatLng(position.latitude, position.longitude);
    final updatedRoute = List<LatLng>.from(_state.route)..add(newPoint);

    double totalDistance = _state.distanceMeters;
    if (_state.route.isNotEmpty) {
      final lastPoint = _state.route.last;
      totalDistance += _haversineDistance(lastPoint, newPoint);
    }

    _state = _state.copyWith(
      route: updatedRoute,
      currentPosition: newPoint,
      distanceMeters: totalDistance,
    );
    _emit();
  }

  double _calculatePace(double distanceMeters, Duration elapsed) {
    if (distanceMeters <= 0 || elapsed.inSeconds <= 0) return 0;
    final miles = distanceMeters / 1609.344;
    return elapsed.inSeconds / miles;
  }

  /// Haversine distance in meters between two LatLng points
  double _haversineDistance(LatLng a, LatLng b) {
    const earthRadius = 6371000.0; // meters
    final dLat = _toRadians(b.latitude - a.latitude);
    final dLng = _toRadians(b.longitude - a.longitude);
    final sinDLat = sin(dLat / 2);
    final sinDLng = sin(dLng / 2);
    final h = sinDLat * sinDLat +
        cos(_toRadians(a.latitude)) *
            cos(_toRadians(b.latitude)) *
            sinDLng *
            sinDLng;
    return 2 * earthRadius * asin(sqrt(h));
  }

  double _toRadians(double degrees) => degrees * pi / 180;

  void _emit() {
    _stateController.add(_state);
  }

  void dispose() {
    _timer?.cancel();
    _positionSub?.cancel();
    _stateController.close();
  }
}
