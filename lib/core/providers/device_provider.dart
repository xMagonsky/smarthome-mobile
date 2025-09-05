import 'package:flutter/material.dart';
import '../../features/devices/models/device.dart';
import '../services/api_service.dart';

class DeviceProvider extends ChangeNotifier {
  List<Device> devices = [];
  final ApiService _apiService = ApiService();

  DeviceProvider() {
    loadDevices();
  }

  void loadDevices() async {
    try {
      final response = await _apiService.fetchDevices();
      if (response.statusCode == 200) {
        // Parse the response and update devices
        // For now, keep mock data
        devices = [
          Device(id: '1', name: 'Living Room Light', type: 'light'),
          Device(id: '2', name: 'Kitchen Plug', type: 'plug'),
          Device(
            id: '3',
            name: 'Bedroom Thermostat',
            type: 'thermostat',
            sensorValues: {'temperature': 22.5, 'humidity': 45},
          ),
          Device(
            id: '4',
            name: 'Outdoor Temperature Sensor',
            type: 'sensor',
            sensorValues: {'temperature': 18.0},
          ),
        ];
      }
    } catch (e) {
      // Handle error
    }
    notifyListeners();
  }

  void addDevice(String name, String type, {Map<String, dynamic>? sensorValues}) {
    final newDevice = Device(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      type: type,
      sensorValues: sensorValues,
    );
    devices.add(newDevice);
    notifyListeners();
  }

  void updateDevice(String id, String name, String type, {Map<String, dynamic>? sensorValues}) {
    final index = devices.indexWhere((d) => d.id == id);
    if (index != -1) {
      devices[index] = Device(
        id: id,
        name: name,
        isOn: devices[index].isOn,
        type: type,
        sensorValues: sensorValues ?? devices[index].sensorValues,
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
      devices[index] = Device(
        id: id,
        name: devices[index].name,
        isOn: isOn,
        type: devices[index].type,
        sensorValues: devices[index].sensorValues,
      );
      notifyListeners();
      // In future: Call API to update real device
    }
  }

  void updateSensorValue(String id, String sensorType, dynamic value) {
    final index = devices.indexWhere((d) => d.id == id);
    if (index != -1) {
      final currentValues = devices[index].sensorValues ?? {};
      currentValues[sensorType] = value;
      devices[index] = Device(
        id: id,
        name: devices[index].name,
        isOn: devices[index].isOn,
        type: devices[index].type,
        sensorValues: currentValues,
      );
      notifyListeners();
      // In future: Call API to update real device
    }
  }
}