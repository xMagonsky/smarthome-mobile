import 'dart:async';
import 'package:logger/logger.dart';
import '../../features/automation/models/rule.dart';
import '../providers/device_provider.dart';
import '../providers/automation_provider.dart';

class AutomationService {
  final DeviceProvider deviceProvider;
  final AutomationProvider automationProvider;
  final Logger _logger = Logger();
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
      if (!automation.enabled) continue;

      bool shouldExecute = false;

      // Check if conditions are met
      shouldExecute = _evaluateConditions(automation.conditions, currentTime);

      if (shouldExecute) {
        _executeActions(automation.actions);
      }
    }
  }

  bool _evaluateConditions(Conditions conditions, String currentTime) {
    if (conditions.children.isEmpty) return false;

    List<bool> results = [];
    
    for (final condition in conditions.children) {
      bool conditionMet = false;
      
      switch (condition.type) {
        case 'time':
          conditionMet = _evaluateTimeCondition(condition, currentTime);
          break;
        case 'sensor':
          conditionMet = _evaluateSensorCondition(condition);
          break;
        case 'device':
          conditionMet = _evaluateDeviceCondition(condition);
          break;
      }
      
      results.add(conditionMet);
    }

    // Apply operator logic
    if (conditions.operator == 'AND') {
      return results.every((result) => result);
    } else if (conditions.operator == 'OR') {
      return results.any((result) => result);
    }
    
    return false;
  }

  bool _evaluateTimeCondition(ConditionChild condition, String currentTime) {
    final String targetTime = condition.value?.toString() ?? '00:00';
    final String op = condition.op ?? '==';
    
    switch (op) {
      case '>':
        return currentTime.compareTo(targetTime) > 0;
      case '<':
        return currentTime.compareTo(targetTime) < 0;
      case '==':
        return currentTime == targetTime;
      default:
        return false;
    }
  }

  bool _evaluateSensorCondition(ConditionChild condition) {
    if (condition.deviceId == null) return false;
    
    final device = deviceProvider.getDeviceById(condition.deviceId!);
    if (device == null) return false;

    final sensorValue = device.state[condition.key];
    if (sensorValue == null) return false;

    final targetValue = condition.value;
    if (targetValue == null) return false;

    return _evaluateComparison(sensorValue, condition.op ?? '>', targetValue);
  }

  bool _evaluateDeviceCondition(ConditionChild condition) {
    if (condition.deviceId == null) return false;
    
    final device = deviceProvider.getDeviceById(condition.deviceId!);
    if (device == null) return false;

    // For device state changes, this would need more complex logic
    // For now, just check if device is on/off
    return device.isOn;
  }

  bool _evaluateComparison(dynamic sensorValue, String op, dynamic targetValue) {
    final sensorNum = sensorValue is num ? sensorValue.toDouble() : double.tryParse(sensorValue.toString()) ?? 0.0;
    final targetNum = targetValue is num ? targetValue.toDouble() : double.tryParse(targetValue.toString()) ?? 0.0;

    switch (op) {
      case '>':
        return sensorNum > targetNum;
      case '<':
        return sensorNum < targetNum;
      case '>=':
        return sensorNum >= targetNum;
      case '<=':
        return sensorNum <= targetNum;
      case '==':
        return sensorNum == targetNum;
      case '!=':
        return sensorNum != targetNum;
      default:
        return false;
    }
  }

  void _executeActions(List<RuleAction> actions) {
    for (final action in actions) {
      _executeAction(action);
    }
  }

  void _executeAction(RuleAction action) {
    switch (action.action) {
      case 'set_state':
        final isOn = action.params['on'] == true;
        deviceProvider.toggleDevice(action.deviceId, isOn);
        break;
      case 'set_brightness':
        // For brightness control
        final brightness = action.params['brightness'] as int? ?? 100;
        _logger.i('Setting brightness to $brightness for device ${action.deviceId}');
        // TODO: Implement brightness control in device provider
        break;
      case 'set_temperature':
        final temperature = action.params['temperature'] as double? ?? 20.0;
        deviceProvider.updateSensorValue(action.deviceId, 'temperature', temperature);
        break;
      case 'set_color':
        final color = action.params['color'] as String? ?? '#FFFFFF';
        _logger.i('Setting color to $color for device ${action.deviceId}');
        // TODO: Implement color control in device provider
        break;
      case 'send_notification':
        final message = action.params['message'] as String? ?? '';
        final title = action.params['title'] as String? ?? 'Smart Home';
        _logger.i('NOTIFICATION: $title - $message');
        // TODO: Implement actual notification system
        break;
      case 'delay':
        final seconds = action.params['seconds'] as int? ?? 5;
        _logger.i('Delaying $seconds seconds');
        // TODO: Implement proper delay handling
        break;
      default:
        _logger.w('Unknown action type: ${action.action}');
    }
  }

  void dispose() {
    _timer?.cancel();
  }
}
