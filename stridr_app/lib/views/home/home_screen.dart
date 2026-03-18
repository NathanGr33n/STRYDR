import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../providers/providers.dart';
import '../widgets/neon_progress_ring.dart';
import '../widgets/streak_flame.dart';
import '../widgets/suggestion_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalState = ref.watch(weeklyGoalProvider);
    final streak = ref.watch(streakProvider);
    final suggestions = ref.watch(suggestionsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'STRIDR',
                    style: AppTheme.statNumber(fontSize: 28),
                  ),
                  IconButton(
                    icon: const Icon(Icons.insights_rounded),
                    color: AppColors.neonPurple,
                    onPressed: () => context.push('/insights'),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Weekly Goal Ring
              GestureDetector(
                onTap: () => context.push('/goal'),
                child: NeonProgressRing(
                  progress: goalState.progress,
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
                        'of ${goalState.goal.targetMiles.toStringAsFixed(0)} mi',
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 14,
                        ),
                      ),
                      if (goalState.goalReached)
                        const Padding(
                          padding: EdgeInsets.only(top: 4),
                          child: Text(
                            'GOAL REACHED!',
                            style: TextStyle(
                              color: AppColors.neonPurpleLight,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'WEEKLY GOAL',
                style: AppTheme.statLabel(),
              ),
              const SizedBox(height: 32),

              // Streak
              StreakFlame(streakCount: streak.currentStreak),
              const SizedBox(height: 4),
              Text(
                'STREAK',
                style: AppTheme.statLabel(),
              ),
              const SizedBox(height: 32),

              // Suggestions
              ...suggestions.asMap().entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: SuggestionCard(
                    suggestion: entry.value,
                    onDismiss: () {
                      ref.read(suggestionsProvider.notifier).dismiss(entry.key);
                    },
                  ),
                );
              }),

              const SizedBox(height: 24),

              // Start Run Button
              SizedBox(
                width: double.infinity,
                height: 64,
                child: ElevatedButton(
                  onPressed: () => context.push('/run'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.neonPurple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.play_arrow_rounded, size: 28),
                      const SizedBox(width: 8),
                      Text(
                        'START RUN',
                        style: AppTheme.statNumber(fontSize: 18),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Recent Run Quick Stats
              _buildRecentRunSection(ref),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentRunSection(WidgetRef ref) {
    final runs = ref.watch(runHistoryProvider);
    if (runs.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Text(
            'No runs yet. Start your first run!',
            style: TextStyle(color: AppColors.textMuted, fontSize: 14),
          ),
        ),
      );
    }

    final lastRun = runs.first;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'LAST RUN',
            style: AppTheme.statLabel(),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _miniStat(
                'Distance',
                '${Formatters.distanceMiles(lastRun.distanceMeters)} mi',
              ),
              _miniStat(
                'Time',
                Formatters.duration(lastRun.duration),
              ),
              _miniStat(
                'Pace',
                '${Formatters.pace(lastRun.avgPaceSecondsPerMile)} /mi',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: AppTheme.statNumber(fontSize: 16),
        ),
        const SizedBox(height: 2),
        Text(
          label.toUpperCase(),
          style: AppTheme.statLabel(),
        ),
      ],
    );
  }
}
