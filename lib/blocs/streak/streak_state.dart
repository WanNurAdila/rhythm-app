import '../../models/weekly_stats.dart';

// HeatmapData: date (midnight-normalised) → total tasks_done that day.
// 0 = no activity, 1–3 = low–medium, 4+ = high opacity in the UI.
typedef HeatmapData = Map<DateTime, int>;

abstract class StreakState {
  const StreakState();
}

class StreakInitial extends StreakState {
  const StreakInitial();
}

class StreakLoading extends StreakState {
  const StreakLoading();
}

class StreakLoaded extends StreakState {
  final int currentStreak;
  final int longestStreak;
  final HeatmapData heatmapData;
  final WeeklyStats weeklyStats;

  const StreakLoaded({
    required this.currentStreak,
    required this.longestStreak,
    required this.heatmapData,
    required this.weeklyStats,
  });

  StreakLoaded copyWith({
    int? currentStreak,
    int? longestStreak,
    HeatmapData? heatmapData,
    WeeklyStats? weeklyStats,
  }) {
    return StreakLoaded(
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      heatmapData: heatmapData ?? this.heatmapData,
      weeklyStats: weeklyStats ?? this.weeklyStats,
    );
  }
}

class StreakError extends StreakState {
  final String message;

  const StreakError({required this.message});
}
