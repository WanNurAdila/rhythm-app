class Streak {
  final String id;
  final String userId;
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastActiveDate;
  final DateTime? updatedAt;

  const Streak({
    required this.id,
    required this.userId,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastActiveDate,
    this.updatedAt,
  });

  Streak copyWith({
    String? id,
    String? userId,
    int? currentStreak,
    int? longestStreak,
    DateTime? lastActiveDate,
    DateTime? updatedAt,
  }) {
    return Streak(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastActiveDate: lastActiveDate ?? this.lastActiveDate,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory Streak.fromJson(Map<String, dynamic> json) {
    return Streak(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      currentStreak: json['current_streak'] as int? ?? 0,
      longestStreak: json['longest_streak'] as int? ?? 0,
      lastActiveDate: json['last_active_date'] != null
          ? DateTime.parse(json['last_active_date'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }
}
