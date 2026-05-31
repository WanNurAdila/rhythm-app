enum TaskPriority {
  low,
  medium,
  high;

  static TaskPriority fromJson(String value) => switch (value) {
        'low' => TaskPriority.low,
        'medium' => TaskPriority.medium,
        'high' => TaskPriority.high,
        _ => TaskPriority.medium,
      };

  String toJson() => name;
}

// Returns the smart default duration in minutes based on priority level.
int defaultDuration(String priority) => switch (priority) {
      'low' => 15,
      'medium' => 30,
      'high' => 45,
      _ => 30,
    };

class Task {
  final String id;
  final String? userId;
  final String beatId;
  final String title;
  final TaskPriority priority;
  final int durationMinutes;
  final bool isCompleted;
  final DateTime scheduledDate;
  final DateTime? completedAt;
  final DateTime? createdAt;

  const Task({
    required this.id,
    this.userId,
    required this.beatId,
    required this.title,
    required this.priority,
    required this.durationMinutes,
    this.isCompleted = false,
    required this.scheduledDate,
    this.completedAt,
    this.createdAt,
  });

  Task copyWith({
    String? id,
    String? userId,
    String? beatId,
    String? title,
    TaskPriority? priority,
    int? durationMinutes,
    bool? isCompleted,
    DateTime? scheduledDate,
    DateTime? completedAt,
    DateTime? createdAt,
  }) {
    return Task(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      beatId: beatId ?? this.beatId,
      title: title ?? this.title,
      priority: priority ?? this.priority,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      isCompleted: isCompleted ?? this.isCompleted,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String,
      userId: json['user_id'] as String?,
      beatId: json['beat_id'] as String,
      title: json['title'] as String,
      priority: TaskPriority.fromJson(json['priority'] as String),
      durationMinutes: json['duration_minutes'] as int,
      isCompleted: json['is_completed'] as bool? ?? false,
      scheduledDate: DateTime.parse(json['scheduled_date'] as String),
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }
}
