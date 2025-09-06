// Type Safety Test for Automation System

import 'package:flutter/material.dart';
import '../features/automation/widgets/automation_preview.dart';

class AutomationTypeSafetyTest {
  // Test data with various data types to ensure type safety
  static Map<String, dynamic> getTestConditions() {
    return {
      'operator': 'AND',
      'children': [
        {
          'type': 'sensor',
          'op': '>',
          'value': 25, // Integer value
          'key': 'temperature',
          'deviceId': 'sensor1',
          'minChange': 0.5, // Double value
        },
        {
          'type': 'time',
          'op': '==',
          'value': '18:00', // String value
        },
        {
          'type': 'device',
          'value': true, // Boolean value
          'deviceId': 'device1',
        }
      ]
    };
  }

  static List<Map<String, dynamic>> getTestActions() {
    return [
      {
        'action': 'set_state',
        'params': {
          'on': true, // Boolean
        },
        'device_id': 'light1',
      },
      {
        'action': 'set_brightness',
        'params': {
          'brightness': 80, // Integer
        },
        'device_id': 'light2',
      },
      {
        'action': 'set_temperature',
        'params': {
          'temperature': 22.5, // Double
        },
        'device_id': 'thermostat1',
      },
      {
        'action': 'send_notification',
        'params': {
          'title': 'Test Notification', // String
          'message': 'This is a test message', // String
        },
        'device_id': '',
      },
      {
        'action': 'delay',
        'params': {
          'seconds': 10, // Integer
        },
        'device_id': '',
      }
    ];
  }

  // Test widget to verify type safety
  static Widget buildTestPreview() {
    return AutomationPreviewWidget(
      conditions: getTestConditions(),
      actions: getTestActions(),
    );
  }

  // Test data with edge cases
  static Map<String, dynamic> getEdgeCaseConditions() {
    return {
      'operator': 'OR',
      'children': [
        {
          'type': 'sensor',
          'op': '!=',
          'value': 0, // Zero value
          'key': 'humidity',
          'deviceId': null, // Null value
          'minChange': null, // Null value
        },
        {
          'type': 'time',
          'op': null, // Null operator
          'value': null, // Null value
        }
      ]
    };
  }

  static List<Map<String, dynamic>> getEdgeCaseActions() {
    return [
      {
        'action': 'set_brightness',
        'params': {
          'brightness': null, // Null value
        },
        'device_id': null,
      },
      {
        'action': null, // Null action type
        'params': null, // Null params
        'device_id': '',
      }
    ];
  }
}

/*
Type Safety Summary:

1. All string interpolations now use .toString() to prevent type errors
2. Null values are handled with null-aware operators (?.)
3. Default values are provided for all potentially null fields
4. Dynamic values are properly cast to strings for display
5. Boolean values are handled separately without string conversion

Key Changes Made:

AutomationPreviewWidget:
- Added .toString() for all condition and action value displays
- Improved device condition display
- Safe null handling for all parameters

AutomationListWidget:
- Added .toString() for condition and action formatting
- Safe type conversion for all displayed values
- Proper handling of mixed data types

The system now handles:
- Integer values (temperature: 25)
- Double values (minChange: 0.5)  
- String values (time: "18:00")
- Boolean values (on: true)
- Null values (deviceId: null)

All UI components are now type-safe and will not throw type errors 
regardless of the data types received from the backend API.
*/
