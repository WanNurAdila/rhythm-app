import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/beat_service.dart';
import '../theme/app_theme.dart';
import '../widgets/design_system.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required this.displayName});
  final String displayName;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

// Preset beat definitions used during onboarding save.
// Keys match the _beatOn map keys.
const _onboardingPresets = {
  'morning': (type: 'morning',   name: 'Morning',      start: '07:00:00', end: '09:00:00', sort: 0),
  'deep':    (type: 'deep_work', name: 'Deep work',    start: '09:00:00', end: '12:30:00', sort: 1),
  'midday':  (type: 'midday',    name: 'Midday break', start: '12:30:00', end: '13:30:00', sort: 2),
  'evening': (type: 'evening',   name: 'Evening',      start: '18:30:00', end: '21:00:00', sort: 3),
};

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _step = 0;
  bool _saving = false;

  // Beat toggles for step 2
  final _beatOn = {
    'morning': true,
    'deep': true,
    'midday': false,
    'evening': true,
  };

  void _goNext() {
    if (_step < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  Future<void> _finishOnboarding() async {
    if (_saving) return;
    setState(() => _saving = true);

    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId != null) {
        final client = GraphQLProvider.of(context).value;
        final beatService = BeatService(client: client);

        for (final entry in _beatOn.entries) {
          if (!entry.value) continue;
          final cfg = _onboardingPresets[entry.key];
          if (cfg == null) continue;
          await beatService.activatePresetBeat(
            userId: userId,
            type: cfg.type,
            name: cfg.name,
            startTime: cfg.start,
            endTime: cfg.end,
            sortOrder: cfg.sort,
          );
        }
      }
    } catch (_) {
      // Non-critical — navigate to home anyway.
    }

    if (mounted) context.go('/home');
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          onPageChanged: (i) => setState(() => _step = i),
          children: [
            _WelcomePage(onNext: _goNext),
            _BeatSetupPage(beatOn: _beatOn, onToggle: (k) => setState(() => _beatOn[k] = !_beatOn[k]!), onNext: _goNext),
            _AllSetPage(displayName: widget.displayName, beatOn: _beatOn, onNext: _goNext, isSaving: _saving),
          ],
        ),
      ),
    );
  }
}

// ── Pagination dots ───────────────────────────────────────────────────────────

class _PageDots extends StatelessWidget {
  const _PageDots({required this.current});
  final int current;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) {
        final active = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 2.5),
          width: active ? 16 : 4,
          height: 4,
          decoration: BoxDecoration(
            color: active ? AppColors.violet : AppColors.faint,
            borderRadius: BorderRadius.circular(2),
          ),
        );
      }),
    );
  }
}

// ── Step 1: Welcome ───────────────────────────────────────────────────────────

class _WelcomePage extends StatelessWidget {
  const _WelcomePage({required this.onNext});
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 20),
      child: Column(
        children: [
          Center(child: BrandPulseMark(size: 64)),
          const SizedBox(height: 18),
          const Text(
            'Meet Rhythm',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w400,
              color: AppColors.text,
              letterSpacing: -0.5,
              height: 1.05,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 14),
            child: Text.rich(
              TextSpan(
                style: TextStyle(fontSize: 13, color: AppColors.muted, height: 1.45),
                children: [
                  TextSpan(text: 'Tasks that live inside timed, mood-matched blocks called '),
                  TextSpan(
                    text: 'beats',
                    style: TextStyle(color: AppColors.violetBright, fontWeight: FontWeight.w500),
                  ),
                  TextSpan(text: '.'),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 22),
          _FeatureCard(
            icon: const _BeatIcon(),
            title: 'Beats',
            body: 'Timed blocks with their own vibe',
          ),
          const SizedBox(height: 9),
          _FeatureCard(
            icon: const _EnergyIcon(),
            title: 'Energy matching',
            body: 'Right task, right time',
          ),
          const SizedBox(height: 9),
          _FeatureCard(
            icon: const _StreakIcon(),
            title: 'Streaks',
            body: 'Stay consistent every day',
          ),
          const Spacer(),
          const _PageDots(current: 0),
          const SizedBox(height: 14),
          PrimaryButton(label: 'Get started', onPressed: onNext),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({required this.icon, required this.title, required this.body});
  final Widget icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return RhythmCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.violetSoft,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Center(child: icon),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.text)),
                const SizedBox(height: 2),
                Text(body,
                    style: const TextStyle(fontSize: 11.5, color: AppColors.muted, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BeatIcon extends StatelessWidget {
  const _BeatIcon();
  @override
  Widget build(BuildContext context) => CustomPaint(
        size: const Size(18, 18),
        painter: _BeatIconPainter(),
      );
}

class _BeatIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.violet
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final rect = RRect.fromLTRBR(3, 4, 15, 14, const Radius.circular(2));
    canvas.drawRRect(rect, paint);
    canvas.drawLine(const Offset(3, 8), const Offset(15, 8), paint);
  }

  @override
  bool shouldRepaint(_) => false;
}

class _EnergyIcon extends StatelessWidget {
  const _EnergyIcon();
  @override
  Widget build(BuildContext context) => CustomPaint(
        size: const Size(18, 18),
        painter: _EnergyIconPainter(),
      );
}

class _EnergyIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.violet
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(9, 2), const Offset(9, 5), paint);
    canvas.drawLine(const Offset(9, 13), const Offset(9, 16), paint);
    canvas.drawLine(const Offset(2, 9), const Offset(5, 9), paint);
    canvas.drawLine(const Offset(13, 9), const Offset(16, 9), paint);
    canvas.drawCircle(const Offset(9, 9), 3, paint);
  }

  @override
  bool shouldRepaint(_) => false;
}

class _StreakIcon extends StatelessWidget {
  const _StreakIcon();
  @override
  Widget build(BuildContext context) => CustomPaint(
        size: const Size(18, 18),
        painter: _StreakIconPainter(),
      );
}

class _StreakIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.violet
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final path = Path()
      ..moveTo(9, 2)
      ..cubicTo(10, 5, 13, 6, 13, 9)
      ..arcToPoint(const Offset(5, 9), radius: const Radius.circular(4))
      ..cubicTo(5, 7, 6, 6, 6, 4)
      ..cubicTo(7, 5, 8, 5, 9, 2)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_) => false;
}

// ── Step 2: Beat setup ────────────────────────────────────────────────────────

class _BeatSetupPage extends StatelessWidget {
  const _BeatSetupPage({
    required this.beatOn,
    required this.onToggle,
    required this.onNext,
  });
  final Map<String, bool> beatOn;
  final void Function(String key) onToggle;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 40, 22, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Set up your beats',
            style: TextStyle(
                fontSize: 22, fontWeight: FontWeight.w600, color: AppColors.text, letterSpacing: -0.6),
          ),
          const SizedBox(height: 5),
          const Text(
            'Toggle beats for your day. Tap to set times.',
            style: TextStyle(fontSize: 12.5, color: AppColors.muted, height: 1.4),
          ),
          const SizedBox(height: 16),
          _BeatRow(
            label: 'Morning',
            time: '7:00 – 9:00 AM',
            color: BeatColors.morningColor,
            bgColor: BeatColors.morningBg,
            value: beatOn['morning']!,
            onChanged: () => onToggle('morning'),
          ),
          const SizedBox(height: 9),
          _BeatRow(
            label: 'Deep work',
            time: '9:00 AM – 12:30 PM',
            color: BeatColors.deepColor,
            bgColor: BeatColors.deepBg,
            value: beatOn['deep']!,
            onChanged: () => onToggle('deep'),
          ),
          const SizedBox(height: 9),
          _BeatRow(
            label: 'Midday break',
            time: '12:30 – 1:30 PM',
            color: BeatColors.middayColor,
            bgColor: BeatColors.middayBg,
            value: beatOn['midday']!,
            onChanged: () => onToggle('midday'),
          ),
          const SizedBox(height: 9),
          _BeatRow(
            label: 'Evening',
            time: '6:30 – 9:00 PM',
            color: BeatColors.eveningColor,
            bgColor: BeatColors.eveningBg,
            value: beatOn['evening']!,
            onChanged: () => onToggle('evening'),
          ),
          const Spacer(),
          const Text(
            'Inactive beats are saved but hidden from home.',
            style: TextStyle(fontSize: 11, color: AppColors.subtle, height: 1.45),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 14),
          const _PageDots(current: 1),
          const SizedBox(height: 14),
          PrimaryButton(label: 'Continue', onPressed: onNext),
        ],
      ),
    );
  }
}

class _BeatRow extends StatelessWidget {
  const _BeatRow({
    required this.label,
    required this.time,
    required this.color,
    required this.bgColor,
    required this.value,
    required this.onChanged,
  });
  final String label;
  final String time;
  final Color color;
  final Color bgColor;
  final bool value;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return RhythmCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Center(
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: color,
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
                Text(label,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.text)),
                const SizedBox(height: 1),
                Text(time,
                    style: const TextStyle(fontSize: 11.5, color: AppColors.muted,
                        fontFeatures: [FontFeature.tabularFigures()])),
              ],
            ),
          ),
          RhythmToggle(value: value, onChanged: (_) => onChanged()),
        ],
      ),
    );
  }
}

// ── Step 3: All set ───────────────────────────────────────────────────────────

// Start and end times (minutes since midnight) for each preset beat.
const _beatStartMins = {
  'morning': 420,   // 07:00
  'deep':    540,   // 09:00
  'midday':  750,   // 12:30
  'evening': 1110,  // 18:30
};
const _beatEndMins = {
  'morning': 540,   // 09:00
  'deep':    750,   // 12:30
  'midday':  810,   // 13:30
  'evening': 1260,  // 21:00
};
const _beatDisplayLabels = {
  'morning': 'Morning',
  'deep':    'Deep work',
  'midday':  'Midday break',
  'evening': 'Evening',
};
const _beatStartLabels = {
  'morning': '7:00 AM',
  'deep':    '9:00 AM',
  'midday':  '12:30 PM',
  'evening': '6:30 PM',
};

class _AllSetPage extends StatelessWidget {
  const _AllSetPage({
    required this.displayName,
    required this.beatOn,
    required this.onNext,
    this.isSaving = false,
  });
  final String displayName;
  final Map<String, bool> beatOn;
  final VoidCallback onNext;
  final bool isSaving;

  // Formats minutes to "X hr" if >= 60, otherwise "X min".
  (String value, String unit) _formatTime(int mins) {
    if (mins >= 60) return ('${mins ~/ 60}', 'hr');
    return ('$mins', 'min');
  }

  // Finds the currently active beat based on now.
  ({String timeValue, String timeUnit, String beatLabel, String startLabel})? _activeBeat() {
    final nowMin = DateTime.now().hour * 60 + DateTime.now().minute;
    for (final entry in beatOn.entries) {
      if (!entry.value) continue;
      final startMin = _beatStartMins[entry.key];
      final endMin = _beatEndMins[entry.key];
      if (startMin == null || endMin == null) continue;
      if (nowMin >= startMin && nowMin < endMin) {
        final remaining = endMin - nowMin;
        final (val, unit) = _formatTime(remaining);
        return (
          timeValue: val,
          timeUnit: unit,
          beatLabel: _beatDisplayLabels[entry.key] ?? entry.key,
          startLabel: _beatStartLabels[entry.key] ?? '',
        );
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final name = displayName.isNotEmpty ? displayName.split(' ').first : 'there';
    final active = _activeBeat();
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 20, 28, 24),
      child: Column(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                BrandPulseMark(size: 84),
                const SizedBox(height: 18),
                Text.rich(
                  TextSpan(
                    style: const TextStyle(
                      fontSize: 38,
                      fontWeight: FontWeight.w400,
                      color: AppColors.text,
                      letterSpacing: -0.5,
                      height: 1.05,
                    ),
                    children: [
                      const TextSpan(text: 'Happy Rhythm,\n'),
                      TextSpan(
                        text: name,
                        style: const TextStyle(color: AppColors.violetBright),
                      ),
                      const TextSpan(text: '.'),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 14),
                const Text(
                  'Your beats are set. Your flow is ready.\nStart small — one beat at a time.',
                  style: TextStyle(fontSize: 13, color: AppColors.muted, height: 1.5),
                  textAlign: TextAlign.center,
                ),
                if (active != null) ...[
                  const SizedBox(height: 28),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'BEAT IN PROGRESS',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.subtle,
                            letterSpacing: 1.0,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              active.timeValue,
                              style: const TextStyle(
                                fontSize: 64,
                                fontWeight: FontWeight.w400,
                                color: AppColors.violetBright,
                                letterSpacing: -2,
                                height: 1,
                                fontFeatures: [FontFeature.tabularFigures()],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 4, bottom: 8),
                              child: Text(
                                active.timeUnit,
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.violetBright,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${active.beatLabel} · ${active.startLabel}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.muted,
                            fontFeatures: [FontFeature.tabularFigures()],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const _PageDots(current: 2),
          const SizedBox(height: 14),
          PrimaryButton(
            label: isSaving ? 'Saving…' : 'Start my rhythm',
            onPressed: isSaving ? null : onNext,
          ),
        ],
      ),
    );
  }
}
