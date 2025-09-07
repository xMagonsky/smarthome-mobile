import 'package:flutter/material.dart';
import '../../features/settings/models/user_settings.dart';
import '../services/api_service.dart';

class SettingsProvider extends ChangeNotifier {
  final ApiService _api = ApiService();
  UserSettings _settings = UserSettings(
    userName: 'John Doe',
    email: 'john.doe@example.com',
  );
  bool _loading = false;
  String? _error;

  UserSettings get settings => _settings;
  bool get isLoading => _loading;
  String? get error => _error;

  void updateSettings(UserSettings newSettings) {
    _settings = newSettings;
    notifyListeners();
    // In future: Save to local storage/API
  }

  void updateUserName(String userName) {
    _settings = _settings.copyWith(userName: userName);
    notifyListeners();
  }

  void updateEmail(String email) {
    _settings = _settings.copyWith(email: email);
    notifyListeners();
  }

  /// Loads the current user's profile from the backend and updates settings
  Future<void> loadUserProfile() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final me = await _api.getCurrentUser();
      // Common field names: name or username, and email
      final String name =
          (me['name'] ?? me['username'] ?? _settings.userName).toString();
      final String email = (me['email'] ?? _settings.email).toString();
      _settings = _settings.copyWith(userName: name, email: email);
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
