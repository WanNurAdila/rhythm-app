import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/beat/beat_bloc.dart';
import '../blocs/beat/beat_event.dart';
import '../blocs/beat/beat_state.dart';
import '../models/beat.dart';
import '../theme/app_theme.dart';
import '../widgets/design_system.dart';

class BeatsPage extends StatelessWidget {
  const BeatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 24, 22, 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  'My beats',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: AppColors.text, letterSpacing: -0.6),
                ),
                const Spacer(),
              ],
            ),
          ),
          _WeekStrip(),
          const Padding(
            padding: EdgeInsets.fromLTRB(22, 0, 22, 6),
            child: Row(
              children: [
                Text("Today's beats", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.text)),
                Spacer(),
              ],
            ),
          ),
          Expanded(child: _BeatList()),
        ],
      ),
    );
  }
}

class _WeekStrip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
    final days = List.generate(7, (i) => startOfWeek.add(Duration(days: i)));
    const labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 14),
      child: Row(
        children: List.generate(7, (i) {
          final day = days[i];
          final isToday = day.day == today.day && day.month == today.month;
          final isPast = day.isBefore(today) && !isToday;
          return Expanded(
            child: Column(
              children: [
                Text(
                  labels[i],
                  style: const TextStyle(fontSize: 10, color: AppColors.subtle, letterSpacing: 0.5),
                ),
                const SizedBox(height: 6),
                Container(
                  width: 32,
                  height: 32,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isToday ? AppColors.violet : isPast ? AppColors.violetSoft : Colors.transparent,
                    border: (!isToday && !isPast) ? Border.all(color: AppColors.border) : null,
                  ),
                  child: Text(
                    '${day.day}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isToday ? FontWeight.w600 : FontWeight.w500,
                      color: isToday ? Colors.white : isPast ? AppColors.violetBright : AppColors.muted,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _BeatList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BeatBloc, BeatState>(
      builder: (context, state) {
        if (state is BeatLoading || state is BeatInitial) {
          return const Center(child: CircularProgressIndicator(color: AppColors.violet, strokeWidth: 2));
        }
        if (state is BeatError) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, color: AppColors.subtle, size: 32),
                const SizedBox(height: 8),
                Text(state.message, style: const TextStyle(color: AppColors.subtle, fontSize: 13)),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () => context.read<BeatBloc>().add(const BeatsLoadRequested()),
                  child: const Text('Retry', style: TextStyle(color: AppColors.violetBright, fontSize: 13)),
                ),
              ],
            ),
          );
        }
        if (state is BeatLoaded) {
          if (state.beats.isEmpty) {
            return const Center(
              child: Text('No beats set up yet.', style: TextStyle(color: AppColors.subtle, fontSize: 13)),
            );
          }
          final sorted = [...state.beats]..sort(_byStartTime);
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(22, 0, 22, 16),
            itemCount: sorted.length,
            separatorBuilder: (_, _) => const SizedBox(height: 9),
            itemBuilder: (_, i) => _BeatStatCard(beat: sorted[i]),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _BeatStatCard extends StatelessWidget {
  const _BeatStatCard({required this.beat});
  final Beat beat;

  @override
  Widget build(BuildContext context) {
    final info = BeatInfo.forType(beat.type);

    String? timeLabel;
    if (beat.startTime != null && beat.endTime != null) {
      timeLabel = '${beat.startTime!} – ${beat.endTime!}';
    } else if (beat.startTime != null && beat.durationMinutes != null) {
      final parts = beat.startTime!.split(':');
      if (parts.length >= 2) {
        final h = int.tryParse(parts[0]) ?? 0;
        final m = int.tryParse(parts[1]) ?? 0;
        final endH = (h * 60 + m + beat.durationMinutes!) ~/ 60;
        final endM = (h * 60 + m + beat.durationMinutes!) % 60;
        final startStr = _fmt(h, m);
        final endStr = _fmt(endH % 24, endM);
        timeLabel = '$startStr – $endStr';
      }
    }

    return RhythmCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: info.bgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: info.color,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(beat.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.text)),
                    if (timeLabel != null)
                      Text(timeLabel, style: const TextStyle(fontSize: 11.5, color: AppColors.muted)),
                  ],
                ),
              ),
              if (!beat.isActive)
                const Text('Off', style: TextStyle(fontSize: 11, color: AppColors.subtle))
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.successSoft,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text('Active', style: TextStyle(fontSize: 11, color: AppColors.success, fontWeight: FontWeight.w500)),
                ),
            ],
          ),
          if (beat.isActive) ...[
            const SizedBox(height: 10),
            Container(
              height: 3,
              decoration: BoxDecoration(
                color: AppColors.surface3,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _fmt(int h, int m) {
    final period = h < 12 ? 'AM' : 'PM';
    final displayH = h % 12 == 0 ? 12 : h % 12;
    return '$displayH:${m.toString().padLeft(2, '0')} $period';
  }
}

int _startMinutes(Beat b) {
  if (b.startTime == null) return 9999;
  final parts = b.startTime!.split(':');
  if (parts.length < 2) return 9999;
  return (int.tryParse(parts[0]) ?? 0) * 60 + (int.tryParse(parts[1]) ?? 0);
}

int _byStartTime(Beat a, Beat b) => _startMinutes(a).compareTo(_startMinutes(b));
