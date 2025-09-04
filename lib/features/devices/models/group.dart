class Group {
  final String id;
  final String name;
  final List<String> deviceIds; // List of device IDs in this group

  Group({required this.id, required this.name, this.deviceIds = const []});

  Group copyWith({String? id, String? name, List<String>? deviceIds}) {
    return Group(
      id: id ?? this.id,
      name: name ?? this.name,
      deviceIds: deviceIds ?? this.deviceIds,
    );
  }
}
