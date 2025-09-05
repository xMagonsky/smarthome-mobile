import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import 'dart:convert';

class AuthProvider with ChangeNotifier {
  bool _isAuthenticated = false;
  String? _token;

  bool get isAuthenticated => _isAuthenticated;
  String? get token => _token;

  final ApiService _apiService = ApiService();

  Future<void> checkAuthStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('jwt_token');
    if (_token != null) {
      _apiService.setToken(_token!);
      _isAuthenticated = true;
    }
    notifyListeners();
  }

  Future<bool> login(String username, String password) async {
    print("Login called with username: $username");
    try {
      final response = await _apiService.login(username, password);
      print("Login response: ${response.body}");
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        print("Login successful, token: ${jsonResponse['token']}");
        _token = jsonResponse['token'];
        _apiService.setToken(_token!);
        _isAuthenticated = true;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', _token!);
        notifyListeners();
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print("Login failed with error: $e");
      return false;
    }
  }

  Future<bool> register(String username, String password, String email) async {
    try {
      final response = await _apiService.register(username, password, email);
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        _token = jsonResponse['token'];
        _apiService.setToken(_token!);
        _isAuthenticated = true;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', _token!);
        notifyListeners();
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<void> logout() async {
    _token = null;
    _isAuthenticated = false;
    _apiService.setToken(null); // Clear token in API service
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    notifyListeners();
  }
}
