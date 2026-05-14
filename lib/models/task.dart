enum TaskEnergy {
  low,
  medium,
  high;

  static TaskEnergy fromJson(String value) => switch (value) {
        'low' => TaskEnergy.low,
        'medium' => TaskEnergy.medium,
        'high' => TaskEnergy.high,
        _ => TaskEnergy.medium,
      };

  String toJson() => name;
}

// Returns the smart default duration in minutes based on energy level.
int defaultDuration(String energy) => switch (energy) {
      'low' => 15,
      'medium' => 30,
      'high' => 45,
      _ => 30,
    };

class Task {
  final String id;
  final String userId;
  final String beat;
  final String title;
  final TaskEnergy energy;
  final int durationMinutes;
  final bool isCompleted;
  final DateTime scheduledDate;
  final DateTime? completedAt;
  final DateTime createdAt;

  const Task({
    required this.id,
    required this.userId,
    required this.beat,
    required this.title,
    required this.energy,
    required this.durationMinutes,
    this.isCompleted = false,
    required this.scheduledDate,
    this.completedAt,
    required this.createdAt,
  });

  Task copyWith({
    String? id,
    String? userId,
    String? beat,
    String? title,
    TaskEnergy? energy,
    int? durationMinutes,
    bool? isCompleted,
    DateTime? scheduledDate,
    DateTime? completedAt,
    DateTime? createdAt,
  }) {
    return Task(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      beat: beat ?? this.beat,
      title: title ?? this.title,
      energy: energy ?? this.energy,
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
      userId: json['user_id'] as String,
      beat: json['beat'] as String,
      title: json['title'] as String,
      energy: TaskEnergy.fromJson(json['energy'] as String),
      durationMinutes: json['duration_minutes'] as int,
      isCompleted: json['is_completed'] as bool? ?? false,
      scheduledDate: DateTime.parse(json['scheduled_date'] as String),
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
