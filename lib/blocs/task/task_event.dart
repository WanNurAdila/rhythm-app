abstract class TaskEvent {
  const TaskEvent();
}

class TasksLoadRequested extends TaskEvent {
  final String beatId;
  final DateTime scheduledDate;

  const TasksLoadRequested({required this.beatId, required this.scheduledDate});
}

class TaskAddRequested extends TaskEvent {
  final String beatId;
  final String title;
  final String priority;
  final int durationMinutes;
  final DateTime scheduledDate;

  const TaskAddRequested({
    required this.beatId,
    required this.title,
    required this.priority,
    required this.durationMinutes,
    required this.scheduledDate,
  });
}

class TaskCompleteRequested extends TaskEvent {
  final String id;

  const TaskCompleteRequested(this.id);
}

class TaskDeleteRequested extends TaskEvent {
  final String id;

  const TaskDeleteRequested(this.id);
}

class TaskRefreshRequested extends TaskEvent {
  const TaskRefreshRequested();
}

class CompletedCountLoadRequested extends TaskEvent {
  const CompletedCountLoadRequested();
}
