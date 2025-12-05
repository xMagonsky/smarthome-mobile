import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:logger/logger.dart';
import '../constants/app_constants.dart';
import '../../features/automation/models/rule.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  String? _token;
  String? _agentId;
  bool _useRemote = false;
  final Logger _logger = Logger();

  factory ApiService() {
    return _instance;
  }

  ApiService._internal();

  void setToken(String? token) {
    _token = token;
  }

  void setAgentId(String? agentId) {
    _agentId = agentId;
  }

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': '$_token',
        if (_useRemote && _agentId != null) 'X-Server-ID': _agentId!,
      };

  Future<http.Response> _makeRequest(
    Future<http.Response> Function(String url) request,
  ) async {
    try {
      _useRemote = false;
      final response = await request(AppConstants.apiBaseUrl).timeout(
        const Duration(seconds: 5),
      );
      return response;
    } catch (e) {
      _logger.w('Local connection failed, trying remote: $e');
      _useRemote = true;
      try {
        final response = await request(AppConstants.remoteApiBaseUrl);
        if (response.statusCode >= 400) {
          _logger.e('Remote server returned error ${response.statusCode}. Agent ID: ${_agentId ?? "not set"}. Response: ${response.body}');
          print('Remote server error ${response.statusCode}. Agent ID used: ${_agentId ?? "not set"}. Response: ${response.body}');
        }
        return response;
      } catch (remoteError) {
        _logger.e('Remote connection also failed: $remoteError. Agent ID: ${_agentId ?? "not set"}');
        rethrow;
      }
    }
  }

  Future<http.Response> fetchDevices() async {
    return _makeRequest((baseUrl) => http.get(
      Uri.parse('$baseUrl/devices'),
      headers: _headers,
    ));
  }

  Future<http.Response> setDeviceOwner(String deviceId) async {
    return _makeRequest((baseUrl) => http.patch(
      Uri.parse('$baseUrl/devices/$deviceId/setowner'),
      headers: _headers,
    ));
  }

  /// Fetch the currently authenticated user's profile
  /// Expected to return JSON with at least name/username and email fields
  Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      final response = await _makeRequest((baseUrl) => http.get(
        Uri.parse('$baseUrl/users/me'),
        headers: _headers,
      ));

      if (response.statusCode == 200) {
        final dynamic data = json.decode(response.body);
        if (data is Map<String, dynamic>) {
          return data;
        } else {
          throw const FormatException('Invalid /users/me response format');
        }
      } else {
        throw HttpException(
            'Failed to fetch current user: ${response.statusCode}');
      }
    } catch (e) {
      _logger.e('Error fetching current user: $e');
      throw Exception('Failed to fetch current user: $e');
    }
  }

  Future<http.Response> login(String username, String password) async {
    print("API Service: Attempting login for $username");
    try {
      final response = await _makeRequest((baseUrl) => http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: _headers,
        body: jsonEncode({
          'username': username, 
          'password': password,
        }),
      ));
      print("API Service: Login response status: ${response.statusCode}");
      return response;
    } catch (e) {
      print("API Service: Login failed with error: $e");
      rethrow;
    }
  }

  Future<http.Response> register(
      String username, String password, String email) async {
    final response = await _makeRequest((baseUrl) => http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: _headers,
      body: jsonEncode({
        'username': username, 
        'password': password, 
        'email': email,
      }),
    ));
    return response;
  }

  Future<http.Response> fetchAutomationRules() async {
    return _makeRequest((baseUrl) => http.get(
      Uri.parse('$baseUrl/automations/rules'),
      headers: _headers,
    ));
  }

  Future<List<Rule>> getAutomations() async {
    try {
      final response = await _makeRequest((baseUrl) => http.get(
        Uri.parse('$baseUrl/automations/rules'),
        headers: _headers,
      ));

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
      final response = await _makeRequest((baseUrl) => http.post(
        Uri.parse('$baseUrl/automations/rules'),
        headers: _headers,
        body: json.encode({
          'name': name,
          'conditions': conditions,
          'actions': actions,
          'enabled': true,
        }),
      ));

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
      final response = await _makeRequest((baseUrl) => http.patch(
        Uri.parse('$baseUrl/automations/rules/$id'),
        headers: _headers,
        body: json.encode({
          'name': name,
          'conditions': conditions,
          'actions': actions,
        }),
      ));

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
      final response = await _makeRequest((baseUrl) => http.delete(
        Uri.parse('$baseUrl/automations/rules/$id'),
        headers: _headers,
      ));

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
      final response = await _makeRequest((baseUrl) => http.patch(
        Uri.parse('$baseUrl/automations/rules/$id'),
        headers: _headers,
        body: json.encode({'enabled': enabled}),
      ));

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
