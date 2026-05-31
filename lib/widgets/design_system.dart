import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:random_avatar/random_avatar.dart';
import '../models/beat.dart';
import '../theme/app_theme.dart';

// ── Beat palette (matches design: 6 swatchable colors) ───────────────────────

const beatPalette = [
  Color(0xFFF5B67A), // morning orange
  Color(0xFFA18BFF), // violet
  Color(0xFF7AD1F5), // sky blue
  Color(0xFFF57AA3), // pink
  Color(0xFF6CE4A3), // green
  Color(0xFFFFC857), // amber (default for custom)
];

const beatPaletteHex = [
  '#f5b67a', '#a18bff', '#7ad1f5', '#f57aa3', '#6ce4a3', '#ffc857',
];

Color colorFromHex(String hex) {
  final clean = hex.replaceFirst('#', '');
  return Color(int.parse('FF$clean', radix: 16));
}

// ── Beat info helper ─────────────────────────────────────────────────────────

class BeatInfo {
  final Color color;
  final Color bgColor;
  final String label;

  const BeatInfo({required this.color, required this.bgColor, required this.label});

  static BeatInfo forType(BeatType type) {
    switch (type) {
      case BeatType.morning:
        return const BeatInfo(color: BeatColors.morningColor, bgColor: BeatColors.morningBg, label: 'Morning');
      case BeatType.deepWork:
        return const BeatInfo(color: BeatColors.deepColor, bgColor: BeatColors.deepBg, label: 'Deep work');
      case BeatType.midday:
        return const BeatInfo(color: BeatColors.middayColor, bgColor: BeatColors.middayBg, label: 'Midday break');
      case BeatType.evening:
        return const BeatInfo(color: BeatColors.eveningColor, bgColor: BeatColors.eveningBg, label: 'Evening');
      case BeatType.custom:
        return const BeatInfo(color: BeatColors.customColor, bgColor: BeatColors.customBg, label: 'Custom');
    }
  }

  // Uses beat.color for custom beats when available.
  static BeatInfo forBeat(Beat beat) {
    if (beat.type == BeatType.custom && beat.color != null) {
      final color = colorFromHex(beat.color!);
      return BeatInfo(
        color: color,
        bgColor: color.withValues(alpha: 0.12),
        label: beat.name,
      );
    }
    return forType(beat.type);
  }
}

// ── Brand pulse mark ─────────────────────────────────────────────────────────

class BrandPulseMark extends StatefulWidget {
  const BrandPulseMark({super.key, this.size = 72});
  final double size;

  @override
  State<BrandPulseMark> createState() => _BrandPulseMarkState();
}

class _BrandPulseMarkState extends State<BrandPulseMark> with TickerProviderStateMixin {
  late final AnimationController _ring1;
  late final AnimationController _ring2;

  @override
  void initState() {
    super.initState();
    _ring1 = AnimationController(vsync: this, duration: const Duration(milliseconds: 2600))..repeat();
    _ring2 = AnimationController(vsync: this, duration: const Duration(milliseconds: 2600));
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) _ring2.repeat();
    });
  }

  @override
  void dispose() {
    _ring1.dispose();
    _ring2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.size;
    final radius = s * 0.22;
    return SizedBox(
      width: s,
      height: s,
      child: Stack(
        alignment: Alignment.center,
        children: [
          _PulseRing(controller: _ring1, size: s, radius: radius),
          _PulseRing(controller: _ring2, size: s, radius: radius),
          Container(
            width: s,
            height: s,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFB39CFF), Color(0xFF8B6CF6), Color(0xFF6E4EE5)],
                stops: [0.0, 0.6, 1.0],
              ),
              borderRadius: BorderRadius.circular(radius),
              boxShadow: const [
                BoxShadow(color: AppColors.violetGlow, blurRadius: 32, offset: Offset(0, 8)),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: s * 0.78,
                  height: s * 0.78,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withValues(alpha: 0.18), width: s * 0.012),
                  ),
                ),
                Container(
                  width: s * 0.5,
                  height: s * 0.5,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withValues(alpha: 0.22), width: s * 0.012),
                  ),
                ),
                Container(
                  width: s * 0.28,
                  height: s * 0.28,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(s * 0.062),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PulseRing extends StatelessWidget {
  const _PulseRing({required this.controller, required this.size, required this.radius});
  final AnimationController controller;
  final double size;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, _) => Transform.scale(
        scale: 1.0 + controller.value * 0.8,
        child: Opacity(
          opacity: (1.0 - controller.value) * 0.5,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(radius),
              border: Border.all(color: AppColors.violet, width: 1.5),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Mini brand mark (for nav if needed) ─────────────────────────────────────

class MiniMark extends StatelessWidget {
  const MiniMark({super.key, this.size = 24, this.glow = false});
  final double size;
  final bool glow;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.violetBright, AppColors.violet],
        ),
        borderRadius: BorderRadius.circular(size * 0.28),
        boxShadow: glow
            ? const [BoxShadow(color: AppColors.violetGlow, blurRadius: 16, offset: Offset(0, 4))]
            : null,
      ),
    );
  }
}

// ── Avatar ────────────────────────────────────────────────────────────────────

class RhythmAvatar extends StatelessWidget {
  const RhythmAvatar({super.key, this.size = 36, this.seed = 'default'});
  final double size;
  final String seed;

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: SizedBox(
        width: size,
        height: size,
        child: RandomAvatar(seed, height: size, width: size),
      ),
    );
  }
}

// ── Card ──────────────────────────────────────────────────────────────────────

class RhythmCard extends StatelessWidget {
  const RhythmCard({super.key, required this.child, this.padding, this.borderRadius = 18.0});
  final Widget child;
  final EdgeInsets? padding;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }
}

// ── Primary button ────────────────────────────────────────────────────────────

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({super.key, required this.label, required this.onPressed, this.isLoading = false});
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          boxShadow: onPressed != null
              ? const [BoxShadow(color: AppColors.violetGlow, blurRadius: 24, offset: Offset(0, 8))]
              : null,
        ),
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          child: isLoading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : Text(label),
        ),
      ),
    );
  }
}

// ── Section label ─────────────────────────────────────────────────────────────

class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        color: AppColors.subtle,
        letterSpacing: 1.0,
      ),
    );
  }
}

// ── Toggle switch ─────────────────────────────────────────────────────────────

class RhythmToggle extends StatelessWidget {
  const RhythmToggle({super.key, required this.value, this.onChanged});
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onChanged != null ? () => onChanged!(!value) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 36,
        height: 22,
        decoration: BoxDecoration(
          color: value ? AppColors.violet : AppColors.surface3,
          borderRadius: BorderRadius.circular(999),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 180),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.all(2),
            width: 18,
            height: 18,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Color(0x4D000000), blurRadius: 3, offset: Offset(0, 1))],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Energy dots ──────────────────────────────────────────────────────────────

class EnergyDots extends StatelessWidget {
  const EnergyDots({super.key, required this.level, this.total = 5});
  final int level;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(total, (i) {
        final on = i < level;
        return Container(
          margin: const EdgeInsets.only(left: 4),
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            color: on ? AppColors.violet : AppColors.faint,
            shape: BoxShape.circle,
            boxShadow: on
                ? const [BoxShadow(color: AppColors.violetGlow, blurRadius: 8)]
                : null,
          ),
        );
      }),
    );
  }
}

// ── Display text helper ───────────────────────────────────────────────────────

Widget displayNumber(String text, {double size = 44, Color color = AppColors.text}) {
  return Text(
    text,
    style: GoogleFonts.instrumentSerif(fontSize: size, color: color, letterSpacing: -1),
  );
}

// ── Divider ───────────────────────────────────────────────────────────────────

const rhythmDivider = Divider(height: 1, thickness: 1, color: AppColors.border);

// ── Chip (energy / beat selector) ────────────────────────────────────────────

class SelectorChip extends StatelessWidget {
  const SelectorChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.selectedColor = AppColors.violet,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color selectedColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? selectedColor : AppColors.surface2,
          borderRadius: BorderRadius.circular(10),
          border: selected ? null : Border.all(color: AppColors.border),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : AppColors.muted,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
          ),
        ),
      ),
    );
  }
}

// ── Back nav header ───────────────────────────────────────────────────────────

class BackNavHeader extends StatelessWidget {
  const BackNavHeader({super.key, required this.title, this.action, this.actionLabel = 'Done'});
  final String title;
  final VoidCallback? action;
  final String actionLabel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 10),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Row(
              children: [
                const Icon(Icons.chevron_left, size: 20, color: AppColors.text),
                const SizedBox(width: 2),
                Text(
                  title,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.text),
                ),
              ],
            ),
          ),
          const Spacer(),
          if (action != null)
            GestureDetector(
              onTap: action,
              child: Text(
                actionLabel,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.violetBright),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Input label ───────────────────────────────────────────────────────────────

class InputLabel extends StatelessWidget {
  const InputLabel(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.muted,
          letterSpacing: 0.1,
        ),
      ),
    );
  }
}
