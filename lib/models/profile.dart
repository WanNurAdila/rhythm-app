class Profile {
  final String id;
  final String displayName;
  final String email;
  final DateTime createdAt;

  const Profile({
    required this.id,
    required this.displayName,
    required this.email,
    required this.createdAt,
  });

  Profile copyWith({
    String? id,
    String? displayName,
    String? email,
    DateTime? createdAt,
  }) {
    return Profile(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // email is not in the profiles table — pass it separately from auth.
  factory Profile.fromJson(Map<String, dynamic> json, {required String email}) {
    return Profile(
      id: json['id'] as String,
      displayName: json['display_name'] as String,
      email: email,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
