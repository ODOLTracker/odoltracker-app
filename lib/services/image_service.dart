import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/vehicle_image.dart';
import 'auth_service.dart';

class ImageService {
  static const String baseUrl = 'https://api.odltracker.my.id/v1';

  static Map<String, String> _getHeaders() {
    final token = AuthService.token;
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // // Get all images
  // static Future<http.Response> getImages({int page = 1, int limit = 10}) async {
  //   final url = Uri.parse('$baseUrl/images?page=$page&limit=$limit');
  //   final response = await http.get(url);
  //   return response;
  // }

  // Get image by ID
  static Future<http.Response> getImageById(String id) async {
    final url = Uri.parse('$baseUrl/images/$id');
    final response = await http.get(url);
    return response;
  }

  // Create a new image
  static Future<http.Response> createImage({
    required String detectionID,
    required String imageURL,
    required String cloudinaryPublicID,
    required String verificationStatus,
  }) async {
    final url = Uri.parse('$baseUrl/images');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'detectionID': detectionID,
        'imageURL': imageURL,
        'cloudinaryPublicID': cloudinaryPublicID,
        'verificationStatus': verificationStatus,
      }),
    );
    return response;
  }

  // Update image by ID
  static Future<http.Response> updateImage({
    required String id,
    required String detectionID,
    required String imageURL,
    required String cloudinaryPublicID,
    required String verificationStatus,
  }) async {
    final url = Uri.parse('$baseUrl/images/$id');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'detectionID': detectionID,
        'imageURL': imageURL,
        'cloudinaryPublicID': cloudinaryPublicID,
        'verificationStatus': verificationStatus,
      }),
    );
    return response;
  }

  // Delete image by ID and cloudinaryPublicID
  static Future<http.Response> deleteImage(String id) async {
    final url = Uri.parse('$baseUrl/images/$id');
    final response = await http.delete(url);
    return response;
  }

  // Upload a new image to Cloudinary
  static Future<http.Response> uploadImage({
    required String detectionID,
    required String imagePath, // Path to the local image
  }) async {
    final url = Uri.parse('$baseUrl/images/upload');
    final request = http.MultipartRequest('POST', url)
      ..fields['detectionID'] = detectionID
      ..files.add(await http.MultipartFile.fromPath('file', imagePath));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    return response;
  }

  // // Verify image by ID
  // static Future<http.Response> verifyImage(String id) async {
  //   final url = Uri.parse('$baseUrl/images/$id/verify');
  //   final response = await http.get(url);
  //   return response;
  // }

  // Reject image by ID
  static Future<http.Response> rejectImage(String id) async {
    final url = Uri.parse('$baseUrl/images/$id/reject');
    final response = await http.get(url);
    return response;
  }

  // Get all verified images by detectionID
  static Future<http.Response> getVerifiedImages(String detectionID,
      {int page = 1, int limit = 10}) async {
    final url = Uri.parse('$baseUrl/images/$detectionID/verified?page=$page&limit=$limit');
    final response = await http.get(url);
    return response;
  }

  // Get all unverified images by detectionID
  static Future<http.Response> getUnverifiedImages(String detectionID,
      {int page = 1, int limit = 10}) async {
    final url = Uri.parse('$baseUrl/images/$detectionID/unverified?page=$page&limit=$limit');
    final response = await http.get(url);
    return response;
  }

  // Get all rejected images by detectionID
  static Future<http.Response> getRejectedImages(String detectionID,
      {int page = 1, int limit = 10}) async {
    final url = Uri.parse('$baseUrl/images/$detectionID/rejected?page=$page&limit=$limit');
    final response = await http.get(url);
    return response;
  }

  // Get the first unverified image for a detection
  static Future<http.Response> getCurrentImageToVerify(String detectionID) async {
    final url = Uri.parse('$baseUrl/images/$detectionID/current-image-to-verify');
    final response = await http.get(url);
    return response;
  }

  // Get the next unverified image for a detection
  static Future<http.Response> getNextImageToVerify(String detectionID) async {
    final url = Uri.parse('$baseUrl/images/$detectionID/next-image-to-verify');
    final response = await http.get(url);
    return response;
  }

  static Future<Map<String, dynamic>> getImages({
    int page = 1, 
    int limit = 10,
    String? status
  }) async {
    final url = Uri.parse(
      '$baseUrl/image?page=$page&limit=$limit${status != null ? '&status=$status' : ''}'
    );
    final response = await http.get(url, headers: _getHeaders());

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<VehicleImage> images = (data['images'] as List)
          .map((json) => VehicleImage.fromJson(json))
          .toList();

      return {
        'images': images,
        'totalPages': data['totalPages'],
        'currentPage': data['currentPage'],
        'totalImages': data['totalImages'],
      };
    } else {
      throw Exception('Failed to load images: ${response.statusCode} - ${response.body}');
    }
  }

  static Future<bool> verifyImage(int imageId, String status) async {
    final endpoint = status == 'Verified' ? 'verify' : 'reject';
    final url = Uri.parse('$baseUrl/image/$imageId/$endpoint');
    final response = await http.get(
      url,
      headers: _getHeaders(),
    );

    print('Verify Response Status: ${response.statusCode}');
    print('Verify Response Body: ${response.body}');

    return response.statusCode == 200;
  }
}