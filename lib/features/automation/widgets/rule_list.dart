import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smarthome_mobile/core/providers/rule_provider.dart';
import 'package:smarthome_mobile/features/automation/models/rule.dart';

class RuleList extends StatelessWidget {
  const RuleList({super.key});

  @override
  Widget build(BuildContext context) {
    final ruleProvider = Provider.of<RuleProvider>(context);

    if (ruleProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (ruleProvider.rules.isEmpty) {
      return const Center(child: Text('No rules found.'));
    }

    return ListView.builder(
      itemCount: ruleProvider.rules.length,
      itemBuilder: (context, index) {
        final rule = ruleProvider.rules[index];
        return RuleCard(rule: rule);
      },
    );
  }
}

class RuleCard extends StatelessWidget {
  final Rule rule;

  const RuleCard({super.key, required this.rule});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(rule.name),
        trailing: Switch(
          value: rule.enabled,
          onChanged: (value) {
            // TODO: Implement toggle rule
          },
        ),
        onTap: () {
          // ignore: avoid_print
          print(rule);
        },
      ),
    );
  }
}
