import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:logger/logger.dart';
import '../constants/app_constants.dart';
import '../../features/automation/models/rule.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  String? _token;
  final Logger _logger = Logger();

  factory ApiService() {
    return _instance;
  }

  ApiService._internal();

  void setToken(String? token) {
    _token = token;
  }

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': '$_token',
      };

  Future<http.Response> fetchDevices() async {
    return http.get(
      Uri.parse('${AppConstants.apiBaseUrl}/devices'),
      headers: _headers,
    );
  }

  Future<http.Response> setDeviceOwner(String deviceId) async {
    return http.patch(
      Uri.parse('${AppConstants.apiBaseUrl}/devices/$deviceId/setowner'),
      headers: _headers,
    );
  }

  Future<http.Response> login(String username, String password) async {
    print("API Service: Attempting login for $username");
    try {
      final response = await http.post(
        Uri.parse('${AppConstants.apiBaseUrl}/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );
      print("API Service: Login response status: ${response.statusCode}");
      return response;
    } catch (e) {
      print("API Service: Login failed with error: $e");
      rethrow;
    }
  }

  Future<http.Response> register(
      String username, String password, String email) async {
    final response = await http.post(
      Uri.parse('${AppConstants.apiBaseUrl}/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(
          {'username': username, 'password': password, 'email': email}),
    );
    return response;
  }

  Future<http.Response> fetchAutomationRules() async {
    return http.get(
      Uri.parse('${AppConstants.apiBaseUrl}/automations/rules'),
      headers: _headers,
    );
  }

  Future<List<Rule>> getAutomations() async {
    try {
      final response = await http.get(
        Uri.parse('${AppConstants.apiBaseUrl}/automations/rules'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => Rule.fromJson(item)).toList();
      } else {
        throw HttpException(
            'Failed to fetch automations: ${response.statusCode}');
      }
    } catch (e) {
      _logger.e('Error fetching automations: $e');
      throw Exception('Failed to fetch automations: $e');
    }
  }

  Future<Rule> createAutomation(String name, Map<String, dynamic> conditions,
      List<Map<String, dynamic>> actions) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConstants.apiBaseUrl}/automations/rules'),
        headers: _headers,
        body: json.encode({
          'name': name,
          'conditions': conditions,
          'actions': actions,
          'enabled': true,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return Rule.fromJson(json.decode(response.body));
      } else {
        throw HttpException(
            'Failed to create automation: ${response.statusCode}');
      }
    } catch (e) {
      _logger.e('Error creating automation: $e');
      throw Exception('Failed to create automation: $e');
    }
  }

  Future<Rule> updateAutomation(
      String id,
      String name,
      Map<String, dynamic> conditions,
      List<Map<String, dynamic>> actions) async {
    try {
      final response = await http.patch(
        Uri.parse('${AppConstants.apiBaseUrl}/automations/rules/$id'),
        headers: _headers,
        body: json.encode({
          'name': name,
          'conditions': conditions,
          'actions': actions,
        }),
      );

      if (response.statusCode == 200) {
        return Rule.fromJson(json.decode(response.body));
      } else {
        throw HttpException(
            'Failed to update automation: ${response.statusCode}');
      }
    } catch (e) {
      _logger.e('Error updating automation: $e');
      throw Exception('Failed to update automation: $e');
    }
  }

  Future<void> deleteAutomation(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('${AppConstants.apiBaseUrl}/automations/rules/$id'),
        headers: _headers,
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw HttpException(
            'Failed to delete automation: ${response.statusCode}');
      }
    } catch (e) {
      _logger.e('Error deleting automation: $e');
      throw Exception('Failed to delete automation: $e');
    }
  }

  Future<void> toggleAutomation(String id, bool enabled) async {
    try {
      final response = await http.patch(
        Uri.parse('${AppConstants.apiBaseUrl}/automations/rules/$id'),
        headers: _headers,
        body: json.encode({'enabled': enabled}),
      );

      if (response.statusCode != 200) {
        throw HttpException(
            'Failed to toggle automation: ${response.statusCode}');
      }
    } catch (e) {
      _logger.e('Error toggling automation: $e');
      throw Exception('Failed to toggle automation: $e');
    }
  }
}
