import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import '../../features/automation/models/rule.dart';

class AutomationApiService {
  final String baseUrl;
  final Logger _logger = Logger();

  AutomationApiService({required this.baseUrl});

  Future<List<Rule>> getAutomations() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/automations/rules'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => Rule.fromJson(item)).toList();
      } else {
        throw HttpException('Failed to fetch automations: ${response.statusCode}');
      }
    } catch (e) {
      _logger.e('Error fetching automations: $e');
      throw Exception('Failed to fetch automations: $e');
    }
  }

  Future<Rule> createAutomation(String name, Map<String, dynamic> conditions, List<Map<String, dynamic>> actions) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/automations/rules'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': name,
          'conditions': conditions,
          'actions': actions,
          'enabled': true,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return Rule.fromJson(json.decode(response.body));
      } else {
        throw HttpException('Failed to create automation: ${response.statusCode}');
      }
    } catch (e) {
      _logger.e('Error creating automation: $e');
      throw Exception('Failed to create automation: $e');
    }
  }

  Future<Rule> updateAutomation(String id, String name, Map<String, dynamic> conditions, List<Map<String, dynamic>> actions) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/automations/rules/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': name,
          'conditions': conditions,
          'actions': actions,
        }),
      );

      if (response.statusCode == 200) {
        return Rule.fromJson(json.decode(response.body));
      } else {
        throw HttpException('Failed to update automation: ${response.statusCode}');
      }
    } catch (e) {
      _logger.e('Error updating automation: $e');
      throw Exception('Failed to update automation: $e');
    }
  }

  Future<void> deleteAutomation(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/automations/rules/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw HttpException('Failed to delete automation: ${response.statusCode}');
      }
    } catch (e) {
      _logger.e('Error deleting automation: $e');
      throw Exception('Failed to delete automation: $e');
    }
  }

  Future<void> toggleAutomation(String id, bool enabled) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/automations/rules/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'enabled': enabled}),
      );

      if (response.statusCode != 200) {
        throw HttpException('Failed to toggle automation: ${response.statusCode}');
      }
    } catch (e) {
      _logger.e('Error toggling automation: $e');
      throw Exception('Failed to toggle automation: $e');
    }
  }
}
