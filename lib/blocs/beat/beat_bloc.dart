import 'package:bloc/bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/beat.dart';
import '../../services/beat_service.dart';
import 'beat_event.dart';
import 'beat_state.dart';

class BeatBloc extends Bloc<BeatEvent, BeatState> {
  BeatBloc({required BeatService beatService})
      : _beatService = beatService,
        super(const BeatInitial()) {
    on<BeatsLoadRequested>(_onBeatsLoadRequested);
    on<BeatAddRequested>(_onBeatAddRequested);
    on<BeatToggleRequested>(_onBeatToggleRequested);
    on<BeatDeleteRequested>(_onBeatDeleteRequested);
  }

  final BeatService _beatService;

  Future<void> _onBeatsLoadRequested(
    BeatsLoadRequested event,
    Emitter<BeatState> emit,
  ) async {
    emit(const BeatLoading());
    try {
      final beats = await _beatService.getBeats();
      emit(BeatLoaded(beats: beats));
    } catch (error) {
      emit(BeatError(message: error.toString()));
    }
  }

  Future<void> _onBeatAddRequested(
    BeatAddRequested event,
    Emitter<BeatState> emit,
  ) async {
    final current = state;
    emit(const BeatLoading());
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated.');

      final beat = await _beatService.addBeat(
        userId: userId,
        type: event.type,
        name: event.name,
        startTime: event.startTime,
        durationMinutes: event.durationMinutes,
        isActive: event.isActive,
        sortOrder: event.sortOrder,
      );

      final existing = current is BeatLoaded ? current.beats : <Beat>[];
      emit(BeatLoaded(beats: [...existing, beat]));
    } catch (error) {
      emit(BeatError(message: error.toString()));
    }
  }

  Future<void> _onBeatToggleRequested(
    BeatToggleRequested event,
    Emitter<BeatState> emit,
  ) async {
    final current = state;
    if (current is! BeatLoaded) return;

    try {
      final updated = await _beatService.toggleBeat(
        event.id,
        isActive: event.isActive,
      );
      final beats = current.beats
          .map((b) => b.id == event.id ? updated : b)
          .toList();
      emit(current.copyWith(beats: beats));
    } catch (error) {
      emit(BeatError(message: error.toString()));
    }
  }

  Future<void> _onBeatDeleteRequested(
    BeatDeleteRequested event,
    Emitter<BeatState> emit,
  ) async {
    final current = state;
    if (current is! BeatLoaded) return;

    try {
      await _beatService.deleteBeat(event.id);
      final beats = current.beats.where((b) => b.id != event.id).toList();
      emit(current.copyWith(beats: beats));
    } catch (error) {
      emit(BeatError(message: error.toString()));
    }
  }
}
