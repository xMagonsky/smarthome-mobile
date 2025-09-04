import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/automation_provider.dart';
import '../models/automation.dart';
import '../pages/add_automation_page.dart';

class AutomationList extends StatelessWidget {
  const AutomationList({super.key});

  @override
  Widget build(BuildContext context) {
    final automationProvider = Provider.of<AutomationProvider>(context);

    return ListView.builder(
      itemCount: automationProvider.automations.length,
      itemBuilder: (context, index) {
        final automation = automationProvider.automations[index];
        return AutomationCard(automation: automation);
      },
    );
  }
}

class AutomationCard extends StatelessWidget {
  final Automation automation;

  const AutomationCard({super.key, required this.automation});

  @override
  Widget build(BuildContext context) {
    final automationProvider = Provider.of<AutomationProvider>(context, listen: false);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(automation.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Trigger: ${automation.trigger.description}'),
            Text('Action: ${automation.action.description}'),
          ],
        ),
        trailing: Switch(
          value: automation.isEnabled,
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
}
