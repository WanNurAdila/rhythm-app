abstract class StreakEvent {
  const StreakEvent();
}

class StreakLoadRequested extends StreakEvent {
  const StreakLoadRequested();
}

class BeatCompletionRecorded extends StreakEvent {
  final String beatId;
  final int tasksTotal;
  final int tasksDone;

  const BeatCompletionRecorded({
    required this.beatId,
    required this.tasksTotal,
    required this.tasksDone,
  });
}
