class Automation {
  final String id;
  final String name;
  final Trigger trigger;
  final Condition? condition;
  final AutomationAction action;
  final bool isEnabled;

  Automation({
    required this.id,
    required this.name,
    required this.trigger,
    this.condition,
    required this.action,
    this.isEnabled = true,
  });
}

class Trigger {
  final String type; // 'time', 'device', 'sensor', 'schedule'
  final String
      value; // czas w formacie HH:MM, device id, sensor id, cron expression
  final String sensorType; // np. 'temperature', 'humidity' dla sensor triggers
  final String description;

  Trigger({
    required this.type,
    required this.value,
    this.sensorType = '',
    required this.description,
  });
}

class Condition {
  final String type; // 'device_state', 'time_range', 'sensor_value', 'weather'
  final String deviceId;
  final String sensorType; // e.g. 'temperature', 'humidity'
  final String operator; // '==', '!=', '>', '<', '>=', '<='
  final dynamic value; // can be string, number, bool
  final String description;

  Condition({
    required this.type,
    required this.deviceId,
    this.sensorType = '',
    required this.operator,
    required this.value,
    required this.description,
  });
}

class AutomationAction {
  final String
      type; // 'device_toggle', 'device_set_value', 'notification', 'scene', 'delay'
  final String deviceId;
  final dynamic
      value; // true/false for toggle, value for set_value, text for notification
  final String description;
  final int? delaySeconds; // for delay actions

  AutomationAction({
    required this.type,
    required this.deviceId,
    required this.value,
    required this.description,
    this.delaySeconds,
  });
}
