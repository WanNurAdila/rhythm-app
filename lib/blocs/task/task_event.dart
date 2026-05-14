abstract class TaskEvent {
  const TaskEvent();
}

class TasksLoadRequested extends TaskEvent {
  final String beat;
  final DateTime scheduledDate;

  const TasksLoadRequested({required this.beat, required this.scheduledDate});
}

class TaskAddRequested extends TaskEvent {
  final String beat;
  final String title;
  final String energy;
  final int durationMinutes;
  final DateTime scheduledDate;

  const TaskAddRequested({
    required this.beat,
    required this.title,
    required this.energy,
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
