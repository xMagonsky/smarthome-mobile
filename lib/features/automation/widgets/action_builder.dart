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
  // UI-only field; stripped before emitting from _notifyChange
  'selected_state_key': null,
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

    // Find the selected device
    Device? selectedDevice;
    if (deviceSelected) {
      try {
        selectedDevice =
            _lightDevices.firstWhere((d) => d.id == action['device_id']);
      } catch (_) {
        selectedDevice = null;
      }
    }

  return Column(
      children: [
        DropdownButtonFormField<String>(
          initialValue: dropdownValue,
          hint: const Text('Select device'),
          decoration: InputDecoration(
            labelText: 'Target Device',
            labelStyle: TextStyle(
              color: Colors.purple.shade700,
              fontWeight: FontWeight.w600,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.purple.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.purple.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.purple.shade600, width: 2),
            ),
            filled: true,
            fillColor: Colors.white,
            prefixIcon: Icon(
              Icons.memory,
              color: Colors.purple.shade400,
            ),
          ),
          items: items,
          onChanged: _lightDevices.isEmpty
              ? null
              : (value) {
                  setState(() {
                    action['device_id'] = value ?? '';
                    action['action'] = 'set_state';
                    // Initialize a single selectable boolean state
                    final dev = _lightDevices.firstWhere(
                        (d) => d.id == (value ?? ''),
                        orElse: () => _lightDevices.first);
                    final boolKeys = dev.state.entries
                        .where((e) => e.value is bool)
                        .map((e) => e.key)
                        .toList();
                    String? selectedKey = action['selected_state_key'];
                    if (selectedKey == null || !boolKeys.contains(selectedKey)) {
                      if (boolKeys.contains('on')) {
                        selectedKey = 'on';
                      } else {
                        selectedKey = boolKeys.isNotEmpty ? boolKeys.first : null;
                      }
                    }
                    action['selected_state_key'] = selectedKey;
                    if (selectedKey != null) {
                      final current = (dev.state[selectedKey] as bool?) ?? false;
                      action['params'] = {selectedKey: current};
                    } else {
                      action['params'] = {'on': true};
                    }
                    _notifyChange();
                  });
                },
        ),
        if (deviceSelected && selectedDevice != null) ...[
          const SizedBox(height: 12),
          // Styled container similar to conditions, with state picker and switch
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.purple.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.purple.shade200),
            ),
            child: Builder(builder: (context) {
              final boolEntries = selectedDevice!.state.entries
                  .where((e) => e.value is bool)
                  .toList();
              if (boolEntries.isEmpty) {
                return const Text(
                  'This device has no boolean states to set.',
                  style: TextStyle(color: Colors.grey),
                );
              }

              final keys = boolEntries.map((e) => e.key).toList();
              String? selectedKey = action['selected_state_key'] as String?;
              if (selectedKey == null || !keys.contains(selectedKey)) {
                selectedKey = keys.contains('on') ? 'on' : keys.first;
                action['selected_state_key'] = selectedKey;
              }
              final bool currentDeviceValue =
                  (selectedDevice.state[selectedKey] as bool?) ?? false;
              final bool selectedValue = (action['params']?[selectedKey]
                      as bool?) ??
                  currentDeviceValue;

              return Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: DropdownButtonFormField<String>(
                      initialValue: selectedKey,
                      decoration: InputDecoration(
                        labelText: 'State',
                        labelStyle: TextStyle(
                          color: Colors.purple.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              BorderSide(color: Colors.purple.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              BorderSide(color: Colors.purple.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                              color: Colors.purple.shade600, width: 2),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        prefixIcon: Icon(
                          Icons.toggle_on,
                          color: Colors.purple.shade400,
                        ),
                      ),
                      items: keys
                          .map(
                            (k) => DropdownMenuItem<String>(
                              value: k,
                              child: Text(
                                k.replaceAll('_', ' ').toUpperCase(),
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (k) {
                        if (k == null) return;
                        setState(() {
                          action['selected_state_key'] = k;
                          final bool deviceVal =
                              (selectedDevice!.state[k] as bool?) ?? false;
                          action['params'] = {k: deviceVal};
                          _notifyChange();
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.purple.shade200),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Value',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 14)),
                          Switch.adaptive(
                            value: selectedValue,
                            onChanged: (v) {
                              setState(() {
                                final k = action['selected_state_key']
                                    as String?;
                                if (k != null) {
                                  action['params'] = {k: v};
                                  _notifyChange();
                                }
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ],
    );
  }

  void _notifyChange() {
    final validActions = actions
        .where((a) =>
            a['device_id'] != null && (a['device_id'] as String).isNotEmpty)
        .map((a) {
      final sanitized = <String, dynamic>{
        'action': a['action'] ?? 'set_state',
        'device_id': a['device_id'],
      };
      final selectedKey = a['selected_state_key'] as String?;
      final params = a['params'] as Map<String, dynamic>?;
      if (selectedKey != null && params != null && params.containsKey(selectedKey)) {
        sanitized['params'] = {selectedKey: params[selectedKey]};
      } else if (params != null && params.isNotEmpty) {
        // fallback: copy the first entry only
        final first = params.entries.first;
        sanitized['params'] = {first.key: first.value};
      } else {
        sanitized['params'] = {'on': true};
      }
      return sanitized;
    }).toList();

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
