import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../blocs/beat/beat_bloc.dart';
import '../blocs/beat/beat_state.dart';
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

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, profileState) {
        if (profileState is ProfileInitial || profileState is ProfileLoading) {
          return const Center(child: CircularProgressIndicator(color: AppColors.violet, strokeWidth: 2));
        }
        if (profileState is ProfileError) {
          return Center(child: Text(profileState.message, style: const TextStyle(color: AppColors.subtle)));
        }
        if (profileState is ProfileLoaded) {
          return _ProfileContent(profile: profileState.profile);
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _ProfileContent extends StatelessWidget {
  const _ProfileContent({required this.profile});
  final dynamic profile;

  void _navigateTo(BuildContext context, Widget screen, {bool withBeatBloc = false, bool withProfileBloc = false}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MultiBlocProvider(
          providers: [
            if (withProfileBloc) BlocProvider.value(value: context.read<ProfileBloc>()),
            if (withBeatBloc) BlocProvider.value(value: context.read<BeatBloc>()),
          ],
          child: screen,
        ),
      ),
    );
  }

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
                  // Identity header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(22, 24, 22, 14),
                    child: Row(
                      children: [
                        RhythmAvatar(size: 56, initials: initialsFrom(profile.displayName)),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                profile.displayName,
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.text, letterSpacing: -0.4),
                              ),
                              const SizedBox(height: 1),
                              Text(
                                profile.email,
                                style: const TextStyle(fontSize: 11.5, color: AppColors.muted),
                              ),
                              const SizedBox(height: 6),
                              GestureDetector(
                                onTap: () => _navigateTo(context, const EditProfileScreen(), withProfileBloc: true),
                                child: const Text(
                                  'Edit profile',
                                  style: TextStyle(fontSize: 11, color: AppColors.violetBright, fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
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
                          child: displayNumber('–', size: 26),
                        ),
                        const SizedBox(width: 8),
                        _StatCard(
                          label: 'Beats',
                          sub: 'active',
                          child: BlocBuilder<BeatBloc, BeatState>(
                            builder: (_, s) => displayNumber(
                              s is BeatLoaded ? '${s.beats.where((b) => b.isActive).length}' : '–',
                              size: 26,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // My beats section
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
                          onTap: () => _navigateTo(context, const EditBeatsScreen(), withBeatBloc: true),
                          child: const Text('Edit', style: TextStyle(fontSize: 11, color: AppColors.violetBright, fontWeight: FontWeight.w500)),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    child: RhythmCard(
                      child: BlocBuilder<BeatBloc, BeatState>(
                        builder: (_, state) {
                          if (state is! BeatLoaded || state.beats.isEmpty) {
                            return const Padding(
                              padding: EdgeInsets.all(14),
                              child: Text('No beats set up.', style: TextStyle(color: AppColors.subtle, fontSize: 13)),
                            );
                          }
                          return Column(
                            children: state.beats.asMap().entries.map((entry) {
                              final beat = entry.value;
                              final info = BeatInfo.forType(beat.type);
                              final isLast = entry.key == state.beats.length - 1;
                              return Opacity(
                                opacity: beat.isActive ? 1.0 : 0.55,
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 30,
                                            height: 30,
                                            decoration: BoxDecoration(
                                              color: info.bgColor,
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Center(
                                              child: Container(
                                                width: 12,
                                                height: 12,
                                                decoration: BoxDecoration(
                                                  color: info.color,
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  beat.name,
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w500,
                                                    color: beat.isActive ? AppColors.text : AppColors.muted,
                                                    decoration: beat.isActive ? null : TextDecoration.lineThrough,
                                                    decorationColor: AppColors.subtle,
                                                  ),
                                                ),
                                                if (beat.startTime != null)
                                                  Text(beat.startTime!, style: const TextStyle(fontSize: 11, color: AppColors.subtle)),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: beat.isActive ? AppColors.successSoft : AppColors.surface3,
                                              borderRadius: BorderRadius.circular(999),
                                            ),
                                            child: Text(
                                              beat.isActive ? 'Active' : 'Off',
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w500,
                                                color: beat.isActive ? AppColors.success : AppColors.subtle,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (!isLast) const Divider(height: 1, thickness: 1, color: AppColors.border, indent: 14, endIndent: 14),
                                  ],
                                ),
                              );
                            }).toList(),
                          );
                        },
                      ),
                    ),
                  ),

                  // Account section
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
                            onTap: () => _navigateTo(context, const EditNotificationsScreen()),
                          ),
                          rhythmDivider,
                          _AccountRow(
                            icon: Icons.music_note_outlined,
                            title: 'Ambient sounds',
                            sub: 'Rain · Lo-fi',
                            onTap: () => _navigateTo(context, const EditSoundsScreen()),
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
  const _StatCard({required this.label, required this.sub, required this.child});
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
              style: const TextStyle(fontSize: 10, color: AppColors.subtle, letterSpacing: 0.3),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccountRow extends StatelessWidget {
  const _AccountRow({required this.icon, required this.title, this.sub, this.onTap, this.danger = false});
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
              child: Icon(icon, size: 14, color: danger ? AppColors.hot : AppColors.violet),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: danger ? AppColors.hot : AppColors.text),
                  ),
                  if (sub != null) Text(sub!, style: const TextStyle(fontSize: 11, color: AppColors.subtle)),
                ],
              ),
            ),
            if (!danger) const Icon(Icons.chevron_right, size: 14, color: AppColors.subtle),
          ],
        ),
      ),
    );
  }
}
