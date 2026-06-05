import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:volume_controller/volume_controller.dart';

import '../blocs/profile/profile_bloc.dart';
import '../blocs/profile/profile_event.dart';
import '../blocs/profile/profile_state.dart';
import '../models/profile.dart';
import '../theme/app_theme.dart';
import '../widgets/design_system.dart';

class EditSoundsScreen extends StatefulWidget {
  const EditSoundsScreen({super.key});

  @override
  State<EditSoundsScreen> createState() => _EditSoundsScreenState();
}

class _EditSoundsScreenState extends State<EditSoundsScreen> {
  double _volume = 0.5;
  bool _saving = false;
  Profile? _profile;

  final List<_Sound> _sounds = [
    _Sound(id: 'rain',  label: 'Rain',        sub: 'Soft, steady downpour', type: AmbientSoundType.rain),
    _Sound(id: 'waves', label: 'Ocean waves', sub: 'Distant surf',          type: AmbientSoundType.waves),
    _Sound(id: 'cafe',  label: 'Café',        sub: 'Quiet chatter',         type: AmbientSoundType.cafe),
    _Sound(id: 'fire',  label: 'Fireplace',   sub: 'Crackling embers',      type: AmbientSoundType.fire),
  ];

  @override
  void initState() {
    super.initState();

    // Sync slider with hardware volume — also fetches initial value immediately.
    VolumeController.instance.showSystemUI = false;
    VolumeController.instance.addListener(
      (volume) { if (mounted) setState(() => _volume = volume); },
      fetchInitialVolume: true,
    );

    final state = context.read<ProfileBloc>().state;
    if (state is ProfileLoaded) {
      _profile = state.profile;
      _initActiveSound(state.profile.ambientSound);
    }
  }

  @override
  void dispose() {
    VolumeController.instance.removeListener();
    super.dispose();
  }

  void _initActiveSound(AmbientSoundType? selected) {
    for (final s in _sounds) {
      s.active = s.type == selected;
    }
  }

  void _onToggle(_Sound tapped) {
    final wasActive = tapped.active;
    setState(() {
      for (final s in _sounds) {
        s.active = false;
      }
      if (!wasActive) tapped.active = true;
    });

    final profile = _profile;
    if (profile == null) return;

    setState(() => _saving = true);
    context.read<ProfileBloc>().add(ProfileUpdateRequested(
      displayName: profile.displayName,
      gender: profile.gender,
      pronouns: profile.pronouns,
      timezone: profile.timezone,
      ambientSound: wasActive ? null : tapped.type,
    ));
  }

  IconData _iconFor(String id) {
    return switch (id) {
      'rain'  => Icons.water_drop_outlined,
      'waves' => Icons.waves_outlined,
      'cafe'  => Icons.local_cafe_outlined,
      'fire'  => Icons.local_fire_department_outlined,
      _       => Icons.volume_up_outlined,
    };
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is ProfileLoaded) {
          setState(() {
            _saving = false;
            _profile = state.profile;
            _initActiveSound(state.profile.ambientSound);
          });
        } else if (state is ProfileError && _saving) {
          setState(() => _saving = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.hot,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.bg,
        body: SafeArea(
          child: Column(
            children: [
              BackNavHeader(
                title: 'Ambient sounds',
                actionLabel: _saving ? 'Saving…' : 'Done',
                action: () => Navigator.of(context).pop(),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(22, 40, 22, 12),
                        child: RhythmCard(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Text('VOLUME', style: TextStyle(fontSize: 12, color: AppColors.muted, letterSpacing: 0.4, fontWeight: FontWeight.w500)),
                                  const Spacer(),
                                  Text('${(_volume * 100).round()}%', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.text)),
                                ],
                              ),
                              const SizedBox(height: 10),
                              SliderTheme(
                                data: SliderThemeData(
                                  activeTrackColor: AppColors.violetBright,
                                  inactiveTrackColor: AppColors.surface3,
                                  thumbColor: Colors.white,
                                  overlayColor: AppColors.violetSoft,
                                  trackHeight: 6,
                                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 9),
                                ),
                                child: Slider(
                                  value: _volume,
                                  onChanged: (v) {
                                    setState(() => _volume = v);
                                    VolumeController.instance.setVolume(v);
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const Padding(
                        padding: EdgeInsets.fromLTRB(28, 0, 22, 6),
                        child: SectionLabel('Library'),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(22, 0, 22, 24),
                        child: RhythmCard(
                          child: Column(
                            children: _sounds.asMap().entries.map((entry) {
                              final sound = entry.value;
                              final isLast = entry.key == _sounds.length - 1;
                              return Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 34,
                                          height: 34,
                                          decoration: BoxDecoration(
                                            color: sound.active ? AppColors.violetSoft : AppColors.surface2,
                                            borderRadius: BorderRadius.circular(9),
                                          ),
                                          child: Icon(_iconFor(sound.id), size: 16, color: AppColors.violetBright),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(sound.label, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w500, color: AppColors.text)),
                                              Text(sound.sub, style: const TextStyle(fontSize: 11.5, color: AppColors.subtle)),
                                            ],
                                          ),
                                        ),
                                        if (sound.active)
                                          const Padding(
                                            padding: EdgeInsets.only(right: 10),
                                            child: Text('Playing', style: TextStyle(fontSize: 11, color: AppColors.violetBright, fontWeight: FontWeight.w600)),
                                          ),
                                        RhythmToggle(
                                          value: sound.active,
                                          onChanged: (_) => _onToggle(sound),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (!isLast) rhythmDivider,
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Sound {
  _Sound({required this.id, required this.label, required this.sub, required this.type});
  final String id;
  final String label;
  final String sub;
  final AmbientSoundType type;
  bool active = false;
}
