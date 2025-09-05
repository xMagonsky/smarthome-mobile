class Device {
  final String id;
  final String name;
  final String type;
  final Map<String, dynamic> state;
  final String mqttTopic;

  Device({
    required this.id,
    required this.name,
    required this.type,
    required this.state,
    required this.mqttTopic,
  });

  bool get isOn => state['on'] ?? false;
}