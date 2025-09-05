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
      devices[index] = Device(
        id: id,
        name: name,
        type: type,
        state: devices[index].state,
        mqttTopic: devices[index].mqttTopic,
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
      devices[index] = Device(
        id: id,
        name: devices[index].name,
        type: devices[index].type,
        state: updatedState,
        mqttTopic: devices[index].mqttTopic,
      );
      notifyListeners();
      // In future: Call API to update real device
    }
  }

  void updateSensorValue(String id, String sensorType, dynamic value) {
    final index = devices.indexWhere((d) => d.id == id);
    if (index != -1) {
      final updatedState = Map<String, dynamic>.from(devices[index].state);
      updatedState[sensorType] = value;
      devices[index] = Device(
        id: id,
        name: devices[index].name,
        type: devices[index].type,
        state: updatedState,
        mqttTopic: devices[index].mqttTopic,
      );
      notifyListeners();
      // In future: Call API to update real device
    }
  }
}