import 'package:flutter/material.dart';
import 'package:smarthome_mobile/features/devices/models/device.dart';

class ConditionBuilder extends StatefulWidget {
  final Map<String, dynamic> initialConditions;
  final Function(Map<String, dynamic>) onChanged;
  final List<Device> devices;

  const ConditionBuilder({
    super.key,
    required this.initialConditions,
    required this.onChanged,
    required this.devices,
  });

  @override
  State<ConditionBuilder> createState() => _ConditionBuilderState();
}

class _ConditionBuilderState extends State<ConditionBuilder> {
  late Map<String, dynamic> conditions;

  @override
  void initState() {
    super.initState();
    conditions = Map<String, dynamic>.from(widget.initialConditions);
    if (conditions.isEmpty) {
      conditions = {
        'operator': 'AND',
        'children': [_createEmptyCondition()],
      };
    }
  }

  Map<String, dynamic> _createEmptyCondition() {
    return {
      'type': 'sensor',
      'op': '>',
      'value': 0,
      'key': 'temperature',
      'device_id': '',
      'min_change': 0.1,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Conditions',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        _buildConditionGroup(conditions),
      ],
    );
  }

  Widget _buildConditionGroup(Map<String, dynamic> group) {
    final List<dynamic> children = group['children'] ?? [];
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Operator selection
            Row(
              children: [
                const Text('Operator: '),
                DropdownButton<String>(
                  value: group['operator'] ?? 'AND',
                  items: const [
                    DropdownMenuItem(value: 'AND', child: Text('AND')),
                    DropdownMenuItem(value: 'OR', child: Text('OR')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      if (value != null) {
                        group['operator'] = value;
                      }
                      _notifyChange();
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Children conditions
            ...children.asMap().entries.map((entry) {
              final index = entry.key;
              final child = entry.value;
              
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: child['children'] != null
                          ? _buildConditionGroup(child)
                          : _buildSingleCondition(child, index, children),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          final newChildren = [...children];
                          newChildren.removeAt(index);
                          group['children'] = newChildren;
                          _notifyChange();
                        });
                      },
                    ),
                  ],
                ),
              );
            }),
            
            // Add buttons
            Wrap(
              spacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      group['children'] = [...children, _createEmptyCondition()];
                      _notifyChange();
                    });
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add Condition'),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      group['children'] = [...children, {
                        'operator': 'AND',
                        'children': [_createEmptyCondition()],
                      }];
                      _notifyChange();
                    });
                  },
                  icon: const Icon(Icons.add_box),
                  label: const Text('Add Group'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSingleCondition(Map<String, dynamic> condition, int index, List<dynamic> siblings) {
    final sensorDevices = widget.devices.where((d) => d.type == 'sensor').toList();
    
    final deviceId = condition['device_id'] as String?;
    final Device? selectedDevice = deviceId != null && deviceId.isNotEmpty
        ? sensorDevices.cast<Device?>().firstWhere(
            (d) => d?.id == deviceId,
            orElse: () => null,
          )
        : null;

    final sensorKeys = selectedDevice != null
        ? selectedDevice.state.keys.toList()
        : <String>[];

    return Card(
      color: Colors.grey[100],
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Condition type
            DropdownButtonFormField<String>(
              value: condition['type'] ?? 'sensor',
              decoration: const InputDecoration(
                labelText: 'Type',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'sensor', child: Text('Sensor')),
                DropdownMenuItem(value: 'time', child: Text('Time')),
              ],
              onChanged: (value) {
                setState(() {
                  condition['type'] = value!;
                  if (value == 'time') {
                    condition.remove('device_id');
                    condition.remove('key');
                    condition.remove('min_change');
                    condition['value'] = condition['value'] ?? '12:00';
                  } else if (value == 'sensor') {
                    condition['device_id'] = condition['device_id'] ?? '';
                    if (condition['key'] == null) {
                      condition.remove('key');
                    }
                    condition['min_change'] = condition['min_change'] ?? 0.1;
                    condition['value'] = condition['value'] ?? 25;
                  }
                  _notifyChange();
                });
              },
            ),
            const SizedBox(height: 8),
            
            // Condition-specific fields
            if (condition['type'] == 'sensor') ...[
              // Device selection
              DropdownButtonFormField<String>(
                value: _getValidDeviceId(condition['device_id']?.toString(), sensorDevices),
                decoration: const InputDecoration(
                  labelText: 'Device',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem<String>(
                    value: '',
                    child: Text('Select Device'),
                  ),
                  ...sensorDevices.map((device) {
                    return DropdownMenuItem<String>(
                      value: device.id,
                      child: Text(device.name),
                    );
                  }),
                ],
                onChanged: (value) {
                  setState(() {
                    condition['device_id'] = value ?? '';
                    condition.remove('key');
                    _notifyChange();
                  });
                },
              ),
              
              if (selectedDevice != null) ...[
                const SizedBox(height: 8),
                
                // Sensor key
                DropdownButtonFormField<String>(
                  value: sensorKeys.contains(condition['key']) ? condition['key'] : null,
                  decoration: const InputDecoration(
                    labelText: 'Sensor Type',
                    border: OutlineInputBorder(),
                  ),
                  items: sensorKeys.map((key) {
                    return DropdownMenuItem<String>(
                      value: key,
                      child: Text(key),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      if (value != null) {
                        condition['key'] = value;
                      } else {
                        condition.remove('key');
                      }
                      _notifyChange();
                    });
                  },
                ),
                const SizedBox(height: 8),
                
                // Operator and value
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: DropdownButtonFormField<String>(
                        value: condition['op'] ?? '>',
                        decoration: const InputDecoration(
                          labelText: 'Op',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(value: '>', child: Text('>')),
                          DropdownMenuItem(value: '<', child: Text('<')),
                          DropdownMenuItem(value: '>=', child: Text('>=')),
                          DropdownMenuItem(value: '<=', child: Text('<=')),
                          DropdownMenuItem(value: '==', child: Text('==')),
                          DropdownMenuItem(value: '!=', child: Text('!=')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            if (value != null) {
                              condition['op'] = value;
                            }
                            _notifyChange();
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        initialValue: condition['value']?.toString() ?? '0',
                        decoration: const InputDecoration(
                          labelText: 'Value',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          condition['value'] = double.tryParse(value) ?? 0;
                          _notifyChange();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ] else if (condition['type'] == 'time') ...[
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: DropdownButtonFormField<String>(
                      value: condition['op'] ?? '>',
                      decoration: const InputDecoration(
                        labelText: 'Op',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: '>', child: Text('After')),
                        DropdownMenuItem(value: '<', child: Text('Before')),
                        DropdownMenuItem(value: '==', child: Text('At')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          if (value != null) {
                            condition['op'] = value;
                          }
                          _notifyChange();
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      initialValue: condition['value']?.toString() ?? '18:00',
                      decoration: const InputDecoration(
                        labelText: 'Time (HH:MM)',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        condition['value'] = value;
                        _notifyChange();
                      },
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _notifyChange() {
    widget.onChanged(conditions);
  }

  String? _getValidDeviceId(String? deviceId, List<Device> devices) {
    if (deviceId == null || deviceId.isEmpty) {
      return '';
    }
    
    // Check if the deviceId exists in the available devices
    final deviceExists = devices.any((device) => device.id == deviceId);
    return deviceExists ? deviceId : '';
  }
}
