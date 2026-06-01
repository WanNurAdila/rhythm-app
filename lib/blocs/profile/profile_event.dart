import '../../models/profile.dart';

abstract class ProfileEvent {
  const ProfileEvent();
}

class ProfileLoadRequested extends ProfileEvent {
  const ProfileLoadRequested();
}

class ProfileUpdateRequested extends ProfileEvent {
  const ProfileUpdateRequested({
    required this.displayName,
    this.gender,
    this.pronouns,
    this.timezone,
    this.ambientSound,
  });

  final String displayName;
  final Gender? gender;
  final String? pronouns;
  final String? timezone;
  final AmbientSoundType? ambientSound;
}
