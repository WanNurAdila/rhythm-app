class DailyStat {
  final DateTime date;
  final int tasksDone;
  final int tasksTotal;

  const DailyStat({
    required this.date,
    this.tasksDone = 0,
    this.tasksTotal = 0,
  });

  double get completionRate =>
      tasksTotal > 0 ? tasksDone / tasksTotal : 0.0;

  bool get hasActivity => tasksTotal > 0;
}

class WeeklyStats {
  // Always 7 entries: today at index 6, 6 days ago at index 0.
  final List<DailyStat> days;

  const WeeklyStats({required this.days});

  double get averageCompletionRate {
    final active = days.where((d) => d.hasActivity).toList();
    if (active.isEmpty) return 0;
    return active.map((d) => d.completionRate).reduce((a, b) => a + b) /
        active.length;
  }
}
