class Device {
  final String id;
  final String name;
  final bool isOn;
  final String type;
  final Map<String, dynamic>? sensorValues; // np. {'temperature': 25.5, 'humidity': 60}

  Device({
    required this.id,
    required this.name,
    this.isOn = false,
    required this.type,
    this.sensorValues,
  });
}