import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/design_system.dart';

class EditNotificationsScreen extends StatefulWidget {
  const EditNotificationsScreen({super.key});

  @override
  State<EditNotificationsScreen> createState() => _EditNotificationsScreenState();
}

class _EditNotificationsScreenState extends State<EditNotificationsScreen> {
  bool beatReminders = true;
  bool midBeatNudge = true;
  bool beatEnding = false;
  bool dailyRecap = true;
  bool streakAtRisk = true;
  bool muteAll = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            BackNavHeader(
              title: 'Notifications',
              actionLabel: 'Done',
              action: () => Navigator.of(context).pop(),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 40),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(28, 0, 22, 6),
                      child: SectionLabel('Beats'),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 22),
                      child: RhythmCard(
                        child: Column(
                          children: [
                            _ToggleRow(
                              title: 'Beat reminders',
                              sub: '5 min before each beat starts',
                              value: beatReminders,
                              onChanged: (v) => setState(() => beatReminders = v),
                            ),
                            rhythmDivider,
                            _ToggleRow(
                              title: 'Mid-beat nudge',
                              sub: 'Halfway check-in for long beats',
                              value: midBeatNudge,
                              onChanged: (v) => setState(() => midBeatNudge = v),
                            ),
                            rhythmDivider,
                            _ToggleRow(
                              title: 'Beat ending',
                              sub: 'When a beat is about to end',
                              value: beatEnding,
                              onChanged: (v) => setState(() => beatEnding = v),
                              isLast: true,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const Padding(
                      padding: EdgeInsets.fromLTRB(28, 14, 22, 6),
                      child: SectionLabel('Streaks'),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 22),
                      child: RhythmCard(
                        child: Column(
                          children: [
                            _ToggleRow(
                              title: 'Daily recap',
                              sub: 'Tasks done & streak at 9:00 PM',
                              value: dailyRecap,
                              onChanged: (v) => setState(() => dailyRecap = v),
                            ),
                            rhythmDivider,
                            _ToggleRow(
                              title: 'Streak at risk',
                              sub: "If you haven't logged a beat by 8 PM",
                              value: streakAtRisk,
                              onChanged: (v) => setState(() => streakAtRisk = v),
                              isLast: true,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const Padding(
                      padding: EdgeInsets.fromLTRB(28, 14, 22, 6),
                      child: SectionLabel('Quiet hours'),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 22),
                      child: RhythmCard(
                        child: Column(
                          children: [
                            _ToggleRow(
                              title: 'Mute all notifications',
                              value: muteAll,
                              onChanged: (v) => setState(() => muteAll = v),
                            ),
                            rhythmDivider,
                            _TimeRow(label: 'From', value: '10:00 PM'),
                            rhythmDivider,
                            _TimeRow(label: 'To', value: '7:00 AM', isLast: true),
                          ],
                        ),
                      ),
                    ),

                    const Padding(
                      padding: EdgeInsets.fromLTRB(28, 14, 28, 8),
                      child: Text(
                        'Rhythm never sends notifications during an active focus session.',
                        style: TextStyle(fontSize: 11, color: AppColors.subtle, height: 1.5),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({required this.title, this.sub, required this.value, required this.onChanged, this.isLast = false});
  final String title;
  final String? sub;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w500, color: AppColors.text)),
                if (sub != null) ...[
                  const SizedBox(height: 2),
                  Text(sub!, style: const TextStyle(fontSize: 11.5, color: AppColors.subtle, height: 1.35)),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          RhythmToggle(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _TimeRow extends StatelessWidget {
  const _TimeRow({required this.label, required this.value, this.isLast = false});
  final String label;
  final String value;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Row(
        children: [
          Expanded(child: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.text))),
          Text(value, style: const TextStyle(fontSize: 12.5, color: AppColors.muted)),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right, size: 14, color: AppColors.subtle),
        ],
      ),
    );
  }
}
