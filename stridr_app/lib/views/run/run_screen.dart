import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../providers/providers.dart';
import '../../services/run_tracking_service.dart';
import '../widgets/stat_tile.dart';

class RunScreen extends ConsumerStatefulWidget {
  const RunScreen({super.key});

  @override
  ConsumerState<RunScreen> createState() => _RunScreenState();
}

class _RunScreenState extends ConsumerState<RunScreen> {
  final MapController _mapController = MapController();
  DateTime? _startTime;
  bool _hasStarted = false;

  @override
  void initState() {
    super.initState();
    _initRun();
  }

  Future<void> _initRun() async {
    final service = ref.read(runTrackingServiceProvider);
    final hasPermission = await service.requestPermissions();
    if (!hasPermission && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location permission required to track runs.'),
          backgroundColor: AppColors.error,
        ),
      );
      context.pop();
      return;
    }
    _startTime = DateTime.now();
    await service.startRun();
    setState(() => _hasStarted = true);
  }

  void _onPause() {
    ref.read(runTrackingServiceProvider).pauseRun();
    HapticFeedback.mediumImpact();
  }

  void _onResume() {
    ref.read(runTrackingServiceProvider).resumeRun();
    HapticFeedback.lightImpact();
  }

  Future<void> _onEnd() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('End Run?', style: TextStyle(color: AppColors.textPrimary)),
        content: const Text(
          'Are you sure you want to end this run?',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('End Run', style: TextStyle(color: AppColors.neonPurple)),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final service = ref.read(runTrackingServiceProvider);
    final finalState = service.endRun();

    HapticFeedback.heavyImpact();

    // Save the run
    await ref.read(runHistoryProvider.notifier).saveRun(
          runState: finalState,
          startTime: _startTime ?? DateTime.now(),
        );

    // Update streak
    await ref.read(streakProvider.notifier).recordRun(DateTime.now());

    // Refresh goal & suggestions
    ref.read(weeklyGoalProvider.notifier).refresh();
    ref.read(suggestionsProvider.notifier).refresh();

    if (mounted) {
      context.go('/summary', extra: finalState);
    }
  }

  @override
  Widget build(BuildContext context) {
    final runState = ref.watch(runStateProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: runState.when(
        data: (state) => _buildRunUI(state),
        loading: () => _buildRunUI(const RunState()),
        error: (_, __) => _buildRunUI(const RunState()),
      ),
    );
  }

  Widget _buildRunUI(RunState state) {
    return Stack(
      children: [
        // Map
        _buildMap(state),

        // Stats overlay at bottom
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: _buildStatsPanel(state),
        ),
      ],
    );
  }

  Widget _buildMap(RunState state) {
    final center = state.currentPosition ?? const LatLng(37.7749, -122.4194);

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: center,
        initialZoom: 16,
      ),
      children: [
        // Dark map tiles
        TileLayer(
          urlTemplate: 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
          subdomains: const ['a', 'b', 'c', 'd'],
          userAgentPackageName: 'dev.stryder.stryder',
        ),
        // Neon route polyline
        if (state.route.length > 1)
          PolylineLayer(
            polylines: [
              // Glow effect
              Polyline(
                points: state.route,
                strokeWidth: 8,
                color: AppColors.neonPurpleGlow,
              ),
              // Main line
              Polyline(
                points: state.route,
                strokeWidth: 4,
                color: AppColors.neonPurple,
              ),
            ],
          ),
        // Current position marker
        if (state.currentPosition != null)
          MarkerLayer(
            markers: [
              Marker(
                point: state.currentPosition!,
                width: 20,
                height: 20,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.neonPurple,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.neonPurpleGlow,
                        blurRadius: 12,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildStatsPanel(RunState state) {
    final isRunning = state.status == RunStatus.running;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 48),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.background.withValues(alpha: 0.0),
            AppColors.background.withValues(alpha: 0.8),
            AppColors.background,
          ],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Stats row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              StatTile(
                label: 'Distance',
                value: Formatters.distanceMiles(state.distanceMeters),
                unit: 'mi',
                fontSize: 28,
              ),
              StatTile(
                label: 'Time',
                value: Formatters.duration(state.elapsed),
                fontSize: 28,
              ),
              StatTile(
                label: 'Pace',
                value: Formatters.pace(state.currentPaceSecondsPerMile),
                unit: '/mi',
                fontSize: 28,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_hasStarted) ...[
                // Pause / Resume
                _controlButton(
                  icon: isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  label: isRunning ? 'Pause' : 'Resume',
                  onTap: isRunning ? _onPause : _onResume,
                  isPrimary: true,
                ),
                const SizedBox(width: 32),
                // End
                _controlButton(
                  icon: Icons.stop_rounded,
                  label: 'End',
                  onTap: _onEnd,
                  isPrimary: false,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _controlButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isPrimary,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: isPrimary ? AppColors.neonPurple : AppColors.surfaceLight,
              shape: BoxShape.circle,
              boxShadow: isPrimary
                  ? [
                      BoxShadow(
                        color: AppColors.neonPurpleGlow,
                        blurRadius: 16,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
            child: Icon(icon, color: AppColors.textPrimary, size: 32),
          ),
          const SizedBox(height: 6),
          Text(
            label.toUpperCase(),
            style: AppTheme.statLabel(),
          ),
        ],
      ),
    );
  }
}
