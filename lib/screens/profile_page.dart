import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../blocs/beat/beat_bloc.dart';
import '../blocs/beat/beat_state.dart';
import '../blocs/task/task_bloc.dart';
import '../blocs/task/task_state.dart';
import '../models/beat.dart';
import '../models/profile.dart' show AmbientSoundType;
import '../blocs/profile/profile_bloc.dart';
import '../blocs/profile/profile_state.dart';
import '../blocs/streak/streak_bloc.dart';
import '../blocs/streak/streak_state.dart';
import '../theme/app_theme.dart';
import '../widgets/design_system.dart';
import 'edit_beats_screen.dart';
import 'edit_notifications_screen.dart';
import 'edit_profile_screen.dart';
import 'edit_sounds_screen.dart';

void _navigateTo(BuildContext context, Widget screen,
    {bool withBeatBloc = false, bool withProfileBloc = false}) {
  final providers = [
    if (withProfileBloc) BlocProvider.value(value: context.read<ProfileBloc>()),
    if (withBeatBloc) BlocProvider.value(value: context.read<BeatBloc>()),
  ];
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => providers.isEmpty
          ? screen
          : MultiBlocProvider(providers: providers, child: screen),
    ),
  );
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Identity header — scoped to profile state only
                  BlocBuilder<ProfileBloc, ProfileState>(
                    builder: (context, state) {
                      if (state is ProfileInitial || state is ProfileLoading) {
                        return const Padding(
                          padding: EdgeInsets.fromLTRB(22, 24, 22, 14),
                          child: SizedBox(
                            height: 56,
                            child: Center(
                              child: CircularProgressIndicator(
                                  color: AppColors.violet, strokeWidth: 2),
                            ),
                          ),
                        );
                      }
                      if (state is ProfileError) {
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(22, 24, 22, 14),
                          child: Text(state.message,
                              style: const TextStyle(
                                  color: AppColors.subtle, fontSize: 13)),
                        );
                      }
                      if (state is ProfileLoaded) {
                        final profile = state.profile;
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(22, 24, 22, 14),
                          child: Row(
                            children: [
                              RhythmAvatar(
                                  size: 56,
                                  seed: profile.displayName),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      profile.displayName,
                                      style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.text,
                                          letterSpacing: -0.4),
                                    ),
                                    const SizedBox(height: 1),
                                    Text(
                                      profile.email,
                                      style: const TextStyle(
                                          fontSize: 11.5,
                                          color: AppColors.muted),
                                    ),
                                    const SizedBox(height: 6),
                                    GestureDetector(
                                      onTap: () => _navigateTo(
                                          context, const EditProfileScreen(),
                                          withProfileBloc: true),
                                      child: const Text(
                                        'Edit profile',
                                        style: TextStyle(
                                            fontSize: 11,
                                            color: AppColors.violetBright,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),

                  // Stats triplet
                  Padding(
                    padding: const EdgeInsets.fromLTRB(22, 0, 22, 6),
                    child: Row(
                      children: [
                        _StatCard(
                          label: 'Streak',
                          sub: 'days',
                          child: BlocBuilder<StreakBloc, StreakState>(
                            builder: (_, s) => displayNumber(
                              s is StreakLoaded ? '${s.currentStreak}' : '–',
                              size: 26,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _StatCard(
                          label: 'Done',
                          sub: 'tasks',
                          child: BlocBuilder<TaskBloc, TaskState>(
                            builder: (_, s) => displayNumber(
                              s is TaskLoaded && s.completedCount != null
                                  ? '${s.completedCount}'
                                  : '–',
                              size: 26,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _StatCard(
                          label: 'Beats',
                          sub: 'active',
                          child: BlocBuilder<BeatBloc, BeatState>(
                            builder: (_, s) => displayNumber(
                              s is BeatLoaded
                                  ? '${s.beats.where((b) => b.isActive).length}'
                                  : '–',
                              size: 26,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // My beats section — scoped to beat state only
                  Padding(
                    padding: const EdgeInsets.fromLTRB(22, 14, 22, 6),
                    child: Row(
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(left: 6),
                          child: SectionLabel('My beats'),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () => _navigateTo(
                              context, const EditBeatsScreen(),
                              withBeatBloc: true),
                          child: const Text('Edit',
                              style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.violetBright,
                                  fontWeight: FontWeight.w500)),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    child: RhythmCard(
                      child: BlocBuilder<BeatBloc, BeatState>(
                        builder: (_, state) {
                          if (state is BeatError) {
                            return Padding(
                              padding: const EdgeInsets.all(14),
                              child: Text(state.message,
                                  style: const TextStyle(
                                      color: AppColors.subtle, fontSize: 13)),
                            );
                          }
                          if (state is! BeatLoaded) {
                            return const Padding(
                              padding: EdgeInsets.all(14),
                              child: Text('No beats set up.',
                                  style: TextStyle(
                                      color: AppColors.subtle, fontSize: 13)),
                            );
                          }
                          final hasCustom = state.beats.any(
                            (b) =>
                                b.type == BeatType.custom &&
                                !b.id.startsWith('preset_'),
                          );
                          final visible = state.beats
                              .where((b) =>
                                  !b.id.startsWith('preset_') &&
                                  (b.isActive || hasCustom))
                              .toList()
                            ..sort((a, b) => _timeToMin(a.startTime).compareTo(_timeToMin(b.startTime)));
                          if (visible.isEmpty) {
                            return const Padding(
                              padding: EdgeInsets.all(14),
                              child: Text('No beats set up.',
                                  style: TextStyle(
                                      color: AppColors.subtle, fontSize: 13)),
                            );
                          }
                          return Column(
                            children: visible.asMap().entries.map((entry) {
                              final beat = entry.value;
                              final info = BeatInfo.forBeat(beat);
                              final isLast = entry.key == visible.length - 1;
                              final isCustom = beat.type == BeatType.custom &&
                                  !beat.id.startsWith('preset_');
                              final timeLabel = _beatTimeLabel(beat);
                              return Opacity(
                                opacity: beat.isActive ? 1.0 : 0.55,
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          14, 12, 14, 12),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 30,
                                            height: 30,
                                            decoration: BoxDecoration(
                                              color: info.bgColor,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Center(
                                              child: Container(
                                                width: 12,
                                                height: 12,
                                                decoration: BoxDecoration(
                                                  color: info.color,
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Text(
                                                      beat.name,
                                                      style: TextStyle(
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: beat.isActive
                                                            ? AppColors.text
                                                            : AppColors.muted,
                                                        decoration: beat.isActive
                                                            ? null
                                                            : TextDecoration
                                                                .lineThrough,
                                                        decorationColor:
                                                            AppColors.subtle,
                                                      ),
                                                    ),
                                                    if (isCustom) ...[
                                                      const SizedBox(width: 7),
                                                      Container(
                                                        padding: const EdgeInsets
                                                            .fromLTRB(
                                                            6, 2, 6, 2),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: AppColors
                                                              .violetSoft,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      999),
                                                        ),
                                                        child: const Text(
                                                          'CUSTOM',
                                                          style: TextStyle(
                                                            fontSize: 9,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            letterSpacing: 0.4,
                                                            color: AppColors
                                                                .violetBright,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ],
                                                ),
                                                if (timeLabel != null)
                                                  Text(
                                                    timeLabel,
                                                    style: const TextStyle(
                                                        fontSize: 11,
                                                        color: AppColors.subtle,
                                                        fontFeatures: [
                                                          FontFeature
                                                              .tabularFigures()
                                                        ]),
                                                  ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: beat.isActive
                                                  ? AppColors.successSoft
                                                  : AppColors.surface3,
                                              borderRadius:
                                                  BorderRadius.circular(999),
                                            ),
                                            child: Text(
                                              beat.isActive ? 'Active' : 'Off',
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w500,
                                                color: beat.isActive
                                                    ? AppColors.success
                                                    : AppColors.subtle,
                                              ),
                                            ),
                                          ),
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
                            }).toList(),
                          );
                        },
                      ),
                    ),
                  ),

                  // Account section — always visible
                  const Padding(
                    padding: EdgeInsets.fromLTRB(28, 14, 22, 6),
                    child: SectionLabel('Account'),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    child: RhythmCard(
                      child: Column(
                        children: [
                          _AccountRow(
                            icon: Icons.notifications_outlined,
                            title: 'Notifications',
                            sub: 'Beat reminders on',
                            onTap: () => _navigateTo(
                                context, const EditNotificationsScreen()),
                          ),
                          rhythmDivider,
                          BlocBuilder<ProfileBloc, ProfileState>(
                            builder: (context, state) {
                              final sound = state is ProfileLoaded
                                  ? state.profile.ambientSound
                                  : null;
                              final sub = switch (sound) {
                                AmbientSoundType.rain  => 'Rain',
                                AmbientSoundType.waves => 'Ocean waves',
                                AmbientSoundType.cafe  => 'Café',
                                AmbientSoundType.fire  => 'Fireplace',
                                null                   => 'None',
                              };
                              return _AccountRow(
                                icon: Icons.music_note_outlined,
                                title: 'Ambient sounds',
                                sub: sub,
                                onTap: () => _navigateTo(
                                    context, const EditSoundsScreen(),
                                    withProfileBloc: true),
                              );
                            },
                          ),
                          rhythmDivider,
                          _AccountRow(
                            icon: Icons.logout,
                            title: 'Sign out',
                            danger: true,
                            onTap: () async {
                              await Supabase.instance.client.auth.signOut();
                              if (context.mounted) context.go('/login');
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }


}

class _StatCard extends StatelessWidget {
  const _StatCard(
      {required this.label, required this.sub, required this.child});
  final String label;
  final String sub;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: RhythmCard(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            child,
            const SizedBox(height: 4),
            Text(
              '${label.toLowerCase()} · $sub',
              style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.subtle,
                  letterSpacing: 0.3),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccountRow extends StatelessWidget {
  const _AccountRow(
      {required this.icon,
      required this.title,
      this.sub,
      this.onTap,
      this.danger = false});
  final IconData icon;
  final String title;
  final String? sub;
  final VoidCallback? onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: danger ? AppColors.hotSoft : AppColors.violetSoft,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon,
                  size: 14,
                  color: danger ? AppColors.hot : AppColors.violet),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: danger ? AppColors.hot : AppColors.text),
                  ),
                  if (sub != null)
                    Text(sub!,
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.subtle)),
                ],
              ),
            ),
            if (!danger)
              const Icon(Icons.chevron_right, size: 14, color: AppColors.subtle),
          ],
        ),
      ),
    );
  }
}

int _timeToMin(String? t) {
  if (t == null) return 9999;
  final p = t.split(':');
  if (p.length < 2) return 0;
  return (int.tryParse(p[0]) ?? 0) * 60 + (int.tryParse(p[1]) ?? 0);
}

// Returns "9:00 AM – 10:30 PM" time range or single time, null if nothing.
String? _beatTimeLabel(Beat beat) {
  final start = _fmtTime(beat.startTime);
  final end = _fmtTime(beat.endTime);
  if (beat.startTime != null && beat.endTime != null) return '$start – $end';
  if (beat.startTime != null) return start;
  return null;
}

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
