import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/beat/beat_bloc.dart';
import '../blocs/beat/beat_event.dart';
import '../blocs/beat/beat_state.dart';
import '../models/beat.dart';
import '../theme/app_theme.dart';
import '../widgets/design_system.dart';
import 'beat_form_sheet.dart';

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
                    return const Center(
                        child: CircularProgressIndicator(
                            color: AppColors.violet, strokeWidth: 2));
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
    final activeBeats = beats.where((b) => b.isActive).toList()..sort(_byStartTime);
    final inactiveBeats = beats.where((b) => !b.isActive).toList()..sort(_byStartTime);
    final nextSortOrder =
        beats.map((b) => b.sortOrder).fold(0, (a, b) => a > b ? a : b) + 1;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Overlap disclaimer banner
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 8, 22, 0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.violetSoft,
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Icon(Icons.info_outline, size: 14, color: AppColors.violetBright),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Active beats can't have overlapping time slots. Adjust the times of any beats you want running at once.",
                      style: TextStyle(fontSize: 11, color: AppColors.muted, height: 1.45),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Active section
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 32, 22, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 0, 0, 8),
                  child: Row(
                    children: [
                      const Text(
                        'ACTIVE',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.6,
                          color: AppColors.subtle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${activeBeats.length}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.subtle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Divider(height: 1, thickness: 1, color: AppColors.border),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => BeatFormSheet.showCreate(
                          context,
                          beatBloc: context.read<BeatBloc>(),
                          sortOrder: nextSortOrder,
                        ),
                        child: Row(
                          children: const [
                            Icon(Icons.add, size: 11, color: AppColors.violetBright),
                            SizedBox(width: 4),
                            Text(
                              'Add beat',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.violetBright,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (activeBeats.isNotEmpty)
                  RhythmCard(
                    child: Column(
                      children: activeBeats.asMap().entries.map((entry) {
                        final beat = entry.value;
                        final isLast = entry.key == activeBeats.length - 1;
                        return _BeatEditRow(beat: beat, isLast: isLast);
                      }).toList(),
                    ),
                  )
                else
                  const Padding(
                    padding: EdgeInsets.fromLTRB(4, 0, 0, 0),
                    child: Text(
                      'No active beats yet.',
                      style: TextStyle(fontSize: 12, color: AppColors.subtle),
                    ),
                  ),
              ],
            ),
          ),

          // Inactive section
          if (inactiveBeats.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 20, 22, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(4, 0, 0, 8),
                    child: Row(
                      children: [
                        const Text(
                          'INACTIVE',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.6,
                            color: AppColors.subtle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${inactiveBeats.length}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.subtle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Divider(height: 1, thickness: 1, color: AppColors.border),
                        ),
                      ],
                    ),
                  ),
                  RhythmCard(
                    child: Column(
                      children: inactiveBeats.asMap().entries.map((entry) {
                        final beat = entry.value;
                        final isLast = entry.key == inactiveBeats.length - 1;
                        return _BeatEditRow(beat: beat, isLast: isLast);
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),

          const Padding(
            padding: EdgeInsets.fromLTRB(28, 20, 28, 22),
            child: Text(
              'Inactive beats are saved but hidden from your home screen until you turn them back on.',
              style: TextStyle(fontSize: 11, color: AppColors.subtle, height: 1.5),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class _BeatEditRow extends StatelessWidget {
  const _BeatEditRow({required this.beat, required this.isLast});
  final Beat beat;
  final bool isLast;

  bool get _isCustom =>
      beat.type == BeatType.custom && !beat.id.startsWith('preset_');

  @override
  Widget build(BuildContext context) {
    final info = BeatInfo.forBeat(beat);

    return Opacity(
      opacity: beat.isActive ? 1.0 : 0.85,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            child: Column(
              children: [
                Row(
                  children: [
                    // Color icon — tappable for custom beats to open edit sheet
                    GestureDetector(
                      onTap: _isCustom
                          ? () => BeatFormSheet.showEdit(
                                context,
                                beatBloc: context.read<BeatBloc>(),
                                beat: beat,
                              )
                          : null,
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                            color: info.bgColor,
                            borderRadius: BorderRadius.circular(8)),
                        child: Center(
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                                color: info.color,
                                borderRadius: BorderRadius.circular(4)),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Name + Custom badge — tappable for custom beats
                    Expanded(
                      child: GestureDetector(
                        onTap: _isCustom
                            ? () => BeatFormSheet.showEdit(
                                  context,
                                  beatBloc: context.read<BeatBloc>(),
                                  beat: beat,
                                )
                            : null,
                        child: Row(
                          children: [
                            Text(
                              beat.name,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.text,
                              ),
                            ),
                            if (_isCustom) ...[
                              const SizedBox(width: 7),
                              Container(
                                padding: const EdgeInsets.fromLTRB(6, 2, 6, 2),
                                decoration: BoxDecoration(
                                  color: AppColors.violetSoft,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: const Text(
                                  'CUSTOM',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.4,
                                    color: AppColors.violetBright,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),

                    // Pencil icon (custom only) + toggle
                    if (_isCustom) ...[
                      GestureDetector(
                        onTap: () => BeatFormSheet.showEdit(
                          context,
                          beatBloc: context.read<BeatBloc>(),
                          beat: beat,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
                          child: Icon(Icons.edit_outlined,
                              size: 14, color: AppColors.subtle),
                        ),
                      ),
                    ],
                    RhythmToggle(
                      value: beat.isActive,
                      onChanged: (v) => _handleToggle(context, v),
                    ),
                  ],
                ),

                // Time fields — always shown when times exist, dimmed when inactive
                if (beat.startTime != null || beat.endTime != null) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                          child: _TimeDisplay(
                              label: 'STARTS',
                              value: _fmtTime(beat.startTime),
                              dim: !beat.isActive)),
                      const SizedBox(width: 8),
                      Expanded(
                          child: _TimeDisplay(
                              label: 'ENDS',
                              value: _fmtTime(beat.endTime),
                              dim: !beat.isActive)),
                    ],
                  ),
                ],
              ],
            ),
          ),
          if (!isLast)
            const Divider(
                height: 1,
                thickness: 1,
                color: AppColors.border,
                indent: 14,
                endIndent: 14),
        ],
      ),
    );
  }

  void _handleToggle(BuildContext context, bool v) async {
    if (v) {
      final beatState = context.read<BeatBloc>().state;
      if (beatState is BeatLoaded) {
        final conflicts = beatState.beats
            .where((b) => b.isActive && b.id != beat.id && _beatsOverlap(beat, b))
            .toList();
        if (conflicts.isNotEmpty) {
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (_) => _OverlapDialog(newBeat: beat, conflicts: conflicts),
          );
          if (confirmed != true) return;
          if (!context.mounted) return;
          for (final c in conflicts) {
            context.read<BeatBloc>().add(BeatToggleRequested(id: c.id, isActive: false));
          }
        }
      }
    }
    if (!context.mounted) return;
    context.read<BeatBloc>().add(BeatToggleRequested(id: beat.id, isActive: v));
  }
}

int _byStartTime(Beat a, Beat b) {
  final aMin = a.startTime != null ? _timeToMinutes(a.startTime!) : 9999;
  final bMin = b.startTime != null ? _timeToMinutes(b.startTime!) : 9999;
  return aMin.compareTo(bMin);
}

int _timeToMinutes(String time) {
  final parts = time.split(':');
  if (parts.length < 2) return 0;
  return (int.tryParse(parts[0]) ?? 0) * 60 + (int.tryParse(parts[1]) ?? 0);
}

bool _beatsOverlap(Beat a, Beat b) {
  final aStart = a.startTime;
  final bStart = b.startTime;
  if (aStart == null || bStart == null) return false;
  final aStartMin = _timeToMinutes(aStart);
  final bStartMin = _timeToMinutes(bStart);
  final int aEndMin;
  if (a.endTime != null) {
    aEndMin = _timeToMinutes(a.endTime!);
  } else if (a.durationMinutes != null) {
    aEndMin = aStartMin + a.durationMinutes!;
  } else {
    return false;
  }
  final int bEndMin;
  if (b.endTime != null) {
    bEndMin = _timeToMinutes(b.endTime!);
  } else if (b.durationMinutes != null) {
    bEndMin = bStartMin + b.durationMinutes!;
  } else {
    return false;
  }
  return aStartMin < bEndMin && bStartMin < aEndMin;
}

class _OverlapDialog extends StatelessWidget {
  const _OverlapDialog({required this.newBeat, required this.conflicts});
  final Beat newBeat;
  final List<Beat> conflicts;

  @override
  Widget build(BuildContext context) {
    final conflictNames = conflicts.map((b) => b.name).join(', ');
    return AlertDialog(
      backgroundColor: AppColors.bg2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text(
        'Time conflict',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.text),
      ),
      content: Text(
        '${newBeat.name} overlaps with $conflictNames. Activating it will deactivate the conflicting beat${conflicts.length > 1 ? 's' : ''}.',
        style: const TextStyle(fontSize: 13, color: AppColors.muted, height: 1.5),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel', style: TextStyle(color: AppColors.subtle)),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Replace', style: TextStyle(color: AppColors.violetBright, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }
}

class _TimeDisplay extends StatelessWidget {
  const _TimeDisplay({required this.label, required this.value, this.dim = false});
  final String label;
  final String value;
  final bool dim;

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
        opacity: dim ? 0.5 : 0.7,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.subtle,
                    letterSpacing: 0.3)),
            const SizedBox(height: 2),
            Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.muted),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.lock_outline,
                    size: 10, color: AppColors.subtle),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Formats "HH:MM:SS" or "HH:MM" → "9:00 AM" style
String _fmtTime(String? t) {
  if (t == null) return '–';
  final parts = t.split(':');
  if (parts.length >= 2) {
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h != null && m != null) {
      final period = h < 12 ? 'AM' : 'PM';
      final h12 = h == 0 ? 12 : (h > 12 ? h - 12 : h);
      return '$h12:${m.toString().padLeft(2, '0')} $period';
    }
  }
  return t;
}
