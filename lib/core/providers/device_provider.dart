import 'package:flutter/material.dart';
import '../../features/devices/models/device.dart';

class DeviceProvider extends ChangeNotifier {
  List<Device> devices = [];

  DeviceProvider() {
    loadDevices();
  }

  void loadDevices() {
    // Mock data; replace with repository call in future
    devices = [
      Device(id: '1', name: 'Living Room Light', type: 'light'),
      Device(id: '2', name: 'Kitchen Plug', type: 'plug'),
      Device(id: '3', name: 'Bedroom Thermostat', type: 'thermostat'),
    ];
    notifyListeners();
  }

  void addDevice(String name, String type) {
    final newDevice = Device(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      type: type,
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
        isOn: devices[index].isOn,
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
    return devices.firstWhere((d) => d.id == id);
  }

  void toggleDevice(String id, bool isOn) {
    final index = devices.indexWhere((d) => d.id == id);
    if (index != -1) {
      devices[index] = Device(
        id: id,
        name: devices[index].name,
        isOn: isOn,
        type: devices[index].type,
      );
      notifyListeners();
      // In future: Call API to update real device
    }
  }
}