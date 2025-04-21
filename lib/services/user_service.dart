import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart'; // Pastikan AuthService ada untuk token autentikasi

class UserService {
  static const String baseUrl = 'https://api.odltracker.my.id/v1';

  // Header request dengan Authorization token
  static Map<String, String> _headers() {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${AuthService.token}',  // Gunakan token yang ada di AuthService
    };
  }

  // Mendapatkan data profil user
  static Future<http.Response> getProfile() async {
    final url = Uri.parse('$baseUrl/profile');
    return await http.get(url, headers: _headers());
  }

  // Mengupdate profil user (name)
  static Future<http.Response> updateProfile({required String name}) async {
    final url = Uri.parse('$baseUrl/profile');
    final response = await http.put(
      url,
      headers: _headers(),
      body: jsonEncode(
        {
          "name": name,
        }
      ),
    );
    return response;
  }

  // Menghapus profil user
  static Future<http.Response> deleteProfile() async {
    final url = Uri.parse('$baseUrl/profile');
    return await http.delete(url, headers: _headers());
  }

  // Mengubah email user
  static Future<http.Response> changeEmail(String email) async {
    final url = Uri.parse('$baseUrl/profile/change-email');
    final response = await http.post(
      url,
      headers: _headers(),
      body: jsonEncode({
        'email': email,
      }),
    );
    return response;
  }

  // Mengubah password user
  static Future<http.Response> changePassword(String oldPassword, String newPassword) async {
    final url = Uri.parse('$baseUrl/profile/change-password');
    final response = await http.post(
      url,
      headers: _headers(),
      body: jsonEncode({
        'oldPassword': oldPassword,
        'newPassword': newPassword,
      }),
    );
    return response;
  }

  // Mengubah foto profil user
  static Future<http.Response> changeProfilePicture(String profilePictureUrl) async {
    final url = Uri.parse('$baseUrl/profile/profile-picture');
    final response = await http.post(
      url,
      headers: _headers(),
      body: jsonEncode({
        'profilePicture': profilePictureUrl,
      }),
    );
    return response;
  }

  // Menghapus foto profil user
  static Future<http.Response> deleteProfilePicture() async {
    final url = Uri.parse('$baseUrl/profile/profile-picture');
    return await http.delete(url, headers: _headers());
  }
}