import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../services/focus_mode_service.dart';
import '../../services/focus_service.dart';
import '../../services/task_service.dart';
import 'focus_event.dart';
import 'focus_state.dart';

class FocusBloc extends Bloc<FocusEvent, FocusState> {
  FocusBloc({
    required FocusService focusService,
    required TaskService taskService,
    required FocusModeService focusModeService,
  })  : _focusService = focusService,
        _taskService = taskService,
        _focusModeService = focusModeService,
        super(const FocusIdle()) {
    on<FocusStarted>(_onFocusStarted);
    on<FocusPaused>(_onFocusPaused);
    on<FocusResumed>(_onFocusResumed);
    on<FocusCompleted>(_onFocusCompleted);
    on<FocusAbandoned>(_onFocusAbandoned);
    on<FocusTicked>(_onFocusTicked);
  }

  final FocusService _focusService;
  final TaskService _taskService;
  final FocusModeService _focusModeService;
  StreamSubscription<int>? _tickerSubscription;

  Future<void> _onFocusStarted(
    FocusStarted event,
    Emitter<FocusState> emit,
  ) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) {
      emit(const FocusError(message: 'User not authenticated.'));
      return;
    }

    try {
      final session = await _focusService.startSession(
        userId: userId,
        taskId: event.task.id,
        beatId: event.task.beatId,
      );

      await _focusModeService.enable();

      final totalSeconds = event.task.durationMinutes * 60;

      _startTicker();

      emit(FocusActive(
        task: event.task,
        sessionId: session.id,
        remainingSeconds: totalSeconds,
        totalSeconds: totalSeconds,
      ));
    } catch (error) {
      emit(FocusError(message: error.toString()));
    }
  }

  void _onFocusPaused(FocusPaused event, Emitter<FocusState> emit) {
    if (state is FocusActive) {
      emit((state as FocusActive).copyWith(isPaused: true));
    }
  }

  void _onFocusResumed(FocusResumed event, Emitter<FocusState> emit) {
    if (state is FocusActive) {
      emit((state as FocusActive).copyWith(isPaused: false));
    }
  }

  Future<void> _onFocusCompleted(
    FocusCompleted event,
    Emitter<FocusState> emit,
  ) async {
    final active = state;
    if (active is! FocusActive) return;

    _cancelTicker();

    final focusedSeconds = active.totalSeconds - active.remainingSeconds;

    try {
      await Future.wait([
        _focusService.endSession(
          id: active.sessionId,
          durationSeconds: focusedSeconds,
          completed: true,
        ),
        _taskService.completeTask(active.task.id),
        _focusModeService.disable(),
      ]);

      emit(FocusComplete(task: active.task, focusedSeconds: focusedSeconds));
    } catch (error) {
      await _focusModeService.disable();
      emit(FocusError(message: error.toString()));
    }
  }

  Future<void> _onFocusAbandoned(
    FocusAbandoned event,
    Emitter<FocusState> emit,
  ) async {
    final active = state;
    _cancelTicker();

    if (active is FocusActive) {
      try {
        await _focusService.endSession(
          id: active.sessionId,
          durationSeconds: active.totalSeconds - active.remainingSeconds,
          completed: false,
        );
      } catch (_) {
        // Best-effort — still reset to idle.
      }
    }

    await _focusModeService.disable();
    emit(const FocusIdle());
  }

  void _onFocusTicked(FocusTicked event, Emitter<FocusState> emit) {
    final active = state;
    if (active is! FocusActive || active.isPaused) return;

    if (active.remainingSeconds <= 1) {
      // Timer expired naturally — treat as user-completed.
      add(const FocusCompleted());
    } else {
      emit(active.copyWith(remainingSeconds: active.remainingSeconds - 1));
    }
  }

  void _startTicker() {
    _cancelTicker();
    _tickerSubscription = Stream.periodic(const Duration(seconds: 1), (i) => i)
        .listen((_) => add(const FocusTicked()));
  }

  void _cancelTicker() {
    _tickerSubscription?.cancel();
    _tickerSubscription = null;
  }

  @override
  Future<void> close() async {
    _cancelTicker();
    await _focusModeService.disable();
    return super.close();
  }
}
