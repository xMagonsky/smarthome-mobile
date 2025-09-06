import 'package:flutter/material.dart';
import 'dart:convert';
import '../../features/devices/models/device.dart';
import '../services/api_service.dart';

class DeviceProvider extends ChangeNotifier {
  List<Device> devices = [];
  final ApiService _apiService = ApiService();

  DeviceProvider() {
    // Don't load devices automatically - wait for authentication
  }

  void loadDevices() async {
    try {
      final response = await _apiService.fetchDevices();
      if (response.statusCode == 200) {
        final List<dynamic> deviceData = jsonDecode(response.body);
        devices = deviceData.map((data) => Device(
          id: data['id'],
          name: data['name'],
          type: data['type'],
          state: data['state'],
          mqttTopic: data['mqtt_topic'],
          isFavorite: data['is_favorite'] ?? false,
          isOnline: data['is_online'] ?? true,
        )).toList();
      } else {
        // Handle error
        print('Failed to load devices: ${response.statusCode}');
      }
    } catch (e) {
      // Handle error
      print('Error loading devices: $e');
    }
    notifyListeners();
  }

  void addDevice(String name, String type) {
    final newDevice = Device(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      type: type,
      state: {'on': false},
      mqttTopic: 'devices/${DateTime.now().millisecondsSinceEpoch}/state',
    );
    devices.add(newDevice);
    notifyListeners();
  }

  void updateDevice(String id, String name, String type) {
    final index = devices.indexWhere((d) => d.id == id);
    if (index != -1) {
      devices[index] = devices[index].copyWith(
        name: name,
        type: type,
      );
      notifyListeners();
    }
  }

  void deleteDevice(String id) {
    devices.removeWhere((d) => d.id == id);
    notifyListeners();
  }

  Device? getDeviceById(String id) {
    try {
      return devices.firstWhere((d) => d.id == id);
    } catch (e) {
      return null;
    }
  }

  void toggleDevice(String id, bool isOn) {
    final index = devices.indexWhere((d) => d.id == id);
    if (index != -1) {
      final updatedState = Map<String, dynamic>.from(devices[index].state);
      updatedState['on'] = isOn;
      devices[index] = devices[index].copyWith(state: updatedState);
      notifyListeners();
      // In future: Call API to update real device
    }
  }

  void updateSensorValue(String id, String sensorType, dynamic value) {
    final index = devices.indexWhere((d) => d.id == id);
    if (index != -1) {
      final updatedState = Map<String, dynamic>.from(devices[index].state);
      updatedState[sensorType] = value;
      devices[index] = devices[index].copyWith(state: updatedState);
      notifyListeners();
      // In future: Call API to update real device
    }
  }

  void toggleFavorite(String id) {
    final index = devices.indexWhere((d) => d.id == id);
    if (index != -1) {
      devices[index] = devices[index].copyWith(isFavorite: !devices[index].isFavorite);
      notifyListeners();
    }
  }

  // Statistics getters
  int get onlineDevicesCount => devices.where((d) => d.isOnline).length;
  int get offlineDevicesCount => devices.where((d) => !d.isOnline).length;
  int get favoriteDevicesCount => devices.where((d) => d.isFavorite).length;
  List<Device> get favoriteDevices => devices.where((d) => d.isFavorite).toList();
  
  bool get allDevicesOk => devices.isEmpty || devices.every((d) => d.isOnline);
  int get alertsCount => devices.where((d) => !d.isOnline).length;
}