enum Gender { male, female, other }

class Profile {
  final String id;
  final String displayName;
  final String email;
  final Gender? gender;
  final String? pronouns;
  final String? timezone;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Profile({
    required this.id,
    required this.displayName,
    required this.email,
    this.gender,
    this.pronouns,
    this.timezone,
    required this.createdAt,
    this.updatedAt,
  });

  Profile copyWith({
    String? id,
    String? displayName,
    String? email,
    Gender? gender,
    String? pronouns,
    String? timezone,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Profile(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      gender: gender ?? this.gender,
      pronouns: pronouns ?? this.pronouns,
      timezone: timezone ?? this.timezone,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory Profile.fromJson(Map<String, dynamic> json, {String? email}) {
    final genderStr = json['gender'] as String?;
    return Profile(
      id: json['id'] as String,
      displayName: json['display_name'] as String,
      email: (json['email'] as String?) ?? email ?? '',
      gender: genderStr != null
          ? Gender.values.firstWhere((e) => e.name == genderStr,
              orElse: () => Gender.other)
          : null,
      pronouns: json['pronouns'] as String?,
      timezone: json['timezone'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }
}
