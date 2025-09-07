# SmartHome Mobile

A Flutter application for managing smart home devices, automations, and user settings. It integrates with a REST API and MQTT broker for real‑time device state and command handling.

## Features

- Authentication (login/register) with token persisted in secure storage/preferences
- Device dashboard with online/offline status via MQTT
- Live device state updates via MQTT and command publishing
- Create, update, enable/disable, and delete automation rules

## Project structure (high level)

- `lib/main.dart` – App entry, routing, provider wiring
- `lib/core/constants/app_constants.dart` – API base URL and MQTT host
- `lib/core/services/` – REST (`api_service.dart`) and MQTT (`mqtt_service.dart`) clients
- `lib/core/providers/` – `AuthProvider`, `DeviceProvider`, `AutomationProvider`, `SettingsProvider`, `RuleProvider`
- `lib/features/` – UI and models per feature (home, devices, automation, settings, auth)

## Requirements

- Flutter (stable), Dart SDK >= 3.0
- A running backend exposing the endpoints listed below
- An MQTT broker (defaults to host `localhost`, port `1883`)

## Configure backend and MQTT

Edit `lib/core/constants/app_constants.dart` to match your environment:

```
class AppConstants {
	static const String appName = 'Smart Home';
	static const String apiBaseUrl = 'http://localhost:5069';
	static const String mqttBrokerHost = 'localhost';
}
```

## Install and run

1) Install dependencies

```powershell
flutter pub get
```

2) Launch for your target platform

- Android emulator or device:

```powershell
flutter devices; flutter run -d android
```

- Windows desktop:

```powershell
flutter config --enable-windows-desktop; flutter run -d windows
```

- Web (Chrome):

```powershell
flutter config --enable-web; flutter run -d chrome
```

## Build artifacts

- Android APK (release):

```powershell
flutter build apk --release
```

- Windows (release):

```powershell
flutter build windows --release
```

## Tech stack

- Flutter, Dart 3, provider, http, mqtt_client, shared_preferences, flutter_secure_storage, logger
