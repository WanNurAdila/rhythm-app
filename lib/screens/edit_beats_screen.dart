import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/beat/beat_bloc.dart';
import '../blocs/beat/beat_event.dart';
import '../blocs/beat/beat_state.dart';
import '../models/beat.dart';
import '../theme/app_theme.dart';
import '../widgets/design_system.dart';

class EditBeatsScreen extends StatelessWidget {
  const EditBeatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            BackNavHeader(
              title: 'My beats',
              actionLabel: 'Done',
              action: () => Navigator.of(context).pop(),
            ),
            Expanded(
              child: BlocBuilder<BeatBloc, BeatState>(
                builder: (context, state) {
                  if (state is BeatLoading || state is BeatInitial) {
                    return const Center(child: CircularProgressIndicator(color: AppColors.violet, strokeWidth: 2));
                  }
                  if (state is BeatLoaded) {
                    return _BeatEditList(beats: state.beats);
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BeatEditList extends StatelessWidget {
  const _BeatEditList({required this.beats});
  final List<Beat> beats;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 40, 22, 0),
            child: RhythmCard(
              child: Column(
                children: beats.asMap().entries.map((entry) {
                  final beat = entry.value;
                  final isLast = entry.key == beats.length - 1;
                  return _BeatEditRow(beat: beat, isLast: isLast);
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 0, 22, 0),
            child: Opacity(
              opacity: 0.5,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.surface2,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderStrong, style: BorderStyle.solid),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.add, size: 12, color: AppColors.subtle),
                    const SizedBox(width: 6),
                    const Text('Add custom beat', style: TextStyle(color: AppColors.subtle, fontSize: 13, fontWeight: FontWeight.w600)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.fromLTRB(6, 1, 6, 1),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Text('Coming soon', style: TextStyle(fontSize: 10, color: AppColors.subtle, fontWeight: FontWeight.w500)),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 28),
            child: Text(
              'Inactive beats are saved but hidden from your home screen until you turn them back on.',
              style: TextStyle(fontSize: 11, color: AppColors.subtle, height: 1.5),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _BeatEditRow extends StatelessWidget {
  const _BeatEditRow({required this.beat, required this.isLast});
  final Beat beat;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final info = BeatInfo.forType(beat.type);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(color: info.bgColor, borderRadius: BorderRadius.circular(8)),
                    child: Center(
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(color: info.color, borderRadius: BorderRadius.circular(4)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(beat.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.text)),
                  ),
                  RhythmToggle(
                    value: beat.isActive,
                    onChanged: (v) => context.read<BeatBloc>().add(BeatToggleRequested(id: beat.id, isActive: v)),
                  ),
                ],
              ),
              if (beat.isActive && beat.startTime != null) ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: _TimeField(label: 'STARTS', value: beat.startTime ?? '–')),
                    const SizedBox(width: 8),
                    Expanded(child: _TimeField(label: 'ENDS', value: _endTime(beat))),
                  ],
                ),
              ],
            ],
          ),
        ),
        if (!isLast) const Divider(height: 1, thickness: 1, color: AppColors.border, indent: 14, endIndent: 14),
      ],
    );
  }

  String _endTime(Beat beat) {
    if (beat.startTime == null || beat.durationMinutes == null) return '–';
    final parts = beat.startTime!.split(':');
    if (parts.length < 2) return '–';
    final h = int.tryParse(parts[0]) ?? 0;
    final m = int.tryParse(parts[1]) ?? 0;
    final total = h * 60 + m + beat.durationMinutes!;
    final endH = (total ~/ 60) % 24;
    final endM = total % 60;
    final p = endH < 12 ? 'AM' : 'PM';
    final dH = endH % 12 == 0 ? 12 : endH % 12;
    return '$dH:${endM.toString().padLeft(2, '0')} $p';
  }
}

class _TimeField extends StatelessWidget {
  const _TimeField({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
      decoration: BoxDecoration(
        color: AppColors.bg2,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Opacity(
        opacity: 0.7,
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 10, color: AppColors.subtle, letterSpacing: 0.3)),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.muted)),
                    const SizedBox(width: 6),
                    const Icon(Icons.lock_outline, size: 10, color: AppColors.subtle),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
