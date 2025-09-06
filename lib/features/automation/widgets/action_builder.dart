import 'package:flutter/material.dart';

class ActionBuilder extends StatefulWidget {
  final List<Map<String, dynamic>> initialActions;
  final Function(List<Map<String, dynamic>>) onChanged;
  final List<dynamic> devices;

  const ActionBuilder({
    super.key,
    required this.initialActions,
    required this.onChanged,
    required this.devices,
  });

  @override
  State<ActionBuilder> createState() => _ActionBuilderState();
}

class _ActionBuilderState extends State<ActionBuilder> {
  late List<Map<String, dynamic>> actions;
  late List<dynamic> _lightDevices;

  @override
  void initState() {
    super.initState();
    actions = List<Map<String, dynamic>>.from(widget.initialActions);
    if (actions.isEmpty) {
      actions = [_createEmptyAction()];
    }
    _lightDevices = widget.devices.where((d) => d['type'] == 'light').toList();
  }

  Map<String, dynamic> _createEmptyAction() {
    return {
      'action': 'set_state',
      'params': {'on': false},
      'device_id': '',
    };
  }

  @override
  void didUpdateWidget(covariant ActionBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.devices != oldWidget.devices) {
      _lightDevices = widget.devices.where((d) => d['type'] == 'light').toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Actions',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        
        // Actions list
        ...actions.asMap().entries.map((entry) {
          final index = entry.key;
          final action = entry.value;
          
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: _buildActionFields(action)),
                      if (actions.length > 1)
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              actions.removeAt(index);
                              _notifyChange();
                            });
                          },
                        ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
        
        // Add action button
        ElevatedButton.icon(
          onPressed: () {
            setState(() {
              actions.add(_createEmptyAction());
              _notifyChange();
            });
          },
          icon: const Icon(Icons.add),
          label: const Text('Add Action'),
        ),
      ],
    );
  }

  Widget _buildActionFields(Map<String, dynamic> action) {
    return DropdownButtonFormField<String>(
      value: _getValidDeviceId(action['device_id']?.toString()),
      decoration: const InputDecoration(
        labelText: 'Target Light',
        border: OutlineInputBorder(),
      ),
      items: [
        const DropdownMenuItem<String>(
          value: '',
          child: Text('Select Light'),
        ),
        ..._lightDevices.map((device) {
          return DropdownMenuItem<String>(
            value: device['id']?.toString() ?? '',
            child: Text(device['name'] ?? 'Unknown Light'),
          );
        }),
      ],
      onChanged: (value) {
        setState(() {
          action['device_id'] = value ?? '';
          action['action'] = 'set_state';
          action['params'] = {'on': true};
          _notifyChange();
        });
      },
    );
  }

  void _notifyChange() {
    widget.onChanged(actions);
  }

  String? _getValidDeviceId(String? deviceId) {
    if (deviceId == null || deviceId.isEmpty) {
      return '';
    }
    
    // Check if the deviceId exists in the available devices
    final deviceExists = _lightDevices.any((device) => device['id']?.toString() == deviceId);
    return deviceExists ? deviceId : '';
  }
}
