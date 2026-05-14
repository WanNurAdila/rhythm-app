import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository {
  AuthRepository({SupabaseClient? client, FlutterSecureStorage? secureStorage})
    : _client = client ?? Supabase.instance.client,
      _secureStorage = secureStorage ?? const FlutterSecureStorage();

  final SupabaseClient _client;
  final FlutterSecureStorage _secureStorage;

  static const _tokenKey = 'auth_token';

  Future<void> login({
    required String email,
    required String password,
  }) async {
    if (email.trim().isEmpty || password.isEmpty) {
      throw Exception('Email and password are required.');
    }

    final response = await _client.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );

    if (response.user == null || response.session == null) {
      throw Exception('Authentication failed. Please check your credentials.');
    }

    // Store token securely
    await _secureStorage.write(
      key: _tokenKey,
      value: response.session!.accessToken,
    );
  }

  Future<void> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    if (email.trim().isEmpty ||
        password.isEmpty ||
        displayName.trim().isEmpty) {
      throw Exception('Email, password, and display name are required.');
    }

    final response = await _client.auth.signUp(
      email: email.trim(),
      password: password,
      data: {'display_name': displayName},
    );

    if (response.user == null) {
      throw Exception('Registration failed. Please try again.');
    }

    // Store token securely if session exists
    if (response.session != null) {
      await _secureStorage.write(
        key: _tokenKey,
        value: response.session!.accessToken,
      );
    }
  }

  Future<void> logout() async {
    await _client.auth.signOut();
    await _secureStorage.delete(key: _tokenKey);
  }

  Future<String?> getStoredToken() async {
    return await _secureStorage.read(key: _tokenKey);
  }

  Future<void> clearStoredToken() async {
    await _secureStorage.delete(key: _tokenKey);
  }
}
