import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:smarthome_mobile/core/services/api_service.dart';
import 'package:smarthome_mobile/features/automation/models/rule.dart';

class RuleProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<Rule> _rules = [];
  bool _isLoading = false;

  RuleProvider() {
    fetchRules();
  }

  List<Rule> get rules => _rules;
  bool get isLoading => _isLoading;

  Future<void> fetchRules() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.fetchAutomationRules();
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _rules = data.map((json) => Rule.fromJson(json)).toList();
      } else {
        // Handle error
        _rules = [];
      }
    } catch (e) {
      // Handle error
      _rules = [];
    }

    _isLoading = false;
    notifyListeners();
  }
}
