import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../services/run_tracking_service.dart';
import '../widgets/stat_tile.dart';

class SummaryScreen extends StatelessWidget {
  final RunState runState;

  const SummaryScreen({super.key, required this.runState});

  @override
  Widget build(BuildContext context) {
    final isMilestone = runState.distanceMeters >= 1609.344; // At least 1 mile

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('RUN COMPLETE', style: AppTheme.statLabel()),
                  IconButton(
                    icon: const Icon(Icons.close),
                    color: AppColors.textMuted,
                    onPressed: () => context.go('/'),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Route map
              if (runState.route.length > 1)
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: SizedBox(
                    height: 250,
                    child: _buildRouteMap(),
                  ),
                ),
              const SizedBox(height: 32),

              // Key stats
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  StatTile(
                    label: 'Distance',
                    value: Formatters.distanceMiles(runState.distanceMeters),
                    unit: 'mi',
                  ),
                  StatTile(
                    label: 'Time',
                    value: Formatters.duration(runState.elapsed),
                  ),
                  StatTile(
                    label: 'Avg Pace',
                    value: Formatters.pace(runState.currentPaceSecondsPerMile),
                    unit: '/mi',
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Milestone card
              if (isMilestone) _buildMilestoneCard(),

              const SizedBox(height: 32),

              // Done button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    context.go('/');
                  },
                  child: const Text('DONE'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRouteMap() {
    final bounds = LatLngBounds.fromPoints(runState.route);

    return FlutterMap(
      options: MapOptions(
        initialCenter: bounds.center,
        initialZoom: 14,
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.none,
        ),
      ),
      children: [
        TileLayer(
          urlTemplate:
              'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
          subdomains: const ['a', 'b', 'c', 'd'],
          userAgentPackageName: 'dev.stryder.stryder',
        ),
        PolylineLayer(
          polylines: [
            Polyline(
              points: runState.route,
              strokeWidth: 6,
              color: AppColors.neonPurpleGlow,
            ),
            Polyline(
              points: runState.route,
              strokeWidth: 3,
              color: AppColors.neonPurple,
            ),
          ],
        ),
        // Start marker
        MarkerLayer(
          markers: [
            Marker(
              point: runState.route.first,
              width: 14,
              height: 14,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
            // End marker
            Marker(
              point: runState.route.last,
              width: 14,
              height: 14,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.neonPurple,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMilestoneCard() {
    final miles = Formatters.metersToMiles(runState.distanceMeters);
    String milestoneText;
    if (miles >= 13.1) {
      milestoneText = 'Half Marathon!';
    } else if (miles >= 6.2) {
      milestoneText = '10K Run!';
    } else if (miles >= 3.1) {
      milestoneText = '5K Run!';
    } else {
      milestoneText = 'Great Run!';
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutBack,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.neonPurple.withValues(alpha: 0.2),
            AppColors.neonPurpleLight.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.neonPurpleDim),
      ),
      child: Column(
        children: [
          const Text('🎉', style: TextStyle(fontSize: 32)),
          const SizedBox(height: 8),
          Text(
            milestoneText,
            style: const TextStyle(
              color: AppColors.neonPurpleLight,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${Formatters.distanceMiles(runState.distanceMeters)} miles in ${Formatters.duration(runState.elapsed)}',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
