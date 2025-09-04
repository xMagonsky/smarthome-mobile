class UserSettings {
  final String userName;
  final String email;

  UserSettings({
    required this.userName,
    required this.email,
  });

  UserSettings copyWith({
    String? userName,
    String? email,
  }) {
    return UserSettings(
      userName: userName ?? this.userName,
      email: email ?? this.email,
    );
  }
}
