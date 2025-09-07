import 'package:flutter/material.dart';

class DeviceIcons {
  static IconData getIconForDeviceType(String type) {
    switch (type.toLowerCase()) {
      case 'light':
      case 'lamp':
      case 'bulb':
        return Icons.lightbulb;
      case 'switch':
        return Icons.toggle_on;
      case 'sensor':
      case 'temperature':
        return Icons.sensors;
      case 'thermostat':
        return Icons.thermostat;
      case 'camera':
        return Icons.camera_alt;
      case 'speaker':
      case 'audio':
        return Icons.speaker;
      case 'tv':
      case 'television':
        return Icons.tv;
      case 'door':
      case 'lock':
        return Icons.door_front_door;
      case 'window':
        return Icons.window;
      case 'fan':
        return Icons.air;
      case 'ac':
      case 'air_conditioning':
        return Icons.ac_unit;
      case 'heater':
        return Icons.local_fire_department;
      case 'security':
        return Icons.security;
      case 'motion':
        return Icons.directions_walk;
      case 'smoke':
        return Icons.smoke_free;
      case 'water':
        return Icons.water_drop;
      case 'garage':
        return Icons.garage;
      case 'router':
      case 'wifi':
        return Icons.wifi;
      case 'plug':
      case 'outlet':
        return Icons.power;
      default:
        return Icons.device_unknown;
    }
  }

  static Color getColorForDeviceType(String type,
      {bool isOn = false, bool isOnline = true}) {
    if (!isOnline) return Colors.grey;

    switch (type.toLowerCase()) {
      case 'light':
      case 'lamp':
      case 'bulb':
        return isOn ? Colors.amber : Colors.grey;
      case 'sensor':
      case 'temperature':
        return Colors.blue;
      case 'thermostat':
        return isOn ? Colors.orange : Colors.grey;
      case 'camera':
        return isOn ? Colors.green : Colors.grey;
      case 'speaker':
      case 'audio':
        return isOn ? Colors.purple : Colors.grey;
      case 'tv':
      case 'television':
        return isOn ? Colors.indigo : Colors.grey;
      case 'door':
      case 'lock':
        return isOn ? Colors.red : Colors.green;
      case 'fan':
        return isOn ? Colors.lightBlue : Colors.grey;
      case 'ac':
      case 'air_conditioning':
        return isOn ? Colors.cyan : Colors.grey;
      case 'heater':
        return isOn ? Colors.deepOrange : Colors.grey;
      case 'security':
        return isOn ? Colors.green : Colors.red;
      case 'motion':
        return Colors.orange;
      case 'smoke':
        return Colors.red;
      case 'water':
        return Colors.blue;
      default:
        return isOn ? Colors.green : Colors.grey;
    }
  }
}
