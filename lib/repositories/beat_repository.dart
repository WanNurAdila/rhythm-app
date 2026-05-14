import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/beat.dart';

class BeatRepository {
  BeatRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Future<List<Beat>> getBeats() async {
    final response = await _client
        .from('beats')
        .select()
        .order('name', ascending: true);

    return (response as List).map((e) => Beat.fromJson(e)).toList();
  }
}
