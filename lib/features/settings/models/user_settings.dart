class UserSettings {
  final String userName;
  final String email;
  final bool notificationsEnabled;
  final bool darkModeEnabled;
  final String language;
  final bool autoUpdateEnabled;
  final bool locationServicesEnabled;

  UserSettings({
    required this.userName,
    required this.email,
    this.notificationsEnabled = true,
    this.darkModeEnabled = false,
    this.language = 'en',
    this.autoUpdateEnabled = true,
    this.locationServicesEnabled = true,
  });

  UserSettings copyWith({
    String? userName,
    String? email,
    bool? notificationsEnabled,
    bool? darkModeEnabled,
    String? language,
    bool? autoUpdateEnabled,
    bool? locationServicesEnabled,
  }) {
    return UserSettings(
      userName: userName ?? this.userName,
      email: email ?? this.email,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      darkModeEnabled: darkModeEnabled ?? this.darkModeEnabled,
      language: language ?? this.language,
      autoUpdateEnabled: autoUpdateEnabled ?? this.autoUpdateEnabled,
      locationServicesEnabled: locationServicesEnabled ?? this.locationServicesEnabled,
    );
  }
}
