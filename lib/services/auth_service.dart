// lib/services/auth_service.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthService {
  static SharedPreferences? _prefs;
  static const String _tokenKey = 'jwt_token';
  static const String _baseUrl = 'https://api.odltracker.my.id/v1';

  static Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static String? get token => _prefs?.getString(_tokenKey);

  static Future<void> setToken(String token) async {
    await _prefs?.setString(_tokenKey, token);
  }

  static Future<void> clearToken() async {
    await _prefs?.remove(_tokenKey);
  }

  static bool isAuthenticated() {
    final token = _prefs?.getString(_tokenKey);
    return token != null && token.isNotEmpty;
  }

  static Map<String, String> _headers({bool withAuth = false}) {
    final headers = {'Content-Type': 'application/json'};
    if (withAuth && token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  static Future<http.Response> register({
    required String email,
    required String password,
    required String name,
  }) async {
    final url = Uri.parse('$_baseUrl/auth/register');
    return await http.post(url,
      headers: _headers(),
      body: jsonEncode({
        'email': email,
        'password': password,
        'name': name,
      }),
    );
  }

  static Future<http.Response> verifyEmail(String token) async {
    final url = Uri.parse('$_baseUrl/auth/verify-email?token=$token');
    return await http.get(url, headers: _headers());
  }

  static Future<http.Response> resendVerificationEmail(String email) async {
    final url = Uri.parse('$_baseUrl/auth/resend-verification-email');
    return await http.post(url,
      headers: _headers(),
      body: jsonEncode({ 'email': email }),
    );
  }

  static Future<http.Response> logout() async {
    final url = Uri.parse('$_baseUrl/auth/logout');
    return await http.get(url, headers: _headers(withAuth: true));
  }

  static Future<http.Response> forgotPassword(String email) async {
    final url = Uri.parse('$_baseUrl/auth/forgot-password');
    return await http.post(url,
      headers: _headers(),
      body: jsonEncode({ 'email': email }),
    );
  }

  static Future<http.Response> resetPassword(String token, String newPassword) async {
    final url = Uri.parse('$_baseUrl/auth/reset-password?token=$token');
    return await http.post(url,
      headers: _headers(),
      body: jsonEncode({ 'newPassword': newPassword }),
    );
  }
}
