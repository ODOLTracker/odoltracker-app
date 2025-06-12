import 'package:http/http.dart' as http;
import 'dart:convert';

class TollgateService {
  static const String baseUrl = "https://api.odltracker.my.id/v1"; // Base URL of your API

  // Get all tollgates with pagination (page and limit)
  static Future<http.Response> getTollgates({int page = 1, int limit = 10}) async {
    final url = Uri.parse('$baseUrl/tollgate?page=$page&limit=$limit');
    final response = await http.get(url);
    return response;
  }

  // Get a tollgate by its ID
  static Future<http.Response> getTollgateById(int tollgateId) async {
    final url = Uri.parse('$baseUrl/tollgate/$tollgateId');
    final response = await http.get(url);
    return response;
  }

  // Get tollgates managed by an operator
  static Future<http.Response> getManagedTollgates(int operatorId, {int page = 1, int limit = 10}) async {
    final url = Uri.parse('$baseUrl/tollgate/managed-tollgates/$operatorId?page=$page&limit=$limit');
    final response = await http.get(url);
    return response;
  }

  // Assign an operator to a tollgate
  static Future<http.Response> assignOperatorToTollgate(int tollgateId, int operatorId) async {
    final url = Uri.parse('$baseUrl/tollgate/$tollgateId/assign-operator/$operatorId');
    final response = await http.post(url);
    return response;
  }

  // Remove operator from tollgate
  static Future<http.Response> removeOperatorFromTollgate(int tollgateId, int operatorId) async {
    final url = Uri.parse('$baseUrl/tollgate/$tollgateId/remove-operator/$operatorId');
    final response = await http.delete(url);
    return response;
  }

  // Get location of a specific tollgate
  static Future<http.Response> getTollgateLocation(int tollgateId) async {
    final url = Uri.parse('$baseUrl/tollgate/$tollgateId/location');
    final response = await http.get(url);
    return response;
  }

  // Get analytics of a specific tollgate
  static Future<http.Response> getTollgateAnalytics(int tollgateId) async {
    final url = Uri.parse('$baseUrl/tollgate/$tollgateId/analytics');
    final response = await http.get(url);
    return response;
  }

  // Change operator of a tollgate
  static Future<http.Response> changeOperatorOfTollgate(int tollgateId, int operatorId) async {
    final url = Uri.parse('$baseUrl/tollgate/$tollgateId/operator');
    final response = await http.put(url, body: jsonEncode({'operatorId': operatorId}));
    return response;
  }

  // Get the operator of a tollgate
  static Future<http.Response> getTollgateOperator(int tollgateId) async {
    final url = Uri.parse('$baseUrl/tollgate/$tollgateId/operator');
    final response = await http.get(url);
    return response;
  }
}
