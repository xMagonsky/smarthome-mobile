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
  final String type; // 'time', 'device', 'sensor'
  final String value; // czas w formacie HH:MM, device id, sensor id
  final String description;

  Trigger({
    required this.type,
    required this.value,
    required this.description,
  });
}

class Condition {
  final String type; // 'device_state', 'time_range', 'sensor_value'
  final String deviceId;
  final String operator; // '==', '!=', '>', '<'
  final String value;
  final String description;

  Condition({
    required this.type,
    required this.deviceId,
    required this.operator,
    required this.value,
    required this.description,
  });
}

class AutomationAction {
  final String type; // 'device_toggle', 'device_set_value', 'notification'
  final String deviceId;
  final String value; // true/false dla toggle, wartość dla set_value
  final String description;

  AutomationAction({
    required this.type,
    required this.deviceId,
    required this.value,
    required this.description,
  });
}
