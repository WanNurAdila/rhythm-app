import '../../models/task.dart';

abstract class FocusEvent {
  const FocusEvent();
}

class FocusStarted extends FocusEvent {
  final Task task;

  const FocusStarted(this.task);
}

class FocusPaused extends FocusEvent {
  const FocusPaused();
}

class FocusResumed extends FocusEvent {
  const FocusResumed();
}

class FocusCompleted extends FocusEvent {
  const FocusCompleted();
}

class FocusAbandoned extends FocusEvent {
  const FocusAbandoned();
}

class FocusTicked extends FocusEvent {
  const FocusTicked();
}
