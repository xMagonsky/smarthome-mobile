import 'package:flutter/material.dart';

class AutomationPreviewWidget extends StatelessWidget {
  final Map<String, dynamic> conditions;
  final List<Map<String, dynamic>> actions;

  const AutomationPreviewWidget({
    super.key,
    required this.conditions,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.preview, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Preview',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Conditions preview
            _buildConditionsPreview(),
            const SizedBox(height: 12),

            // Actions preview
            _buildActionsPreview(),
          ],
        ),
      ),
    );
  }

  Widget _buildConditionsPreview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.rule, size: 16, color: Colors.blue[600]),
            const SizedBox(width: 4),
            const Text(
              'When:',
              style: TextStyle(fontWeight: FontWeight.w600, color: Colors.blue),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.only(left: 20),
          child: _buildConditionText(conditions),
        ),
      ],
    );
  }

  Widget _buildConditionText(Map<String, dynamic> condition) {
    if (condition['children'] != null) {
      final List<dynamic> children = condition['children'];
      final String operator = condition['operator'] ?? 'AND';

      if (children.isEmpty) {
        return const Text('No conditions',
            style: TextStyle(fontStyle: FontStyle.italic));
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...children.asMap().entries.map((entry) {
            final index = entry.key;
            final child = entry.value;

            return Padding(
              padding:
                  EdgeInsets.only(bottom: index < children.length - 1 ? 4 : 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (index > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: operator == 'AND'
                            ? Colors.green[100]
                            : Colors.orange[100],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        operator,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: operator == 'AND'
                              ? Colors.green[700]
                              : Colors.orange[700],
                        ),
                      ),
                    ),
                  if (index > 0) const SizedBox(width: 8),
                  Expanded(child: _buildSingleConditionText(child)),
                ],
              ),
            );
          }),
        ],
      );
    } else {
      return _buildSingleConditionText(condition);
    }
  }

  Widget _buildSingleConditionText(Map<String, dynamic> condition) {
    final String type = condition['type'] ?? '';

    switch (type) {
      case 'sensor':
        final String key = condition['key']?.toString() ?? 'value';
        final String op = condition['op']?.toString() ?? '>';
        final String value = condition['value']?.toString() ?? '0';
        return Text('$key $op $value');

      case 'time':
        final String op = condition['op']?.toString() ?? '==';
        final String value = condition['value']?.toString() ?? '00:00';
        String opText = op == '>'
            ? 'after'
            : op == '<'
                ? 'before'
                : 'at';
        return Text('Time is $opText $value');

      case 'device':
        final String deviceState =
            condition['value']?.toString() == 'true' ? 'on' : 'off';
        return Text('Device is $deviceState');

      default:
        return Text('Unknown condition ($type)');
    }
  }

  Widget _buildActionsPreview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.play_arrow, size: 16, color: Colors.green[600]),
            const SizedBox(width: 4),
            const Text(
              'Then:',
              style:
                  TextStyle(fontWeight: FontWeight.w600, color: Colors.green),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (actions.isEmpty)
                const Text('No actions',
                    style: TextStyle(fontStyle: FontStyle.italic))
              else
                ...actions.map((action) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: _buildActionText(action),
                    )),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionText(Map<String, dynamic> action) {
    final String actionType = action['action']?.toString() ?? '';
    final Map<String, dynamic> params = action['params'] ?? {};

    switch (actionType) {
      case 'set_state':
        final bool isOn = params['on'] == true;
        return Text('Turn ${isOn ? 'on' : 'off'} device');

      case 'set_brightness':
        final String brightness = params['brightness']?.toString() ?? '100';
        return Text('Set brightness to $brightness%');

      case 'set_temperature':
        final String temperature = params['temperature']?.toString() ?? '20';
        return Text('Set temperature to $temperature°C');

      case 'set_color':
        final String color = params['color']?.toString() ?? '#FFFFFF';
        return Text('Set color to $color');

      case 'send_notification':
        final String message = params['message']?.toString() ?? '';
        return Text('Send notification: "$message"');

      case 'delay':
        final String seconds = params['seconds']?.toString() ?? '5';
        return Text('Wait $seconds seconds');

      default:
        return Text('Unknown action ($actionType)');
    }
  }
}
