import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  bool _isAuthenticated = false;
  String? _token;

  bool get isAuthenticated => _isAuthenticated;
  String? get token => _token;

  final ApiService _apiService = ApiService();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  Future<void> checkAuthStatus() async {
    _token = await _secureStorage.read(key: 'jwt_token');
    if (_token != null) {
      _apiService.setToken(_token!);
      _isAuthenticated = true;
    }
    notifyListeners();
  }

  Future<bool> login(String username, String password) async {
    try {
      final response = await _apiService.login(username, password);
      if (response.statusCode == 200) {
        _token = response.body.trim(); // Assuming the token is in the response body
        _apiService.setToken(_token!);
        _isAuthenticated = true;
        await _secureStorage.write(key: 'jwt_token', value: _token);
        notifyListeners();
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<bool> register(String username, String password, String email) async {
    try {
      final response = await _apiService.register(username, password, email);
      if (response.statusCode == 200) {
        _token = response.body.trim(); // Assuming the token is in the response body
        _apiService.setToken(_token!);
        _isAuthenticated = true;
        await _secureStorage.write(key: 'jwt_token', value: _token);
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
    await _secureStorage.delete(key: 'jwt_token');
    notifyListeners();
  }
}
