import 'package:bloc/bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/beat_completion.dart';
import '../../models/streak.dart';
import '../../models/weekly_stats.dart';
import '../../services/streak_service.dart';
import 'streak_event.dart';
import 'streak_state.dart';

class StreakBloc extends Bloc<StreakEvent, StreakState> {
  StreakBloc({required StreakService streakService})
      : _streakService = streakService,
        super(const StreakInitial()) {
    on<StreakLoadRequested>(_onStreakLoadRequested);
    on<BeatCompletionRecorded>(_onBeatCompletionRecorded);
  }

  final StreakService _streakService;

  // Cached so BeatCompletionRecorded can mutate without a full reload.
  Streak? _streak;
  List<BeatCompletion> _completions = [];

  Future<void> _onStreakLoadRequested(
    StreakLoadRequested event,
    Emitter<StreakState> emit,
  ) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) {
      emit(const StreakError(message: 'User not authenticated.'));
      return;
    }

    emit(const StreakLoading());
    try {
      final fromDate = _today().subtract(const Duration(days: 27));

      final results = await Future.wait([
        _streakService.getStreak(userId),
        _streakService.getBeatCompletions(userId, fromDate),
      ]);

      _streak = results[0] as Streak?;
      _completions = results[1] as List<BeatCompletion>;

      emit(_buildLoaded());
    } catch (error) {
      emit(StreakError(message: error.toString()));
    }
  }

  Future<void> _onBeatCompletionRecorded(
    BeatCompletionRecorded event,
    Emitter<StreakState> emit,
  ) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null || state is! StreakLoaded) return;

    try {
      final today = _today();

      // Skip if this beat was already completed today.
      final alreadyRecorded = await _streakService.beatCompletionExists(
        userId: userId,
        beatId: event.beatId,
        date: today,
      );
      if (alreadyRecorded) return;

      // Persist the beat completion record.
      final completion = await _streakService.recordBeatCompletion(
        userId: userId,
        beatId: event.beatId,
        completedDate: today,
        tasksTotal: event.tasksTotal,
        tasksDone: event.tasksDone,
      );
      _completions = [..._completions, completion];

      // Compute new streak values.
      final current = _streak;
      final lastActive = current?.lastActiveDate != null
          ? _normalise(current!.lastActiveDate!)
          : null;

      int newStreak;
      if (lastActive == today) {
        newStreak = current!.currentStreak; // already counted today
      } else if (lastActive == today.subtract(const Duration(days: 1))) {
        newStreak = (current?.currentStreak ?? 0) + 1; // consecutive day
      } else {
        newStreak = 1; // streak broken — reset
      }

      final newLongest =
          newStreak > (current?.longestStreak ?? 0) ? newStreak : (current?.longestStreak ?? 0);

      // Persist updated streak row and update cache locally.
      await _streakService.updateStreak(
        userId: userId,
        currentStreak: newStreak,
        longestStreak: newLongest,
        lastActiveDate: today,
      );
      _streak = (_streak ?? Streak(id: '', userId: userId)).copyWith(
        currentStreak: newStreak,
        longestStreak: newLongest,
        lastActiveDate: today,
      );

      emit(_buildLoaded());
    } catch (error) {
      emit(StreakError(message: error.toString()));
    }
  }

  // --- Helpers ---

  StreakLoaded _buildLoaded() {
    return StreakLoaded(
      currentStreak: _streak?.currentStreak ?? 0,
      longestStreak: _streak?.longestStreak ?? 0,
      heatmapData: _buildHeatmap(_completions),
      weeklyStats: _buildWeeklyStats(_completions),
    );
  }

  HeatmapData _buildHeatmap(List<BeatCompletion> completions) {
    final map = <DateTime, int>{};
    for (final c in completions) {
      final date = _normalise(c.completedDate);
      map[date] = (map[date] ?? 0) + c.tasksDone;
    }
    return map;
  }

  WeeklyStats _buildWeeklyStats(List<BeatCompletion> completions) {
    final today = _today();

    // Build a lookup: date → aggregated (done, total).
    final lookup = <DateTime, ({int done, int total})>{};
    for (final c in completions) {
      final date = _normalise(c.completedDate);
      final prev = lookup[date] ?? (done: 0, total: 0);
      lookup[date] = (done: prev.done + c.tasksDone, total: prev.total + c.tasksTotal);
    }

    final days = List.generate(7, (i) {
      final date = today.subtract(Duration(days: 6 - i));
      final entry = lookup[date];
      return DailyStat(
        date: date,
        tasksDone: entry?.done ?? 0,
        tasksTotal: entry?.total ?? 0,
      );
    });

    return WeeklyStats(days: days);
  }

  DateTime _today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  DateTime _normalise(DateTime dt) => DateTime(dt.year, dt.month, dt.day);
}
