import 'package:http/http.dart' as http;
import 'dart:convert';
import '../constants/app_constants.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  String? _token;

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

  Future<http.Response> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('${AppConstants.apiBaseUrl}/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );
    return response;
  }

  Future<http.Response> register(String username, String password, String email) async {
    final response = await http.post(
      Uri.parse('${AppConstants.apiBaseUrl}/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password, 'email': email}),
    );
    return response;
  }
}