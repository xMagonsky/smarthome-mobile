import 'dart:async';
import '../../features/automation/models/automation.dart';
import '../providers/device_provider.dart';
import '../providers/automation_provider.dart';

class AutomationService {
  final DeviceProvider deviceProvider;
  final AutomationProvider automationProvider;
  Timer? _timer;

  AutomationService({
    required this.deviceProvider,
    required this.automationProvider,
  }) {
    _startAutomationCheck();
  }

  void _startAutomationCheck() {
    // Check every minute for time-based triggers
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _checkAutomations();
    });

    // Also check immediately
    _checkAutomations();
  }

  void _checkAutomations() {
    final now = DateTime.now();
    final currentTime = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    for (final automation in automationProvider.automations) {
      if (!automation.isEnabled) continue;

      bool shouldExecute = false;

      switch (automation.trigger.type) {
        case 'time':
          shouldExecute = automation.trigger.value == currentTime;
          break;
        case 'device':
          final device = deviceProvider.getDeviceById(automation.trigger.value);
          if (device != null) {
            // For device state triggers, we could check if device state changed
            // For now, just check current state
            shouldExecute = true; // This would need more logic for actual device state changes
          }
          break;
        case 'sensor':
          final device = deviceProvider.getDeviceById(automation.trigger.value);
          if (device != null && device.sensorValues != null) {
            final sensorValue = device.sensorValues![automation.trigger.sensorType];
            if (sensorValue != null) {
              shouldExecute = _evaluateCondition(sensorValue, automation.trigger.value, automation.condition);
            }
          }
          break;
      }

      if (shouldExecute && _checkCondition(automation.condition)) {
        _executeAction(automation.action);
      }
    }
  }

  bool _evaluateCondition(dynamic sensorValue, String triggerValue, Condition? condition) {
    if (condition == null) return true;

    final targetValue = double.tryParse(triggerValue) ?? 0.0;
    final sensorNum = sensorValue is num ? sensorValue.toDouble() : double.tryParse(sensorValue.toString()) ?? 0.0;

    switch (condition.operator) {
      case '>':
        return sensorNum > targetValue;
      case '<':
        return sensorNum < targetValue;
      case '>=':
        return sensorNum >= targetValue;
      case '<=':
        return sensorNum <= targetValue;
      case '==':
        return sensorNum == targetValue;
      case '!=':
        return sensorNum != targetValue;
      default:
        return false;
    }
  }

  bool _checkCondition(Condition? condition) {
    if (condition == null) return true;

    final device = deviceProvider.getDeviceById(condition.deviceId);
    if (device == null) return false;

    switch (condition.type) {
      case 'device_state':
        return device.isOn == (condition.value == 'true');
      case 'sensor_value':
        if (device.sensorValues != null) {
          final sensorValue = device.sensorValues![condition.sensorType];
          if (sensorValue != null) {
            return _evaluateCondition(sensorValue, condition.value.toString(), condition);
          }
        }
        return false;
      default:
        return true;
    }
  }

  void _executeAction(AutomationAction action) {
    switch (action.type) {
      case 'device_toggle':
        final isOn = action.value == true || action.value == 'true';
        deviceProvider.toggleDevice(action.deviceId, isOn);
        break;
      case 'device_set_value':
        // For thermostat, set temperature
        if (action.value is num) {
          deviceProvider.updateSensorValue(action.deviceId, 'temperature', action.value);
        }
        break;
      case 'notification':
        // For now, just print notification. In real app, show notification
        print('NOTIFICATION: ${action.value}');
        break;
    }
  }

  void dispose() {
    _timer?.cancel();
  }
}
