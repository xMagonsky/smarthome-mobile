// Example usage of the new automation system

import 'package:flutter/material.dart';
import '../core/services/api_service.dart';

class AutomationExamples {
  static final ApiService _apiService = ApiService();

  // Example 1: Simple time-based automation
  static Future<void> createTimeBasedAutomation() async {
    final conditions = {
      'operator': 'AND',
      'children': [
        {
          'type': 'time',
          'op': '==',
          'value': '18:00',
        }
      ]
    };

    final actions = [
      {
        'action': 'set_state',
        'params': {'on': true},
        'device_id': 'living_room_light',
      }
    ];

    try {
      await _apiService.createAutomation(
        'Evening Lights',
        conditions,
        actions,
      );
      debugPrint('Time-based automation created successfully');
    } catch (e) {
      debugPrint('Error creating automation: $e');
    }
  }

  // Example 2: Sensor-based automation with multiple actions
  static Future<void> createTemperatureAutomation() async {
    final conditions = {
      'operator': 'AND',
      'children': [
        {
          'type': 'sensor',
          'op': '>',
          'value': 25,
          'key': 'temperature',
          'deviceId': 'outdoor_sensor',
          'minChange': 0.5,
        }
      ]
    };

    final actions = [
      {
        'action': 'set_state',
        'params': {'on': true},
        'device_id': 'air_conditioner',
      },
      {
        'action': 'set_temperature',
        'params': {'temperature': 20},
        'device_id': 'thermostat',
      },
      {
        'action': 'send_notification',
        'params': {
          'title': 'Temperature Alert',
          'message': 'Air conditioning turned on due to high temperature'
        },
        'device_id': '',
      }
    ];

    try {
      await _apiService.createAutomation(
        'Temperature Control',
        conditions,
        actions,
      );
      debugPrint('Temperature automation created successfully');
    } catch (e) {
      debugPrint('Error creating automation: $e');
    }
  }

  // Example 3: Complex nested conditions
  static Future<void> createComplexAutomation() async {
    final conditions = {
      'operator': 'AND',
      'children': [
        {
          'type': 'time',
          'op': '>',
          'value': '18:00',
        },
        {
          'operator': 'OR',
          'children': [
            {
              'type': 'sensor',
              'op': '<',
              'value': 10,
              'key': 'temperature',
              'deviceId': 'outdoor_sensor',
              'minChange': 1.0,
            },
            {
              'type': 'sensor',
              'op': '>',
              'value': 80,
              'key': 'humidity',
              'deviceId': 'humidity_sensor',
              'minChange': 5.0,
            }
          ]
        }
      ]
    };

    final actions = [
      {
        'action': 'set_state',
        'params': {'on': true},
        'device_id': 'heater',
      },
      {
        'action': 'delay',
        'params': {'seconds': 30},
        'device_id': '',
      },
      {
        'action': 'set_brightness',
        'params': {'brightness': 80},
        'device_id': 'living_room_light',
      }
    ];

    try {
      await _apiService.createAutomation(
        'Evening Climate Control',
        conditions,
        actions,
      );
      debugPrint('Complex automation created successfully');
    } catch (e) {
      debugPrint('Error creating automation: $e');
    }
  }

  // Example 4: Update existing automation
  static Future<void> updateAutomation(String automationId) async {
    final conditions = {
      'operator': 'AND',
      'children': [
        {
          'type': 'time',
          'op': '==',
          'value': '19:00', // Changed from 18:00 to 19:00
        }
      ]
    };

    final actions = [
      {
        'action': 'set_state',
        'params': {'on': true},
        'device_id': 'living_room_light',
      }
    ];

    try {
      await _apiService.updateAutomation(
        automationId,
        'Evening Lights (Updated)',
        conditions,
        actions,
      );
      debugPrint('Automation updated successfully');
    } catch (e) {
      debugPrint('Error updating automation: $e');
    }
  }

  // Example 5: List all automations
  static Future<void> listAutomations() async {
    try {
      final automations = await _apiService.getAutomations();
      debugPrint('Found ${automations.length} automations:');
      for (final automation in automations) {
        debugPrint('- ${automation.name} (${automation.enabled ? 'enabled' : 'disabled'})');
      }
    } catch (e) {
      debugPrint('Error fetching automations: $e');
    }
  }

  // Example 6: Toggle automation
  static Future<void> toggleAutomation(String automationId, bool enabled) async {
    try {
      await _apiService.toggleAutomation(automationId, enabled);
      debugPrint('Automation ${enabled ? 'enabled' : 'disabled'} successfully');
    } catch (e) {
      debugPrint('Error toggling automation: $e');
    }
  }

  // Example 7: Delete automation
  static Future<void> deleteAutomation(String automationId) async {
    try {
      await _apiService.deleteAutomation(automationId);
      debugPrint('Automation deleted successfully');
    } catch (e) {
      debugPrint('Error deleting automation: $e');
    }
  }
}
