import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/focus_session.dart';

class FocusRepository {
  FocusRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Future<FocusSession> startSession(String taskId) async {
    final response = await _client
        .from('focus_sessions')
        .insert({
          'task_id': taskId,
          'started_at': DateTime.now().toIso8601String(),
        })
        .select()
        .single();

    return FocusSession.fromJson(response);
  }

  Future<FocusSession> endSession(String sessionId, int durationMinutes) async {
    final response = await _client
        .from('focus_sessions')
        .update({
          'ended_at': DateTime.now().toIso8601String(),
          'duration_minutes': durationMinutes,
        })
        .eq('id', sessionId)
        .select()
        .single();

    return FocusSession.fromJson(response);
  }

  Future<List<FocusSession>> getSessionsForTask(String taskId) async {
    final response = await _client
        .from('focus_sessions')
        .select()
        .eq('task_id', taskId)
        .order('started_at', ascending: false);

    return (response as List).map((e) => FocusSession.fromJson(e)).toList();
  }
}
