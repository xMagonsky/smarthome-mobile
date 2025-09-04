import 'package:flutter/material.dart';
import '../../features/devices/models/group.dart';

class GroupProvider extends ChangeNotifier {
  List<Group> groups = [];

  GroupProvider() {
    loadGroups();
  }

  void loadGroups() {
    // Mock data; replace with repository call in future
    groups = [
      Group(id: '1', name: 'Living Room', deviceIds: ['1']),
      Group(id: '2', name: 'Kitchen', deviceIds: ['2']),
      Group(id: '3', name: 'Bedroom', deviceIds: ['3']),
    ];
    notifyListeners();
  }

  void addGroup(String name, List<String> deviceIds) {
    final newGroup = Group(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      deviceIds: deviceIds,
    );
    groups.add(newGroup);
    notifyListeners();
  }

  void updateGroup(String id, String name, List<String> deviceIds) {
    final index = groups.indexWhere((g) => g.id == id);
    if (index != -1) {
      groups[index] = Group(id: id, name: name, deviceIds: deviceIds);
      notifyListeners();
    }
  }

  void deleteGroup(String id) {
    groups.removeWhere((g) => g.id == id);
    notifyListeners();
  }

  Group? getGroupById(String id) {
    return groups.firstWhere((g) => g.id == id);
  }
}
