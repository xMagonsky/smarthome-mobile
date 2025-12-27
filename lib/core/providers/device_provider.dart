import 'package:flutter/material.dart';
import 'dart:convert';
import '../../features/devices/models/device.dart';
import '../services/api_service.dart';
import '../services/mqtt_service.dart';

class DeviceProvider extends ChangeNotifier {
  List<Device> devices = [];
  final ApiService _apiService = ApiService();
  late MqttService _mqttService;

  DeviceProvider() {
    _mqttService = MqttService(
      onDeviceStatusChanged: updateDeviceOnlineStatus,
      onDeviceStateChanged: _mergeDeviceStateFromMqtt,
    );
    _mqttService.connect();
    // Don't load devices automatically - wait for authentication
  }

  void updateDeviceOnlineStatus(String mqttTopic, bool isOnline) {
    final index = devices.indexWhere((d) => d.mqttTopic == mqttTopic);
    if (index != -1) {
      if (devices[index].isOnline != isOnline) {
        devices[index] = devices[index].copyWith(isOnline: isOnline);
        notifyListeners();
      }
    }
  }

  void _mergeDeviceStateFromMqtt(
      String mqttTopicBase, Map<String, dynamic> newState) {
    final index = devices.indexWhere((d) => d.mqttTopic == mqttTopicBase);
    if (index != -1) {
      // Merge incoming state keys into existing state map
      final updatedState = Map<String, dynamic>.from(devices[index].state);
      updatedState.addAll(newState);
      devices[index] = devices[index].copyWith(state: updatedState);
      notifyListeners();
    }
  }

  void loadDevices() async {
    // Unsubscribe from old topics before fetching new list
    final oldTopics = devices.map((d) => d.mqttTopic).toList();
    if (oldTopics.isNotEmpty) {
      _mqttService.unsubscribeFromTopics(oldTopics);
    }

    try {
      final response = await _apiService.fetchDevices();
      if (response.statusCode == 200) {
        final List<dynamic> deviceData = jsonDecode(response.body);
        devices = deviceData
            .map((data) => Device(
                  id: data['id'],
                  name: data['name'],
                  type: data['type'],
                  state: data['state'],
                  mqttTopic: data['mqtt_topic'],
                  isOnline: data['is_online'] ?? true,
                ))
            .toList();

        final newTopics = devices.map((d) => d.mqttTopic).toList();
        if (newTopics.isNotEmpty) {
          _mqttService.subscribeToTopics(newTopics);
        }
      } else {
        print('Failed to load devices: ${response.statusCode}');
      }
    } catch (e) {
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

  void toggleDevice(String id, bool isOn) async {
    final index = devices.indexWhere((d) => d.id == id);
    if (index != -1) {
      final updatedState = Map<String, dynamic>.from(devices[index].state);
      updatedState['on'] = isOn;
      devices[index] = devices[index].copyWith(state: updatedState);
      notifyListeners();
      
      // Use HTTP in remote mode, MQTT in local mode
      if (_apiService.isRemoteMode) {
        try {
          await _apiService.sendDeviceCommand(devices[index].id, {'on': isOn});
        } catch (e) {
          print('Failed to send HTTP command: $e');
        }
      } else {
        final topicBase = devices[index].mqttTopic;
        _mqttService.publishCommand(topicBase, {'on': isOn});
      }
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

  // Statistics getters
  int get onlineDevicesCount => devices.where((d) => d.isOnline).length;
  int get offlineDevicesCount => devices.where((d) => !d.isOnline).length;
  bool get allDevicesOk => devices.isEmpty || devices.every((d) => d.isOnline);
  int get alertsCount => devices.where((d) => !d.isOnline).length;

  // Expose helpers for detail page to subscribe/unsubscribe to a specific device state topic
  void subscribeToDeviceState(Device device) {
    _mqttService.subscribeToStateTopic(device.mqttTopic);
  }

  void unsubscribeFromDeviceState(Device device) {
    _mqttService.unsubscribeFromStateTopic(device.mqttTopic);
  }

  // Publish a boolean command for a specific state entry, e.g., { '<entry>': true/false }
  void publishStateToggle(Device device, String stateKey, bool value) async {
    // Optimistic UI update
    final index = devices.indexWhere((d) => d.id == device.id);
    if (index != -1) {
      final updatedState = Map<String, dynamic>.from(devices[index].state);
      updatedState[stateKey] = value;
      devices[index] = devices[index].copyWith(state: updatedState);
      notifyListeners();
    }
    
    // Use HTTP in remote mode, MQTT in local mode
    if (_apiService.isRemoteMode) {
      try {
        await _apiService.sendDeviceCommand(device.id, {stateKey: value});
      } catch (e) {
        print('Failed to send HTTP command: $e');
      }
    } else {
      _mqttService.publishCommand(device.mqttTopic, {stateKey: value});
    }
  }
}
