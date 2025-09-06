import 'package:flutter/material.dart';
import '../../features/automation/models/rule.dart';
import '../services/automation_api_service.dart';

class AutomationProvider extends ChangeNotifier {
  List<Rule> automations = [];
  final AutomationApiService _apiService;
  bool isLoading = false;
  String? errorMessage;

  AutomationProvider({required AutomationApiService apiService}) : _apiService = apiService;

  Future<void> loadAutomations() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      automations = await _apiService.getAutomations();
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addAutomation(String name, Map<String, dynamic> conditions, List<Map<String, dynamic>> actions) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final newAutomation = await _apiService.createAutomation(name, conditions, actions);
      automations.add(newAutomation);
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateAutomation(String id, String name, Map<String, dynamic> conditions, List<Map<String, dynamic>> actions) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final updatedAutomation = await _apiService.updateAutomation(id, name, conditions, actions);
      final index = automations.indexWhere((a) => a.id == id);
      if (index != -1) {
        automations[index] = updatedAutomation;
      }
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> removeAutomation(String id) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _apiService.deleteAutomation(id);
      automations.removeWhere((a) => a.id == id);
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleAutomation(String id, bool isEnabled) async {
    try {
      await _apiService.toggleAutomation(id, isEnabled);
      final index = automations.indexWhere((a) => a.id == id);
      if (index != -1) {
        final oldRule = automations[index];
        automations[index] = Rule(
          id: oldRule.id,
          name: oldRule.name,
          conditions: oldRule.conditions,
          actions: oldRule.actions,
          enabled: isEnabled,
          ownerId: oldRule.ownerId,
        );
        notifyListeners();
      }
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
    }
  }

  Rule? getAutomationById(String id) {
    try {
      return automations.firstWhere((a) => a.id == id);
    } catch (e) {
      return null;
    }
  }
}
