import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/streak/streak_bloc.dart';
import '../blocs/streak/streak_event.dart';
import '../blocs/streak/streak_state.dart';
import '../theme/app_theme.dart';
import '../widgets/design_system.dart';

class StreakPage extends StatefulWidget {
  const StreakPage({super.key});

  @override
  State<StreakPage> createState() => _StreakPageState();
}

class _StreakPageState extends State<StreakPage> {
  @override
  void initState() {
    super.initState();
    context.read<StreakBloc>().add(const StreakLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StreakBloc, StreakState>(
      builder: (context, state) {
        if (state is StreakInitial || state is StreakLoading) {
          return const Center(child: CircularProgressIndicator(color: AppColors.violet, strokeWidth: 2));
        }
        if (state is StreakError) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, color: AppColors.subtle, size: 32),
                const SizedBox(height: 8),
                Text(state.message, style: const TextStyle(color: AppColors.subtle, fontSize: 13)),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () => context.read<StreakBloc>().add(const StreakLoadRequested()),
                  child: const Text('Retry', style: TextStyle(color: AppColors.violetBright, fontSize: 13)),
                ),
              ],
            ),
          );
        }
        if (state is StreakLoaded) {
          return _StreakContent(state: state);
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _StreakContent extends StatelessWidget {
  const _StreakContent({required this.state});
  final StreakLoaded state;

  Color _heatColor(int v) {
    if (v == 0) return AppColors.surface2;
    if (v <= 1) return const Color(0x406B6CF6);
    if (v <= 3) return const Color(0x808B6CF6);
    if (v <= 5) return const Color(0xBF8B6CF6);
    return AppColors.violetBright;
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final heatmap = state.heatmapData;

    // Build 28-day grid (4 weeks, Mon–Sun)
    final days = List.generate(28, (i) => today.subtract(Duration(days: 27 - i)));
    final isOnFire = state.currentStreak >= 7;

    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Padding(
              padding: EdgeInsets.fromLTRB(22, 24, 22, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Streaks', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: AppColors.text, letterSpacing: -0.6)),
                  SizedBox(height: 2),
                  Text('Keep the rhythm going.', style: TextStyle(fontSize: 12.5, color: AppColors.muted)),
                ],
              ),
            ),

            // Hero streak card
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 14, 22, 0),
              child: Container(
                padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.border),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0x298B6CF6), AppColors.surface],
                  ),
                ),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('CURRENT STREAK', style: TextStyle(fontSize: 11, color: AppColors.muted, letterSpacing: 0.5, fontWeight: FontWeight.w500)),
                        const SizedBox(height: 2),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            displayNumber('${state.currentStreak}', size: 44, color: AppColors.violetBright),
                            const SizedBox(width: 6),
                            const Text('days', style: TextStyle(fontSize: 13, color: AppColors.muted)),
                          ],
                        ),
                      ],
                    ),
                    const Spacer(),
                    if (isOnFire)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0x1FFF8A6B),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: const Color(0x33FF8A6B)),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.local_fire_department, size: 14, color: AppColors.hot),
                            SizedBox(width: 6),
                            Text('On fire', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.hot)),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Heatmap
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 14, 22, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionLabel('Last 28 days'),
                  const SizedBox(height: 8),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      crossAxisSpacing: 5,
                      mainAxisSpacing: 5,
                    ),
                    itemCount: 28,
                    itemBuilder: (_, i) {
                      final day = days[i];
                      final key = DateTime(day.year, day.month, day.day);
                      final v = heatmap[key] ?? 0;
                      final isToday = day.day == today.day && day.month == today.month;
                      return Container(
                        decoration: BoxDecoration(
                          color: _heatColor(v),
                          borderRadius: BorderRadius.circular(5),
                          border: isToday ? Border.all(color: AppColors.violetBright, width: 1.5) : null,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Weekly stats grid
            const Padding(
              padding: EdgeInsets.fromLTRB(22, 14, 22, 6),
              child: Text('Beat stats this week', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.text)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 0, 22, 24),
              child: _WeeklyStatsGrid(state: state),
            ),
          ],
        ),
      ),
    );
  }
}

class _WeeklyStatsGrid extends StatelessWidget {
  const _WeeklyStatsGrid({required this.state});
  final StreakLoaded state;

  @override
  Widget build(BuildContext context) {
    final totalDone = state.weeklyStats.days.fold(0, (s, d) => s + d.tasksDone);
    final daysWithActivity = state.weeklyStats.days.where((d) => d.tasksDone > 0).length;

    final cells = [
      _StatCell(value: '$daysWithActivity', unit: '/7', label: 'days active'),
      _StatCell(value: '$totalDone', unit: '', label: 'tasks done'),
      _StatCell(value: '${state.currentStreak}', unit: '', label: 'day streak'),
      _StatCell(value: '${state.longestStreak}', unit: '', label: 'best streak'),
    ];

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 9,
      mainAxisSpacing: 9,
      childAspectRatio: 1.4,
      children: cells,
    );
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell({required this.value, required this.unit, required this.label});
  final String value;
  final String unit;
  final String label;

  @override
  Widget build(BuildContext context) {
    return RhythmCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              displayNumber(value, size: 32),
              if (unit.isNotEmpty)
                Text(unit, style: const TextStyle(fontSize: 22, color: AppColors.subtle)),
            ],
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.subtle)),
        ],
      ),
    );
  }
}
