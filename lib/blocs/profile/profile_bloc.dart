import 'package:bloc/bloc.dart';
import '../../services/profile_service.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc({required ProfileService profileService})
      : _profileService = profileService,
        super(const ProfileInitial()) {
    on<ProfileLoadRequested>(_onProfileLoadRequested);
    on<ProfileUpdateRequested>(_onProfileUpdateRequested);
  }

  final ProfileService _profileService;

  Future<void> _onProfileLoadRequested(
    ProfileLoadRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());
    try {
      final profile = await _profileService.getProfile();
      emit(ProfileLoaded(profile: profile));
    } catch (error) {
      emit(ProfileError(message: error.toString()));
    }
  }

  Future<void> _onProfileUpdateRequested(
    ProfileUpdateRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());
    try {
      final profile = await _profileService.updateProfile(
        displayName: event.displayName,
        gender: event.gender,
        pronouns: event.pronouns,
        timezone: event.timezone,
        ambientSound: event.ambientSound,
      );
      emit(ProfileLoaded(profile: profile));
    } catch (error) {
      emit(ProfileError(message: error.toString()));
    }
  }
}
