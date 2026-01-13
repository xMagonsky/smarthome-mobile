import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/automation_provider.dart';
import '../widgets/automation_list.dart';
import 'add_automation_page.dart';

class AutomationPage extends StatelessWidget {
  const AutomationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                onPressed: () {
                  Provider.of<AutomationProvider>(context, listen: false)
                      .loadAutomations();
                },
                icon: const Icon(Icons.refresh),
                tooltip: 'Refresh',
              ),
            ],
          ),
        ),
        const Expanded(
          child: AutomationList(),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AddAutomationPage(),
                ),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Automation'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
            ),
          ),
        ),
      ],
    );
  }
}
