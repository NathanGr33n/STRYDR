import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../models/run_record.dart';
import '../../providers/providers.dart';

class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final runs = ref.watch(runHistoryProvider);
    final streak = ref.watch(streakProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text('INSIGHTS', style: AppTheme.statLabel()),
        centerTitle: true,
      ),
      body: runs.isEmpty
          ? const Center(
              child: Text(
                'Complete some runs to see insights.',
                style: TextStyle(color: AppColors.textMuted),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Weekly mileage chart
                  _sectionTitle('WEEKLY MILEAGE'),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: _buildWeeklyMileageChart(runs),
                  ),
                  const SizedBox(height: 32),

                  // Pace trend
                  _sectionTitle('PACE TREND'),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: _buildPaceTrendChart(runs),
                  ),
                  const SizedBox(height: 32),

                  // Streak info
                  _sectionTitle('STREAK'),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _streakStat(
                          'Current',
                          '${streak.currentStreak}',
                        ),
                        Container(
                          width: 1,
                          height: 40,
                          color: AppColors.surfaceLight,
                        ),
                        _streakStat(
                          'Longest',
                          '${streak.longestStreak}',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Run history list
                  _sectionTitle('RECENT RUNS'),
                  const SizedBox(height: 16),
                  ...runs.take(10).map((run) => _runHistoryTile(run)),
                ],
              ),
            ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: AppTheme.statLabel(),
    );
  }

  Widget _buildWeeklyMileageChart(List<RunRecord> runs) {
    // Group runs by week (last 8 weeks)
    final now = DateTime.now();
    final weekData = <int, double>{};

    for (int i = 0; i < 8; i++) {
      weekData[i] = 0;
    }

    for (final run in runs) {
      final weeksAgo = now.difference(run.startTime).inDays ~/ 7;
      if (weeksAgo < 8) {
        weekData[weeksAgo] = (weekData[weeksAgo] ?? 0) + run.distanceMiles;
      }
    }

    final maxY = weekData.values.fold<double>(0, (a, b) => a > b ? a : b);

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY > 0 ? maxY * 1.2 : 10,
        barTouchData: BarTouchData(enabled: false),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final weeksAgo = 7 - value.toInt();
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    weeksAgo == 0 ? 'Now' : '${weeksAgo}w',
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 10,
                    ),
                  ),
                );
              },
            ),
          ),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: false),
        barGroups: List.generate(8, (i) {
          final weeksAgo = 7 - i;
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: weekData[weeksAgo] ?? 0,
                color: AppColors.neonPurple,
                width: 20,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                backDrawRodData: BackgroundBarChartRodData(
                  show: true,
                  toY: maxY > 0 ? maxY * 1.2 : 10,
                  color: AppColors.surfaceLight,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildPaceTrendChart(List<RunRecord> runs) {
    final recentRuns = runs.take(15).toList().reversed.toList();
    if (recentRuns.length < 2) {
      return const Center(
        child: Text(
          'Need at least 2 runs for pace trend.',
          style: TextStyle(color: AppColors.textMuted),
        ),
      );
    }

    final spots = recentRuns.asMap().entries.map((entry) {
      final paceMinutes = entry.value.avgPaceSecondsPerMile / 60;
      return FlSpot(entry.key.toDouble(), paceMinutes);
    }).toList();

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 1,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: AppColors.surfaceLight,
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toInt()}\'',
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 10),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: AppColors.neonPurple,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: AppColors.neonPurpleLight,
                  strokeWidth: 0,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: AppColors.neonPurpleDim,
            ),
          ),
        ],
        lineTouchData: const LineTouchData(enabled: false),
      ),
    );
  }

  Widget _streakStat(String label, String value) {
    return Column(
      children: [
        Text(value, style: AppTheme.statNumber(fontSize: 28)),
        const SizedBox(height: 4),
        Text(label.toUpperCase(), style: AppTheme.statLabel()),
      ],
    );
  }

  Widget _runHistoryTile(RunRecord run) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _formatDate(run.startTime),
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${Formatters.distanceMiles(run.distanceMeters)} mi • ${Formatters.duration(run.duration)}',
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          Text(
            '${Formatters.pace(run.avgPaceSecondsPerMile)} /mi',
            style: AppTheme.statNumber(fontSize: 16),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }
}
