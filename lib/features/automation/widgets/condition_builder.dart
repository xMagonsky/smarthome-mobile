import 'package:flutter/material.dart';

class ConditionBuilder extends StatefulWidget {
  final Map<String, dynamic> initialConditions;
  final Function(Map<String, dynamic>) onChanged;
  final List<dynamic> devices;

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
      'deviceId': '',
      'minChange': 0.1,
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
                      group['operator'] = value!;
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
    return Card(
      color: Colors.grey[100],
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Condition type
            DropdownButtonFormField<String>(
              initialValue: condition['type'] ?? 'sensor',
              decoration: const InputDecoration(
                labelText: 'Type',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'sensor', child: Text('Sensor')),
                DropdownMenuItem(value: 'time', child: Text('Time')),
                DropdownMenuItem(value: 'device', child: Text('Device State')),
              ],
              onChanged: (value) {
                setState(() {
                  condition['type'] = value!;
                  if (value == 'time') {
                    condition.remove('deviceId');
                    condition.remove('key');
                    condition.remove('minChange');
                    condition['value'] = condition['value'] ?? '12:00';
                  } else if (value == 'sensor') {
                    condition['deviceId'] = condition['deviceId'] ?? '';
                    condition['key'] = condition['key'] ?? 'temperature';
                    condition['minChange'] = condition['minChange'] ?? 0.1;
                    condition['value'] = condition['value'] ?? 25;
                  } else if (value == 'device') {
                    condition['deviceId'] = condition['deviceId'] ?? '';
                    condition.remove('key');
                    condition.remove('minChange');
                    condition['value'] = condition['value']?.toString() == 'true' || condition['value']?.toString() == 'false' 
                        ? condition['value'].toString() 
                        : 'true';
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
                initialValue: _getValidDeviceId(condition['deviceId']?.toString()),
                decoration: const InputDecoration(
                  labelText: 'Device',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem<String>(
                    value: '',
                    child: Text('Select Device'),
                  ),
                  ...widget.devices.map((device) {
                    return DropdownMenuItem<String>(
                      value: device['id']?.toString() ?? '',
                      child: Text(device['name'] ?? 'Unknown Device'),
                    );
                  }),
                ],
                onChanged: (value) {
                  setState(() {
                    condition['deviceId'] = value ?? '';
                    _notifyChange();
                  });
                },
              ),
              const SizedBox(height: 8),
              
              // Sensor key
              DropdownButtonFormField<String>(
                initialValue: condition['key'] ?? 'temperature',
                decoration: const InputDecoration(
                  labelText: 'Sensor Type',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'temperature', child: Text('Temperature')),
                  DropdownMenuItem(value: 'humidity', child: Text('Humidity')),
                  DropdownMenuItem(value: 'pressure', child: Text('Pressure')),
                  DropdownMenuItem(value: 'motion', child: Text('Motion')),
                ],
                onChanged: (value) {
                  setState(() {
                    condition['key'] = value;
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
                      initialValue: condition['op'] ?? '>',
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
                          condition['op'] = value;
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
              const SizedBox(height: 8),
              
              // Min change
              TextFormField(
                initialValue: condition['minChange']?.toString() ?? '0.1',
                decoration: const InputDecoration(
                  labelText: 'Min Change',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  condition['minChange'] = double.tryParse(value) ?? 0.1;
                  _notifyChange();
                },
              ),
            ] else if (condition['type'] == 'time') ...[
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: DropdownButtonFormField<String>(
                      initialValue: condition['op'] ?? '>',
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
                          condition['op'] = value;
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
            ] else if (condition['type'] == 'device') ...[
              // Device selection for device state condition
              DropdownButtonFormField<String>(
                initialValue: _getValidDeviceId(condition['deviceId']?.toString()),
                decoration: const InputDecoration(
                  labelText: 'Device',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem<String>(
                    value: '',
                    child: Text('Select Device'),
                  ),
                  ...widget.devices.map((device) {
                    return DropdownMenuItem<String>(
                      value: device['id']?.toString() ?? '',
                      child: Text(device['name'] ?? 'Unknown Device'),
                    );
                  }),
                ],
                onChanged: (value) {
                  setState(() {
                    condition['deviceId'] = value ?? '';
                    _notifyChange();
                  });
                },
              ),
              const SizedBox(height: 8),
              
              // Device state selection
              DropdownButtonFormField<String>(
                initialValue: condition['value']?.toString() ?? 'true',
                decoration: const InputDecoration(
                  labelText: 'State',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'true', child: Text('On')),
                  DropdownMenuItem(value: 'false', child: Text('Off')),
                ],
                onChanged: (value) {
                  setState(() {
                    condition['value'] = value ?? 'true';
                    _notifyChange();
                  });
                },
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

  String? _getValidDeviceId(String? deviceId) {
    if (deviceId == null || deviceId.isEmpty) {
      return '';
    }
    
    // Check if the deviceId exists in the available devices
    final deviceExists = widget.devices.any((device) => device['id']?.toString() == deviceId);
    return deviceExists ? deviceId : '';
  }
}
