import '../../models/profile.dart';

abstract class ProfileState {
  const ProfileState();
}

class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

class ProfileLoaded extends ProfileState {
  final Profile profile;

  const ProfileLoaded({required this.profile});

  ProfileLoaded copyWith({Profile? profile}) {
    return ProfileLoaded(profile: profile ?? this.profile);
  }
}

class ProfileError extends ProfileState {
  final String message;

  const ProfileError({required this.message});
}
