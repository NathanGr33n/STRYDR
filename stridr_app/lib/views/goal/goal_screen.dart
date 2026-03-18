import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/providers.dart';
import '../widgets/neon_progress_ring.dart';

class GoalScreen extends ConsumerStatefulWidget {
  const GoalScreen({super.key});

  @override
  ConsumerState<GoalScreen> createState() => _GoalScreenState();
}

class _GoalScreenState extends ConsumerState<GoalScreen> {
  late double _targetMiles;

  @override
  void initState() {
    super.initState();
    _targetMiles = ref.read(weeklyGoalProvider).goal.targetMiles;
  }

  @override
  Widget build(BuildContext context) {
    final goalState = ref.watch(weeklyGoalProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text('WEEKLY GOAL', style: AppTheme.statLabel()),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Spacer(),

            // Preview ring with new target
            NeonProgressRing(
              progress: _targetMiles > 0
                  ? (goalState.currentMiles / _targetMiles).clamp(0.0, 1.0)
                  : 0,
              size: 200,
              strokeWidth: 12,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    goalState.currentMiles.toStringAsFixed(1),
                    style: AppTheme.statNumber(fontSize: 32),
                  ),
                  Text(
                    'of ${_targetMiles.toStringAsFixed(0)} mi',
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),

            // Slider
            Text(
              '${_targetMiles.toStringAsFixed(0)} miles',
              style: AppTheme.statNumber(fontSize: 24),
            ),
            const SizedBox(height: 16),
            SliderTheme(
              data: SliderThemeData(
                activeTrackColor: AppColors.neonPurple,
                inactiveTrackColor: AppColors.surfaceLight,
                thumbColor: AppColors.neonPurpleLight,
                overlayColor: AppColors.neonPurpleDim,
                trackHeight: 6,
                thumbShape: const RoundSliderThumbShape(
                  enabledThumbRadius: 14,
                ),
              ),
              child: Slider(
                value: _targetMiles,
                min: AppConstants.minWeeklyGoalMiles,
                max: AppConstants.maxWeeklyGoalMiles,
                divisions: 99,
                onChanged: (value) {
                  setState(() => _targetMiles = value);
                  HapticFeedback.selectionClick();
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${AppConstants.minWeeklyGoalMiles.toInt()} mi',
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                  ),
                ),
                Text(
                  '${AppConstants.maxWeeklyGoalMiles.toInt()} mi',
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),

            const Spacer(),

            // Save button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () async {
                  await ref
                      .read(weeklyGoalProvider.notifier)
                      .updateTarget(_targetMiles);
                  HapticFeedback.mediumImpact();
                  if (context.mounted) context.pop();
                },
                child: const Text('SAVE GOAL'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
