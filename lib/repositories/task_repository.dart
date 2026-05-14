import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/task.dart';

class TaskRepository {
  TaskRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Future<List<Task>> getTasks() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated.');

    final response = await _client
        .from('tasks')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (response as List).map((e) => Task.fromJson(e)).toList();
  }

  Future<Task> addTask({
    required String name,
    required String beat,
    required String energy,
    required int durationMinutes,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated.');

    final response = await _client
        .from('tasks')
        .insert({
          'user_id': userId,
          'name': name,
          'beat': beat,
          'energy': energy,
          'duration_minutes': durationMinutes,
          'is_completed': false,
        })
        .select()
        .single();

    return Task.fromJson(response);
  }

  Future<Task> completeTask(String taskId) async {
    final response = await _client
        .from('tasks')
        .update({'is_completed': true})
        .eq('id', taskId)
        .select()
        .single();

    return Task.fromJson(response);
  }

  Future<void> deleteTask(String taskId) async {
    await _client.from('tasks').delete().eq('id', taskId);
  }
}
