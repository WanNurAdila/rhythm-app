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

class PresetBeatDef {
  final BeatType type;
  final String name;
  final String? startTime;
  final int? durationMinutes;
  final int sortOrder;

  const PresetBeatDef({
    required this.type,
    required this.name,
    this.startTime,
    this.durationMinutes,
    required this.sortOrder,
  });
}

const presetBeatDefs = [
  PresetBeatDef(type: BeatType.morning,  name: 'Morning',      startTime: '7:00',  durationMinutes: 60,  sortOrder: 0),
  PresetBeatDef(type: BeatType.deepWork, name: 'Deep work',    startTime: '9:00',  durationMinutes: 120, sortOrder: 1),
  PresetBeatDef(type: BeatType.midday,   name: 'Midday break', startTime: '12:00', durationMinutes: 30,  sortOrder: 2),
  PresetBeatDef(type: BeatType.evening,  name: 'Evening',      startTime: '18:00', durationMinutes: 60,  sortOrder: 3),
];

String presetId(BeatType type) => 'preset_${type.toJson()}';

class Beat {
  final String id;
  final String userId;
  final BeatType type;
  final String name;
  final String? color;
  final String? startTime;
  final String? endTime;
  final bool isActive;
  final bool? isPreset;
  final int? durationMinutes;
  final int sortOrder;
  final DateTime? createdAt;

  const Beat({
    required this.id,
    required this.userId,
    required this.type,
    required this.name,
    this.color,
    this.startTime,
    this.endTime,
    required this.isActive,
    this.isPreset,
    this.durationMinutes,
    required this.sortOrder,
    this.createdAt,
  });

  Beat copyWith({
    String? id,
    String? userId,
    BeatType? type,
    String? name,
    String? color,
    String? startTime,
    String? endTime,
    bool? isActive,
    bool? isPreset,
    int? durationMinutes,
    int? sortOrder,
    DateTime? createdAt,
  }) {
    return Beat(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      name: name ?? this.name,
      color: color ?? this.color,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isActive: isActive ?? this.isActive,
      isPreset: isPreset ?? this.isPreset,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory Beat.fromJson(Map<String, dynamic> json) {
    return Beat(
      id: json['id'] as String,
      userId: json['user_id'] as String? ?? '',
      type: BeatType.fromJson(json['type'] as String),
      name: json['name'] as String,
      color: json['color'] as String?,
      startTime: json['start_time'] as String?,
      endTime: json['end_time'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      isPreset: json['is_preset'] as bool?,
      durationMinutes: json['duration_minutes'] as int?,
      sortOrder: json['sort_order'] as int? ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }
}
