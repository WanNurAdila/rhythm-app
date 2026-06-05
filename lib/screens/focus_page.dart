import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';

import '../blocs/focus/focus_bloc.dart';
import '../blocs/focus/focus_event.dart';
import '../blocs/focus/focus_state.dart' as focus_states;
import '../blocs/profile/profile_bloc.dart';
import '../blocs/profile/profile_state.dart';
import '../blocs/task/task_bloc.dart';
import '../blocs/task/task_event.dart';
import '../models/profile.dart' show AmbientSoundType;
import '../models/task.dart';
import '../theme/app_theme.dart';

class FocusPage extends StatefulWidget {
  const FocusPage({super.key, required this.task, this.beatName});

  final Task task;
  final String? beatName;

  @override
  State<FocusPage> createState() => _FocusPageState();
}

class _FocusPageState extends State<FocusPage> {
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        final state = context.read<FocusBloc>().state;
        if (state is focus_states.FocusActive) {
          _confirmAbandon(context);
        } else if (state is focus_states.FocusComplete) {
          // Block — user must tap "Back to Home"
        } else {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.bg,
        body: BlocConsumer<FocusBloc, focus_states.FocusState>(
          listener: (context, state) {
            if (state is focus_states.FocusComplete) {
              context.read<TaskBloc>().add(TaskCompleteRequested(state.task.id));
            }
            // FocusIdle after abandon or complete dismiss — pop back to home.
            if (state is focus_states.FocusIdle) {
              Navigator.of(context).pop();
            }
          },
          builder: (context, state) {
            if (state is focus_states.FocusIdle) {
              return _IdleView(task: widget.task, beatName: widget.beatName);
            }
            if (state is focus_states.FocusActive) {
              return _ActiveView(state: state, beatName: widget.beatName);
            }
            if (state is focus_states.FocusComplete) {
              return _FocusCompleteView(
                  state: state, beatName: widget.beatName);
            }
            if (state is focus_states.FocusError) {
              return _ErrorView(message: state.message);
            }
            return const Center(
              child: CircularProgressIndicator(color: AppColors.violet),
            );
          },
        ),
      ),
    );
  }
}

// ── Abandon confirmation ───────────────────────────────────────────────────

Future<void> _confirmAbandon(BuildContext context) async {
  final bloc = context.read<FocusBloc>();
  final state = bloc.state;

  final wasRunning =
      state is focus_states.FocusActive && !state.isPaused;
  if (wasRunning) bloc.add(const FocusPaused());

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => Dialog(
      backgroundColor: AppColors.bg2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Exit focus?',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: AppColors.text,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Your progress will reset. You'll need to start again.",
              style: TextStyle(
                fontSize: 13.5,
                color: AppColors.muted,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.of(ctx).pop(false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Center(
                        child: Text(
                          'Keep going',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.muted,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.of(ctx).pop(true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      decoration: BoxDecoration(
                        color: AppColors.hot.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: AppColors.hot.withValues(alpha: 0.25)),
                      ),
                      child: const Center(
                        child: Text(
                          'Exit',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.hot,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );

  if (!context.mounted) return;
  if (confirmed == true) {
    bloc.add(const FocusAbandoned());
  } else if (wasRunning) {
    bloc.add(const FocusResumed());
  }
}

// ── Shared background decoration ───────────────────────────────────────────

BoxDecoration _focusBackground() => BoxDecoration(
      gradient: RadialGradient(
        center: const Alignment(0, -0.4),
        radius: 1.0,
        colors: [
          AppColors.violetGlow.withValues(alpha: 0.25),
          Colors.transparent,
        ],
      ),
    );

// ── Idle view (pre-start) ──────────────────────────────────────────────────

class _IdleView extends StatelessWidget {
  const _IdleView({required this.task, this.beatName});
  final Task task;
  final String? beatName;

  @override
  Widget build(BuildContext context) {
    final totalMins = task.durationMinutes;
    final timeLabel =
        '${(totalMins ~/ 60).toString().padLeft(2, '0')}:${(totalMins % 60).toString().padLeft(2, '0')}';

    final energyLabel = switch (task.priority) {
      TaskPriority.low => 'Low energy',
      TaskPriority.medium => 'Medium energy',
      TaskPriority.high => 'High energy',
    };
    final subtitle =
        beatName != null ? '$beatName · $energyLabel' : energyLabel;

    return Container(
      decoration: _focusBackground(),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 24, 22, 18),
          child: Column(
            children: [
              _TopRow(
                beatName: beatName,
                onHome: () => Navigator.of(context).pop(),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _TimerRing(remainingFraction: 1.0, timeLabel: timeLabel),
                    const SizedBox(height: 20),
                    Text(
                      task.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.text,
                        letterSpacing: -0.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(subtitle,
                        style: const TextStyle(
                            fontSize: 11.5, color: AppColors.muted)),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () =>
                    context.read<FocusBloc>().add(FocusStarted(task)),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.violetBright, AppColors.violet],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.violetGlow,
                        blurRadius: 24,
                        spreadRadius: -4,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      'Start focus',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
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

// ── Active view ────────────────────────────────────────────────────────────

class _ActiveView extends StatelessWidget {
  const _ActiveView({required this.state, this.beatName});
  final focus_states.FocusActive state;
  final String? beatName;

  @override
  Widget build(BuildContext context) {
    final mins = state.remainingSeconds ~/ 60;
    final secs = state.remainingSeconds % 60;
    final timeLabel =
        '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';

    final energyLabel = switch (state.task.priority) {
      TaskPriority.low => 'Low energy',
      TaskPriority.medium => 'Medium energy',
      TaskPriority.high => 'High energy',
    };
    final subtitle =
        beatName != null ? '$beatName · $energyLabel' : energyLabel;

    return Container(
      decoration: _focusBackground(),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 24, 22, 18),
          child: Column(
            children: [
              _TopRow(
                beatName: beatName,
                onHome: () => _confirmAbandon(context),
              ),
              const SizedBox(height: 10),
              const Text(
                'Switch beats from Home',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.subtle,
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _TimerRing(
                      remainingFraction: 1.0 - state.progress,
                      timeLabel: timeLabel,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      state.task.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.text,
                        letterSpacing: -0.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(subtitle,
                        style: const TextStyle(
                            fontSize: 11.5, color: AppColors.muted)),
                  ],
                ),
              ),
              Column(
                children: [
                  _SoundCard(),
                  const SizedBox(height: 12),
                  _ControlsRow(isPaused: state.isPaused),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Focus complete view ────────────────────────────────────────────────────

class _FocusCompleteView extends StatelessWidget {
  const _FocusCompleteView({required this.state, this.beatName});
  final focus_states.FocusComplete state;
  final String? beatName;

  @override
  Widget build(BuildContext context) {
    final minutes = (state.focusedSeconds / 60).ceil();
    final beatName = this.beatName ?? 'your beat';

    return Stack(
      children: [
        // Dimmed blurred background
        Container(
          decoration: _focusBackground(),
          child: Center(
            child: Opacity(
              opacity: 0.22,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border:
                      Border.all(color: AppColors.violetBright, width: 3),
                ),
              ),
            ),
          ),
        ),
        // Scrim
        Container(color: Colors.black.withValues(alpha: 0.6)),
        // Modal card
        Center(
          child: Padding(
            padding: const EdgeInsets.all(26),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.bg2,
                borderRadius: BorderRadius.circular(26),
                border: Border.all(color: AppColors.border),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black,
                    blurRadius: 60,
                    spreadRadius: -10,
                    offset: Offset(0, 30),
                  ),
                ],
              ),
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 22),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Success icon
                  Container(
                    width: 76,
                    height: 76,
                    decoration: const BoxDecoration(
                      color: AppColors.successSoft,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(Icons.check_rounded,
                          color: AppColors.success, size: 34),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Beat complete',
                    style: GoogleFonts.instrumentSerif(
                      fontSize: 32,
                      color: AppColors.text,
                      height: 1.05,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text.rich(
                    TextSpan(
                      style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.muted,
                          height: 1.5),
                      children: [
                        const TextSpan(text: 'Nice work — you focused for\n'),
                        TextSpan(
                          text: '$minutes ${minutes == 1 ? 'minute' : 'minutes'}',
                          style: const TextStyle(
                              color: AppColors.text,
                              fontWeight: FontWeight.w600),
                        ),
                        TextSpan(text: ' on $beatName.'),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 18),
                  // Stats
                  Row(
                    children: [
                      _StatCell(value: '$minutes', label: 'minutes'),
                      const SizedBox(width: 10),
                      _StatCell(value: '1', label: 'task done'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () => context.read<FocusBloc>().add(const FocusAbandoned()),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.violet,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.violetGlow,
                            blurRadius: 24,
                            spreadRadius: -8,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          'Back to Home',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: GoogleFonts.instrumentSerif(
                fontSize: 26,
                color: AppColors.violetBright,
                height: 1,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.subtle,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Shared top row ─────────────────────────────────────────────────────────

class _TopRow extends StatelessWidget {
  const _TopRow({this.beatName, required this.onHome});
  final String? beatName;
  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: onHome,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.chevron_left_rounded,
                  color: AppColors.muted, size: 20),
              SizedBox(width: 2),
              Text(
                'Home',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.muted,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Center(child: _BeatChip(name: beatName ?? 'Focus')),
        ),
        // Spacer to balance the back button width
        const SizedBox(width: 52),
      ],
    );
  }
}

// ── Beat chip ──────────────────────────────────────────────────────────────

class _BeatChip extends StatelessWidget {
  const _BeatChip({required this.name});
  final String name;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: AppColors.violetBright,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: AppColors.violetGlow, blurRadius: 8),
              ],
            ),
          ),
          const SizedBox(width: 7),
          Text(
            name,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.text),
          ),
        ],
      ),
    );
  }
}

// ── Timer ring ─────────────────────────────────────────────────────────────

class _TimerRing extends StatelessWidget {
  const _TimerRing({required this.remainingFraction, required this.timeLabel});
  final double remainingFraction;
  final String timeLabel;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260,
      height: 260,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(260, 260),
            painter: _RingPainter(remainingFraction: remainingFraction),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                timeLabel,
                style: GoogleFonts.instrumentSerif(
                  fontSize: 72,
                  color: AppColors.text,
                  letterSpacing: -2,
                  height: 1,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'REMAINING',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.subtle,
                  letterSpacing: 1,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({required this.remainingFraction});
  final double remainingFraction;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    const r = 110.0;
    const sw = 3.0;

    canvas.drawCircle(
      center,
      r,
      Paint()
        ..color = AppColors.surface2
        ..strokeWidth = sw
        ..style = PaintingStyle.stroke,
    );

    if (remainingFraction <= 0) return;

    final rect = Rect.fromCircle(center: center, radius: r);
    final sweep = 2 * math.pi * remainingFraction;

    canvas.drawArc(
      rect, -math.pi / 2, sweep, false,
      Paint()
        ..color = AppColors.violetBright.withValues(alpha: 0.35)
        ..strokeWidth = sw + 6
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );

    canvas.drawArc(
      rect, -math.pi / 2, sweep, false,
      Paint()
        ..color = AppColors.violetBright
        ..strokeWidth = sw
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.remainingFraction != remainingFraction;
}

// ── Ambient sound card ─────────────────────────────────────────────────────

class _SoundCard extends StatefulWidget {
  @override
  State<_SoundCard> createState() => _SoundCardState();
}

class _SoundCardState extends State<_SoundCard> {
  final _player = AudioPlayer();
  bool _playing = false;

  String _assetFor(AmbientSoundType type) => switch (type) {
        AmbientSoundType.rain  => 'assets/audio/rain-ambient.mp3',
        AmbientSoundType.waves => 'assets/audio/waves-ambient.mp3',
        AmbientSoundType.cafe  => 'assets/audio/cafe-ambient.mp3',
        AmbientSoundType.fire  => 'assets/audio/fire-ambient.mp3',
      };

  String _labelFor(AmbientSoundType type) => switch (type) {
        AmbientSoundType.rain  => 'Rain',
        AmbientSoundType.waves => 'Ocean waves',
        AmbientSoundType.cafe  => 'Café',
        AmbientSoundType.fire  => 'Fireplace',
      };

  Future<void> _toggle(AmbientSoundType type) async {
    if (_playing) {
      setState(() => _playing = false);
      await _player.stop();
    } else {
      setState(() => _playing = true);
      await _player.setAsset(_assetFor(type));
      await _player.setLoopMode(LoopMode.one);
      await _player.play();
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        final ambientSound =
            state is ProfileLoaded ? state.profile.ambientSound : null;
        final hasSound = ambientSound != null;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.music_note_rounded,
                    color: hasSound ? AppColors.violetBright : AppColors.muted,
                    size: 18,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      hasSound ? _labelFor(ambientSound) : 'Ambient sounds',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                        color: hasSound ? AppColors.text : AppColors.muted,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: hasSound ? () => _toggle(ambientSound) : null,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 36,
                      height: 22,
                      decoration: BoxDecoration(
                        color: _playing ? AppColors.violetBright : AppColors.surface3,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Align(
                        alignment: _playing ? Alignment.centerRight : Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.all(2),
                          child: Container(
                            width: 18,
                            height: 18,
                            decoration: const BoxDecoration(
                                color: Colors.white, shape: BoxShape.circle),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              if (!hasSound)
                const Padding(
                  padding: EdgeInsets.only(top: 5, left: 30),
                  child: Text(
                    'Set an ambient sound in your profile to enable',
                    style: TextStyle(fontSize: 11, color: AppColors.muted),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

// ── Controls row ───────────────────────────────────────────────────────────

class _ControlsRow extends StatelessWidget {
  const _ControlsRow({required this.isPaused});
  final bool isPaused;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Pause / Resume
        GestureDetector(
          onTap: () => context.read<FocusBloc>().add(
                isPaused ? const FocusResumed() : const FocusPaused(),
              ),
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.violetBright, AppColors.violet],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.violetGlow,
                  blurRadius: 24,
                  spreadRadius: -4,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Center(
              child: isPaused
                  ? const Icon(Icons.play_arrow_rounded,
                      color: Colors.white, size: 28)
                  : const Icon(Icons.pause_rounded,
                      color: Colors.white, size: 26),
            ),
          ),
        ),
        const SizedBox(width: 28),
        // Stop (X) — with confirmation
        GestureDetector(
          onTap: () => _confirmAbandon(context),
          child: Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surface2,
              border: Border.all(color: AppColors.border),
            ),
            child: const Center(
              child: Icon(Icons.close_rounded,
                  color: AppColors.muted, size: 20),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Error view ─────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: const Icon(Icons.close, color: AppColors.subtle, size: 22),
            ),
            const Spacer(),
            Text(message,
                style: const TextStyle(color: AppColors.hot, fontSize: 14)),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: const Text('Go back',
                  style: TextStyle(color: AppColors.violet, fontSize: 14)),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
