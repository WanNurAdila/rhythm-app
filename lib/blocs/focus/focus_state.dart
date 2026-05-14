import '../../models/task.dart';

abstract class FocusState {
  const FocusState();
}

class FocusIdle extends FocusState {
  const FocusIdle();
}

class FocusActive extends FocusState {
  final Task task;
  final String sessionId;
  final int remainingSeconds;
  final int totalSeconds;
  final bool isPaused;

  const FocusActive({
    required this.task,
    required this.sessionId,
    required this.remainingSeconds,
    required this.totalSeconds,
    this.isPaused = false,
  });

  double get progress =>
      totalSeconds > 0 ? (totalSeconds - remainingSeconds) / totalSeconds : 0;

  FocusActive copyWith({
    Task? task,
    String? sessionId,
    int? remainingSeconds,
    int? totalSeconds,
    bool? isPaused,
  }) {
    return FocusActive(
      task: task ?? this.task,
      sessionId: sessionId ?? this.sessionId,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      totalSeconds: totalSeconds ?? this.totalSeconds,
      isPaused: isPaused ?? this.isPaused,
    );
  }
}

class FocusComplete extends FocusState {
  final Task task;
  final int focusedSeconds;

  const FocusComplete({required this.task, required this.focusedSeconds});
}

class FocusError extends FocusState {
  final String message;

  const FocusError({required this.message});
}
