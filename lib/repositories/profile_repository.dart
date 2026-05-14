import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_profile.dart';

class ProfileRepository {
  ProfileRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Future<UserProfile> getProfile() async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('User not authenticated.');

    final response = await _client
        .from('profiles')
        .select()
        .eq('id', user.id)
        .single();

    return UserProfile.fromJson(response);
  }

  Future<UserProfile> updateProfile({required String displayName}) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('User not authenticated.');

    final response = await _client
        .from('profiles')
        .update({'display_name': displayName})
        .eq('id', user.id)
        .select()
        .single();

    return UserProfile.fromJson(response);
  }
}
