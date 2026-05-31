class FocusSession {
  final String id;
  final String userId;
  final String taskId;
  final String beatId;
  final DateTime startedAt;
  final DateTime? endedAt;
  final int? durationSeconds;
  final bool completed;

  const FocusSession({
    required this.id,
    required this.userId,
    required this.taskId,
    required this.beatId,
    required this.startedAt,
    this.endedAt,
    this.durationSeconds,
    this.completed = false,
  });

  bool get isActive => endedAt == null;

  FocusSession copyWith({
    String? id,
    String? userId,
    String? taskId,
    String? beatId,
    DateTime? startedAt,
    DateTime? endedAt,
    int? durationSeconds,
    bool? completed,
  }) {
    return FocusSession(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      taskId: taskId ?? this.taskId,
      beatId: beatId ?? this.beatId,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      completed: completed ?? this.completed,
    );
  }

  factory FocusSession.fromJson(Map<String, dynamic> json) {
    return FocusSession(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      taskId: json['task_id'] as String,
      beatId: json['beat_id'] as String,
      startedAt: DateTime.parse(json['started_at'] as String),
      endedAt: json['ended_at'] != null
          ? DateTime.parse(json['ended_at'] as String)
          : null,
      durationSeconds: json['duration_seconds'] as int?,
      completed: json['completed'] as bool? ?? false,
    );
  }
}
