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
    on<BeatUpdateRequested>(_onBeatUpdateRequested);
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
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated.');
      final apiBeats = await _beatService.getBeats(userId: userId);
      emit(BeatLoaded(beats: _mergeWithPresets(apiBeats)));
    } catch (error) {
      emit(BeatError(message: error.toString()));
    }
  }

  List<Beat> _mergeWithPresets(List<Beat> apiBeats) {
    final result = <Beat>[];
    for (final def in presetBeatDefs) {
      Beat? existing;
      for (final b in apiBeats) {
        if (b.type == def.type) { existing = b; break; }
      }
      result.add(existing ?? Beat(
        id: presetId(def.type),
        userId: '',
        type: def.type,
        name: def.name,
        startTime: def.startTime,
        isActive: false,
        sortOrder: def.sortOrder,
      ));
    }
    for (final b in apiBeats) {
      if (!presetBeatDefs.any((d) => d.type == b.type)) result.add(b);
    }
    return result;
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

      final beat = await _beatService.addCustomBeat(
        userId: userId,
        name: event.name,
        color: event.color,
        startTime: event.startTime,
        endTime: event.endTime,
        sortOrder: event.sortOrder,
      );

      final existing = current is BeatLoaded ? current.beats : <Beat>[];
      emit(BeatLoaded(beats: [...existing, beat]));
    } catch (error) {
      emit(BeatError(message: error.toString()));
    }
  }

  Future<void> _onBeatUpdateRequested(
    BeatUpdateRequested event,
    Emitter<BeatState> emit,
  ) async {
    final current = state;
    if (current is! BeatLoaded) return;

    try {
      final beat = await _beatService.updateBeat(
        id: event.id,
        name: event.name,
        color: event.color,
        startTime: event.startTime,
        endTime: event.endTime,
        isActive: event.isActive,
      );
      final beats = current.beats.map((b) => b.id == event.id ? beat : b).toList();
      emit(current.copyWith(beats: beats));
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
      await _beatService.toggleBeat(event.id, isActive: event.isActive);
      final beats = current.beats
          .map((b) => b.id == event.id ? b.copyWith(isActive: event.isActive) : b)
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
