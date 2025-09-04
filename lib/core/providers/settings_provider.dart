import 'package:flutter/material.dart';
import '../../features/settings/models/user_settings.dart';

class SettingsProvider extends ChangeNotifier {
  UserSettings _settings = UserSettings(
    userName: 'John Doe',
    email: 'john.doe@example.com',
  );

  UserSettings get settings => _settings;

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
}
