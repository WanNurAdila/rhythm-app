enum BeatType {
  morning,
  deepWork,
  midday,
  evening,
  custom;

  static BeatType fromJson(String value) {
    switch (value) {
      case 'morning':
        return BeatType.morning;
      case 'deep_work':
        return BeatType.deepWork;
      case 'midday':
        return BeatType.midday;
      case 'evening':
        return BeatType.evening;
      case 'custom':
        return BeatType.custom;
      default:
        return BeatType.custom;
    }
  }

  String toJson() {
    switch (this) {
      case BeatType.morning:
        return 'morning';
      case BeatType.deepWork:
        return 'deep_work';
      case BeatType.midday:
        return 'midday';
      case BeatType.evening:
        return 'evening';
      case BeatType.custom:
        return 'custom';
    }
  }
}

class Beat {
  final String id;
  final String userId;
  final BeatType type;
  final String name;
  final String? startTime;
  final int? durationMinutes;
  final bool isActive;
  final int sortOrder;

  const Beat({
    required this.id,
    required this.userId,
    required this.type,
    required this.name,
    this.startTime,
    this.durationMinutes,
    required this.isActive,
    required this.sortOrder,
  });

  Beat copyWith({
    String? id,
    String? userId,
    BeatType? type,
    String? name,
    String? startTime,
    int? durationMinutes,
    bool? isActive,
    int? sortOrder,
  }) {
    return Beat(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      name: name ?? this.name,
      startTime: startTime ?? this.startTime,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      isActive: isActive ?? this.isActive,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  factory Beat.fromJson(Map<String, dynamic> json) {
    return Beat(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      type: BeatType.fromJson(json['type'] as String),
      name: json['name'] as String,
      startTime: json['start_time'] as String?,
      durationMinutes: json['duration_minutes'] as int?,
      isActive: json['is_active'] as bool? ?? true,
      sortOrder: json['sort_order'] as int? ?? 0,
    );
  }
}
