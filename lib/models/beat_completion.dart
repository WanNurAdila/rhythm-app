class BeatCompletion {
  final String id;
  final String? userId;
  final String beatId;
  final DateTime completedDate;
  final int tasksTotal;
  final int tasksDone;

  const BeatCompletion({
    required this.id,
    this.userId,
    required this.beatId,
    required this.completedDate,
    required this.tasksTotal,
    required this.tasksDone,
  });

  factory BeatCompletion.fromJson(Map<String, dynamic> json) {
    return BeatCompletion(
      id: json['id'] as String,
      userId: json['user_id'] as String?,
      beatId: json['beat_id'] as String,
      completedDate: DateTime.parse(json['completed_date'] as String),
      tasksTotal: json['tasks_total'] as int,
      tasksDone: json['tasks_done'] as int,
    );
  }
}
