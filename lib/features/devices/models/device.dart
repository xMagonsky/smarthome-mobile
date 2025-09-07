class Device {
  final String id;
  final String name;
  final String type;
  final Map<String, dynamic> state;
  final String mqttTopic;
  final bool isOnline;

  Device({
    required this.id,
    required this.name,
    required this.type,
    required this.state,
    required this.mqttTopic,
    this.isOnline = true,
  });

  bool get isOn => state['on'] ?? false;

  Device copyWith({
    String? id,
    String? name,
    String? type,
    Map<String, dynamic>? state,
    String? mqttTopic,
    bool? isOnline,
  }) {
    return Device(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      state: state ?? this.state,
      mqttTopic: mqttTopic ?? this.mqttTopic,
      isOnline: isOnline ?? this.isOnline,
    );
  }
}
