import 'package:flutter/material.dart';
import 'package:smarthome_mobile/features/devices/models/device.dart';

class ActionBuilder extends StatefulWidget {
  final List<Map<String, dynamic>> initialActions;
  final Function(List<Map<String, dynamic>>) onChanged;
  final List<Device> devices;

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
  late List<Device> _lightDevices;

  @override
  void initState() {
    super.initState();
    actions = List<Map<String, dynamic>>.from(widget.initialActions);
    if (actions.isEmpty) {
      actions = [_createEmptyAction()];
    }
    _lightDevices = widget.devices.where((d) => d.type == 'light').toList();
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
      _lightDevices = widget.devices.where((d) => d.type == 'light').toList();
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
    List<DropdownMenuItem<String>> items;
    String? dropdownValue = _getValidDeviceId(action['device_id']?.toString());

    if (_lightDevices.isEmpty) {
      items = [
        const DropdownMenuItem<String>(
          value: '',
          child: Text('No available devices'),
        ),
      ];
      dropdownValue = '';
    } else {
      items = _lightDevices.map((device) {
        return DropdownMenuItem<String>(
          value: device.id,
          child: Text(device.name),
        );
      }).toList();

      if (dropdownValue == null ||
          !_lightDevices.any((d) => d.id == dropdownValue)) {
        dropdownValue = null;
      }
    }

    final deviceSelected = action['device_id'] != null &&
        (action['device_id'] as String).isNotEmpty;

    return Column(
      children: [
        DropdownButtonFormField<String>(
          initialValue: dropdownValue,
          hint: const Text('Select device'),
          decoration: const InputDecoration(
            labelText: 'Target Device',
            border: OutlineInputBorder(),
          ),
          items: items,
          onChanged: _lightDevices.isEmpty
              ? null
              : (value) {
                  setState(() {
                    action['device_id'] = value ?? '';
                    action['action'] = 'set_state';
                    if (action['params'] == null ||
                        action['params']['on'] == null) {
                      action['params'] = {'on': true};
                    }
                    _notifyChange();
                  });
                },
        ),
        if (deviceSelected) ...[
          const SizedBox(height: 12),
          DropdownButtonFormField<bool>(
            initialValue: action['params']?['on'] as bool? ?? true,
            decoration: const InputDecoration(
              labelText: 'Set state to',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem<bool>(
                value: true,
                child: Text('ON'),
              ),
              DropdownMenuItem<bool>(
                value: false,
                child: Text('OFF'),
              ),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  action['params']['on'] = value;
                  _notifyChange();
                });
              }
            },
          ),
        ],
      ],
    );
  }

  void _notifyChange() {
    final validActions = actions
        .where((a) =>
            a['device_id'] != null && (a['device_id'] as String).isNotEmpty)
        .toList();
    widget.onChanged(validActions);
  }

  String? _getValidDeviceId(String? deviceId) {
    if (deviceId == null || deviceId.isEmpty) {
      return '';
    }

    // Check if the deviceId exists in the available devices
    final deviceExists = _lightDevices.any((device) => device.id == deviceId);
    return deviceExists ? deviceId : '';
  }
}
