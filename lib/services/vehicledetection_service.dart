import 'dart:convert';
import 'package:http/http.dart' as http;

class VehicleDetectionService {
  static const String baseUrl = "https://api.odltracker.my.id/v1"; // Base URL

  // Get all vehicle detections
  static Future<http.Response> getAllVehicleDetections({int page = 1, int limit = 10}) async {
    final url = Uri.parse('$baseUrl/vehicledetection?page=$page&limit=$limit');
    final response = await http.get(url);
    return response;
  }

  // Get vehicle detection by ID
  static Future<http.Response> getVehicleDetectionById(String id) async {
    final url = Uri.parse('$baseUrl/vehicledetection/$id');
    final response = await http.get(url);
    return response;
  }

  // Create a new vehicle detection
  static Future<http.Response> createVehicleDetection({
    required String vehicleType,
    required String detectionDateTime,
    required String status,
    required String tollGateID,
  }) async {
    final url = Uri.parse('$baseUrl/vehicledetection');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'vehicleType': vehicleType,
        'detectionDateTime': detectionDateTime,
        'status': status,
        'tollGateID': tollGateID,
      }),
    );
    return response;
  }

  // Update vehicle detection
  static Future<http.Response> updateVehicleDetection({
    required String id,
    required String vehicleType,
    required String detectionDateTime,
    required String status,
    required String tollGateID,
  }) async {
    final url = Uri.parse('$baseUrl/vehicledetection/$id');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'vehicleType': vehicleType,
        'detectionDateTime': detectionDateTime,
        'status': status,
        'tollGateID': tollGateID,
      }),
    );
    return response;
  }

  // Delete vehicle detection
  static Future<http.Response> deleteVehicleDetection(String id) async {
    final url = Uri.parse('$baseUrl/vehicledetection/$id');
    final response = await http.delete(url);
    return response;
  }

  // Get overdimension vehicle detections by tollgateId
  static Future<http.Response> getOverdimensionVehicleDetections(int tollgateId, {int page = 1, int limit = 10}) async {
    final url = Uri.parse('$baseUrl/vehicledetection/$tollgateId/overdimension?page=$page&limit=$limit');
    final response = await http.get(url);
    return response;
  }

  // Get normal vehicle detections by tollgateId
  static Future<http.Response> getNormalVehicleDetections(int tollgateId, {int page = 1, int limit = 10}) async {
    final url = Uri.parse('$baseUrl/vehicledetection/$tollgateId/normal?page=$page&limit=$limit');
    final response = await http.get(url);
    return response;
  }

  // Get daily vehicle detection count by tollgateId
  static Future<http.Response> getDailyVehicleDetectionCount(String tollgateId) async {
    final url = Uri.parse('$baseUrl/vehicledetection/daily-count/$tollgateId');
    final response = await http.get(url);
    return response;
  }

  // Get vehicle detection count by date range
  static Future<http.Response> getVehicleDetectionCountByDateRange(String tollgateId, {required String startDate, required String endDate}) async {
    final url = Uri.parse('$baseUrl/vehicledetection/date-range-count/$tollgateId?startDate=$startDate&endDate=$endDate');
    final response = await http.get(url);
    return response;
  }

  // Get vehicle detection by vehicle type
  static Future<http.Response> getVehicleDetectionByVehicleType(String tollgateId, String vehicleType, {int page = 1, int limit = 10}) async {
    final url = Uri.parse('$baseUrl/vehicledetection/$vehicleType/$tollgateId?page=$page&limit=$limit');
    final response = await http.get(url);
    return response;
  }

  // Get vehicle detection count by vehicle type
  static Future<http.Response> getVehicleDetectionCountByVehicleType(String tollgateId, String vehicleType) async {
    final url = Uri.parse('$baseUrl/vehicledetection/$vehicleType/$tollgateId/count');
    final response = await http.get(url);
    return response;
  }
}
