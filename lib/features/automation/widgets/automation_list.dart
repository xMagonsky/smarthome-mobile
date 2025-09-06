import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/automation_provider.dart';
import '../models/rule.dart';
import '../pages/add_automation_page.dart';

class AutomationList extends StatelessWidget {
  const AutomationList({super.key});

  @override
  Widget build(BuildContext context) {
    final automationProvider = Provider.of<AutomationProvider>(context);

    if (automationProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (automationProvider.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Error loading automations',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              automationProvider.errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => automationProvider.loadAutomations(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (automationProvider.automations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.smart_toy_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No automations yet',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Create your first automation to get started',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => automationProvider.loadAutomations(),
      child: ListView.builder(
        itemCount: automationProvider.automations.length,
        itemBuilder: (context, index) {
          final automation = automationProvider.automations[index];
          return AutomationCard(automation: automation);
        },
      ),
    );
  }
}

class AutomationCard extends StatelessWidget {
  final Rule automation;

  const AutomationCard({super.key, required this.automation});

  @override
  Widget build(BuildContext context) {
    final automationProvider = Provider.of<AutomationProvider>(context, listen: false);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(
          automation.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              _buildConditionDescription(),
              style: const TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 2),
            Text(
              _buildActionDescription(),
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            ),
            const SizedBox(height: 4),
          ],
        ),
        trailing: Switch(
          value: automation.enabled,
          onChanged: (value) {
            automationProvider.toggleAutomation(automation.id, value);
          },
        ),
        onTap: () {
          // Navigate to edit automation
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddAutomationPage(automation: automation),
            ),
          );
        },
      ),
    );
  }

  String _buildConditionDescription() {
    final conditions = automation.conditions;
    if (conditions.children.isEmpty) {
      return 'No conditions';
    }

    if (conditions.children.length == 1) {
      final child = conditions.children.first;
      return _formatCondition(child);
    }

    return '${conditions.children.length} conditions (${conditions.operator})';
  }

  String _formatCondition(ConditionChild condition) {
    switch (condition.type) {
      case 'sensor':
        final String key = condition.key?.toString().toUpperCase() ?? 'SENSOR';
        final String op = condition.op?.toString() ?? '>';
        final String value = condition.value?.toString() ?? '0';
        return '$key $op $value';
      case 'time':
        String op = condition.op?.toString() ?? '==';
        String opText = op == '>' ? 'after' : op == '<' ? 'before' : 'at';
        String value = condition.value?.toString() ?? '00:00';
        return '$opText $value';
      case 'device':
        return 'Device state change';
      default:
        return 'Unknown condition';
    }
  }

  String _buildActionDescription() {
    if (automation.actions.isEmpty) {
      return 'No actions';
    }

    if (automation.actions.length == 1) {
      final action = automation.actions.first;
      return _formatAction(action);
    }

    return '${automation.actions.length} actions';
  }

  String _formatAction(RuleAction action) {
    switch (action.action) {
      case 'set_state':
        final isOn = action.params['on'] == true;
        return 'Turn ${isOn ? 'on' : 'off'} device';
      case 'set_brightness':
        final String brightness = action.params['brightness']?.toString() ?? '100';
        return 'Set brightness to $brightness%';
      case 'set_temperature':
        final String temperature = action.params['temperature']?.toString() ?? '20';
        return 'Set temperature to $temperature°C';
      case 'set_color':
        final String color = action.params['color']?.toString() ?? '#FFFFFF';
        return 'Set color to $color';
      case 'send_notification':
        final String message = action.params['message']?.toString() ?? '';
        return 'Send notification: $message';
      case 'delay':
        final String seconds = action.params['seconds']?.toString() ?? '5';
        return 'Wait ${seconds}s';
      default:
        return 'Unknown action';
    }
  }
}
