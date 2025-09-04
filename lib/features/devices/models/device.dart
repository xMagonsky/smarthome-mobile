class Device {
  final String id;
  final String name;
  final bool isOn;
  final String type;

  Device({required this.id, required this.name, this.isOn = false, required this.type});
}