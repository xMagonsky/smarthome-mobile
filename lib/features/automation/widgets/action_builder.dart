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
  // no UI-only fields stored persistently
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
                          icon: const Icon(Icons.delete, color: Colors.red, size: 20),
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
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Action'),
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
            labelText: 'Device',
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
              size: 20,
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
                    final String? selectedKey = boolKeys.contains('on')
                        ? 'on'
                        : (boolKeys.isNotEmpty ? boolKeys.first : null);
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
          // Styled container similar to conditions, with multiple state pickers and switches
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

              // Keep only boolean params for this device
              final keysAll = boolEntries.map((e) => e.key).toList();
              final params = (action['params'] as Map<String, dynamic>?) ??
                  <String, dynamic>{};
              // Remove params not in available keys
              params.keys
                  .where((k) => !keysAll.contains(k))
                  .toList()
                  .forEach(params.remove);
              action['params'] = params;

              // Ensure at least one key is selected
              if (params.isEmpty) {
                final defaultKey =
                    keysAll.contains('on') ? 'on' : keysAll.first;
                params[defaultKey] =
                    (selectedDevice.state[defaultKey] as bool?) ?? false;
              }

              final selectedKeys = params.keys.toList();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...selectedKeys.asMap().entries.map((entry) {
                    final rowIndex = entry.key;
                    final currentKey = entry.value;
                    final currentValue = (params[currentKey] as bool?) ??
                        ((selectedDevice!.state[currentKey] as bool?) ??
                            false);

                    // Keys available for this row: ensure uniqueness and include current key
                    final otherSelected = Set<String>.from(selectedKeys)
                      ..remove(currentKey);
                    final availableForRow = <String>{
                      currentKey,
                      ...keysAll.where((k) => !otherSelected.contains(k)),
                    }.toList();

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: DropdownButtonFormField<String>(
                              key: ValueKey('state_key_${rowIndex}_$currentKey'),
                              initialValue: currentKey,
                              decoration: InputDecoration(
                                labelText: 'State',
                                labelStyle: TextStyle(
                                  color: Colors.purple.shade700,
                                  fontWeight: FontWeight.w600,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                      color: Colors.purple.shade300),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                      color: Colors.purple.shade300),
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
                              items: availableForRow
                                  .map(
                                    (k) => DropdownMenuItem<String>(
                                      value: k,
                                      child: Text(
                                        k
                                            .replaceAll('_', ' ')
                                            .toUpperCase(),
                                        style:
                                            const TextStyle(fontSize: 12),
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (k) {
                                if (k == null || k == currentKey) return;
                                setState(() {
                                  final oldVal = params[currentKey] as bool? ??
                                      ((selectedDevice!.state[currentKey]
                                              as bool?) ??
                                          false);
                                  params.remove(currentKey);
                                  params[k] = (selectedDevice!.state[k]
                                              as bool?) ??
                                          oldVal;
                                  action['params'] = params;
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
                                border: Border.all(
                                    color: Colors.purple.shade200),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text('ON/OFF',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 10)),
                                  ),
                                  Switch.adaptive(
                                    value: currentValue,
                                    onChanged: (v) {
                                      setState(() {
                                        params[currentKey] = v;
                                        action['params'] = params;
                                        _notifyChange();
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (selectedKeys.length > 1) ...[
                            const SizedBox(width: 8),
                            IconButton(
                              tooltip: 'Remove state',
                              onPressed: () {
                                setState(() {
                                  params.remove(currentKey);
                                  action['params'] = params;
                                  _notifyChange();
                                });
                              },
                              icon: const Icon(Icons.remove_circle,
                                  color: Colors.redAccent),
                            ),
                          ],
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 4),
                  // Add state button if any remaining keys available
                  if (keysAll
                      .any((k) => !(action['params'] as Map).keys.contains(k)))
                    Align(
                      alignment: Alignment.centerLeft,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.add),
                        label: const Text('Add state'),
                        onPressed: () {
                          setState(() {
                            final used =
                                Set<String>.from((action['params'] as Map)
                                    .keys
                                    .cast<String>());
                            final nextKey = keysAll
                                .firstWhere((k) => !used.contains(k));
                            params[nextKey] =
                                (selectedDevice!.state[nextKey] as bool?) ??
                                    false;
                            action['params'] = params;
                            _notifyChange();
                          });
                        },
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
      final params = (a['params'] as Map<String, dynamic>?);
      if (params != null && params.isNotEmpty) {
        // Keep only boolean values
        final filtered = <String, dynamic>{};
        params.forEach((k, v) {
          if (v is bool) filtered[k] = v;
        });
        sanitized['params'] =
            filtered.isNotEmpty ? filtered : <String, dynamic>{'on': true};
      } else {
        sanitized['params'] = {'on': true};
      }
      // strip any UI-only artifacts if they somehow exist
      (sanitized..remove('selected_state_key'));
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
