class UserProfile {
  final String id;
  final String displayName;
  final String email;
  final String? avatarUrl;
  final int totalTasksCompleted;
  final int totalFocusMinutes;

  const UserProfile({
    required this.id,
    required this.displayName,
    required this.email,
    this.avatarUrl,
    this.totalTasksCompleted = 0,
    this.totalFocusMinutes = 0,
  });

  UserProfile copyWith({
    String? id,
    String? displayName,
    String? email,
    String? avatarUrl,
    int? totalTasksCompleted,
    int? totalFocusMinutes,
  }) {
    return UserProfile(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      totalTasksCompleted: totalTasksCompleted ?? this.totalTasksCompleted,
      totalFocusMinutes: totalFocusMinutes ?? this.totalFocusMinutes,
    );
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      displayName: json['display_name'] as String,
      email: json['email'] as String,
      avatarUrl: json['avatar_url'] as String?,
      totalTasksCompleted: json['total_tasks_completed'] as int? ?? 0,
      totalFocusMinutes: json['total_focus_minutes'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'display_name': displayName,
      'email': email,
      'avatar_url': avatarUrl,
      'total_tasks_completed': totalTasksCompleted,
      'total_focus_minutes': totalFocusMinutes,
    };
  }
}
