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
        // Handle error - for demo, load sample data
        print('Failed to load devices: ${response.statusCode}');
        _loadSampleDevices();
      }
    } catch (e) {
      // Handle error - for demo, load sample data
      print('Error loading devices: $e');
      _loadSampleDevices();
    }
    notifyListeners();
  }

  void _loadSampleDevices() {
    devices = [
      Device(
        id: '1',
        name: 'Lampa sypialnia',
        type: 'light',
        state: {'on': true},
        mqttTopic: 'devices/1/state',
        isFavorite: true,
        isOnline: true,
      ),
      Device(
        id: '2',
        name: 'Czujnik temperatury',
        type: 'sensor',
        state: {'temperature': 22.5, 'humidity': 45},
        mqttTopic: 'devices/2/state',
        isFavorite: false,
        isOnline: true,
      ),
      Device(
        id: '3',
        name: 'Smart TV',
        type: 'tv',
        state: {'on': false},
        mqttTopic: 'devices/3/state',
        isFavorite: true,
        isOnline: false,
      ),
      Device(
        id: '4',
        name: 'Klimatyzacja',
        type: 'climate',
        state: {'on': true, 'temperature': 24},
        mqttTopic: 'devices/4/state',
        isFavorite: false,
        isOnline: true,
      ),
      Device(
        id: '5',
        name: 'Żaluzje okienne',
        type: 'blinds',
        state: {'on': false, 'position': 50},
        mqttTopic: 'devices/5/state',
        isFavorite: true,
        isOnline: true,
      ),
    ];
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