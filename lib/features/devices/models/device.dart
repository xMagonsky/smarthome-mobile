class Device {
  final String id;
  final String name;
  final String type;
  final Map<String, dynamic> state;
  final String mqttTopic;
  final Map<String, dynamic>? sensorValues; // np. {'temperature': 25.5, 'humidity': 60}

  Device({
    required this.id,
    required this.name,
    required this.type,
    required this.state,
    required this.mqttTopic,
    this.sensorValues,
  });

  bool get isOn => state['on'] ?? false;
}