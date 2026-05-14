import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/design_system.dart';

class EditSoundsScreen extends StatefulWidget {
  const EditSoundsScreen({super.key});

  @override
  State<EditSoundsScreen> createState() => _EditSoundsScreenState();
}

class _EditSoundsScreenState extends State<EditSoundsScreen> {
  double _volume = 0.62;

  final List<_Sound> _sounds = [
    _Sound(id: 'rain',   label: 'Rain',        sub: 'Soft, steady downpour',   active: true),
    _Sound(id: 'lofi',   label: 'Lo-fi',       sub: 'Mellow beats',            active: true),
    _Sound(id: 'forest', label: 'Forest',      sub: 'Birds & wind',            active: false),
    _Sound(id: 'waves',  label: 'Ocean waves', sub: 'Distant surf',            active: false),
    _Sound(id: 'cafe',   label: 'Café',        sub: 'Quiet chatter',           active: false),
    _Sound(id: 'brown',  label: 'Brown noise', sub: 'Low-frequency static',    active: false),
    _Sound(id: 'fire',   label: 'Fireplace',   sub: 'Crackling embers',        active: false),
  ];

  IconData _iconFor(String id) {
    return switch (id) {
      'rain'   => Icons.water_drop_outlined,
      'lofi'   => Icons.music_note_outlined,
      'forest' => Icons.park_outlined,
      'waves'  => Icons.waves_outlined,
      'cafe'   => Icons.local_cafe_outlined,
      'brown'  => Icons.graphic_eq,
      'fire'   => Icons.local_fire_department_outlined,
      _        => Icons.volume_up_outlined,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            BackNavHeader(
              title: 'Ambient sounds',
              actionLabel: 'Done',
              action: () => Navigator.of(context).pop(),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Volume card
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
                                onChanged: (v) => setState(() => _volume = v),
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
                                        onChanged: (_) => setState(() => sound.active = !sound.active),
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
    );
  }
}

class _Sound {
  _Sound({required this.id, required this.label, required this.sub, required this.active});
  final String id;
  final String label;
  final String sub;
  bool active;
}
