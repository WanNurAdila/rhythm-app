class FocusSession {
  final String id;
  final String taskId;
  final DateTime startedAt;
  final DateTime? endedAt;
  final int? durationMinutes;

  const FocusSession({
    required this.id,
    required this.taskId,
    required this.startedAt,
    this.endedAt,
    this.durationMinutes,
  });

  bool get isActive => endedAt == null;

  FocusSession copyWith({
    String? id,
    String? taskId,
    DateTime? startedAt,
    DateTime? endedAt,
    int? durationMinutes,
  }) {
    return FocusSession(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      durationMinutes: durationMinutes ?? this.durationMinutes,
    );
  }

  factory FocusSession.fromJson(Map<String, dynamic> json) {
    return FocusSession(
      id: json['id'] as String,
      taskId: json['task_id'] as String,
      startedAt: DateTime.parse(json['started_at'] as String),
      endedAt: json['ended_at'] != null
          ? DateTime.parse(json['ended_at'] as String)
          : null,
      durationMinutes: json['duration_minutes'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'task_id': taskId,
      'started_at': startedAt.toIso8601String(),
      'ended_at': endedAt?.toIso8601String(),
      'duration_minutes': durationMinutes,
    };
  }
}
