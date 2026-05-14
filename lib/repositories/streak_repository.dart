import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/streak.dart';

class StreakRepository {
  StreakRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Future<Streak> getStreak() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated.');

    final response = await _client
        .from('streaks')
        .select()
        .eq('user_id', userId)
        .maybeSingle();

    if (response == null) return Streak(id: '', userId: userId);
    return Streak.fromJson(response);
  }

  Future<Streak> incrementStreak() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated.');

    final current = await getStreak();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final lastDate = current.lastActiveDate;
    final isConsecutive = lastDate != null &&
        today.difference(DateTime(lastDate.year, lastDate.month, lastDate.day)).inDays == 1;

    final newStreak = isConsecutive ? current.currentStreak + 1 : 1;
    final newLongest = newStreak > current.longestStreak ? newStreak : current.longestStreak;

    final data = {
      'user_id': userId,
      'current_streak': newStreak,
      'longest_streak': newLongest,
      'last_active_date': today.toIso8601String(),
    };

    final response = await _client
        .from('streaks')
        .upsert(data, onConflict: 'user_id')
        .select()
        .single();

    return Streak.fromJson(response);
  }
}
