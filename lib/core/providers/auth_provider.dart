import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import 'dart:convert';

class AuthProvider with ChangeNotifier {
  bool _isAuthenticated = false;
  String? _token;
  String? _agentId;

  bool get isAuthenticated => _isAuthenticated;
  String? get token => _token;
  String? get agentId => _agentId;

  final ApiService _apiService = ApiService();

  Future<void> checkAuthStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('jwt_token');
    _agentId = prefs.getString('agent_id');
    if (_token != null) {
      _apiService.setToken(_token!);
      if (_agentId != null) {
        _apiService.setAgentId(_agentId!);
      }
      _isAuthenticated = true;
    }
    notifyListeners();
  }

  Future<bool> login(String username, String password) async {
    print("Login called with username: $username");
    
    // Load agent ID from preferences before login attempt (needed for remote connection)
    final prefs = await SharedPreferences.getInstance();
    final savedAgentId = prefs.getString('agent_id');
    if (savedAgentId != null) {
      _agentId = savedAgentId;
      _apiService.setAgentId(_agentId!);
      print("Agent ID loaded from prefs for login: $_agentId");
    }
    
    try {
      final response = await _apiService.login(username, password);
      print("Login response: ${response.body}");
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        print("Login successful, token: ${jsonResponse['token']}");
        _token = jsonResponse['token'];
        
        // Update agent_id if provided in response
        if (jsonResponse.containsKey('agent_id') && jsonResponse['agent_id'] != null) {
          _agentId = jsonResponse['agent_id'];
          print("Agent ID received: $_agentId");
        }
        
        _apiService.setToken(_token!);
        if (_agentId != null) {
          _apiService.setAgentId(_agentId!);
        }
        _isAuthenticated = true;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', _token!);
        if (_agentId != null) {
          await prefs.setString('agent_id', _agentId!);
        }
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
      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        _token = jsonResponse['token'];
        
        // Update agent_id if provided in response
        if (jsonResponse.containsKey('agent_id') && jsonResponse['agent_id'] != null) {
          _agentId = jsonResponse['agent_id'];
          print("Agent ID received: $_agentId");
        }
        
        _apiService.setToken(_token!);
        if (_agentId != null) {
          _apiService.setAgentId(_agentId!);
        }
        _isAuthenticated = true;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', _token!);
        if (_agentId != null) {
          await prefs.setString('agent_id', _agentId!);
        }
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
    _agentId = null;
    _isAuthenticated = false;
    _apiService.setToken(null); // Clear token in API service
    //_apiService.setAgentId(null); // Clear agent ID in API service
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    //await prefs.remove('agent_id');
    notifyListeners();
  }
}
