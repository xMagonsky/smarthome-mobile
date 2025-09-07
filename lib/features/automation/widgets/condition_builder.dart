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
                child: child['children'] != null
                    ? Row(
                        children: [
                          Expanded(
                            child: _buildConditionGroup(child),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete,
                                color: Colors.red, size: 20),
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
                      )
                    : _buildSingleCondition(child, index, children),
              );
            }),

            // Add buttons
            Wrap(
              spacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      group['children'] = [
                        ...children,
                        _createEmptyCondition()
                      ];
                      _notifyChange();
                    });
                  },
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Condition'),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      group['children'] = [
                        ...children,
                        {
                          'operator': 'AND',
                          'children': [_createEmptyCondition()],
                        }
                      ];
                      _notifyChange();
                    });
                  },
                  icon: const Icon(Icons.add_box, size: 18),
                  label: const Text('Group'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSingleCondition(
      Map<String, dynamic> condition, int index, List<dynamic> siblings) {
    final sensorDevices =
        widget.devices.where((d) => d.type == 'sensor').toList();

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
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: Colors.grey[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Condition type with trash icon
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: condition['type'] ?? 'sensor',
                    decoration: InputDecoration(
                      labelText: 'Condition Type',
                      labelStyle: TextStyle(
                        color: Colors.indigo.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.indigo.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.indigo.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            BorderSide(color: Colors.indigo.shade600, width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: Icon(
                        Icons.category,
                        color: Colors.indigo.shade400,
                        size: 20,
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'sensor',
                        child: Text('Sensor', style: TextStyle(fontSize: 14)),
                      ),
                      DropdownMenuItem(
                        value: 'time',
                        child: Text('Time', style: TextStyle(fontSize: 14)),
                      ),
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
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                  onPressed: () {
                    setState(() {
                      final newChildren = [...siblings];
                      newChildren.removeAt(index);
                      if (newChildren.isEmpty) {
                        newChildren.add(_createEmptyCondition());
                      }
                      // Update the parent's children
                      final parentGroup = conditions;
                      if (parentGroup['children'] == siblings) {
                        parentGroup['children'] = newChildren;
                      } else {
                        // Find the parent group that contains these siblings
                        _findAndUpdateParent(parentGroup, siblings, newChildren);
                      }
                      _notifyChange();
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Condition-specific fields
            if (condition['type'] == 'sensor') ...[
              // Device selection
              DropdownButtonFormField<String>(
                initialValue: _getValidDeviceId(
                    condition['device_id']?.toString(), sensorDevices),
                hint: const Text('Select device',
                    style: TextStyle(color: Colors.grey)),
                decoration: InputDecoration(
                  labelText: 'Device',
                  labelStyle: TextStyle(
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.green.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.green.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        BorderSide(color: Colors.green.shade600, width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: Icon(
                    Icons.devices,
                    color: Colors.green.shade400,
                    size: 20,
                  ),
                ),
                items: sensorDevices.isEmpty
                    ? [
                        const DropdownMenuItem<String>(
                          value: '',
                          child: Text('No available devices',
                              style: TextStyle(color: Colors.grey)),
                        ),
                      ]
                    : sensorDevices.map((device) {
                        return DropdownMenuItem<String>(
                          value: device.id,
                          child: Text(
                            device.name,
                            style: const TextStyle(fontSize: 14),
                          ),
                        );
                      }).toList(),
                onChanged: sensorDevices.isEmpty
                    ? null
                    : (value) {
                        setState(() {
                          condition['device_id'] = value ?? '';
                          condition.remove('key');
                          _notifyChange();
                        });
                      },
              ),
              const SizedBox(height: 16),

              if (selectedDevice != null) ...[
                const SizedBox(height: 8),

                // Sensor key, operator, and value in the same row
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Column(
                    children: [
                      // Sensor Type
                      DropdownButtonFormField<String>(
                        initialValue: sensorKeys.contains(condition['key'])
                            ? condition['key']
                            : null,
                        decoration: InputDecoration(
                          labelText: 'Sensor',
                          labelStyle: TextStyle(
                            color: Colors.blue.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.blue.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.blue.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                                color: Colors.blue.shade600, width: 2),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 6),
                        ),
                        items: sensorKeys.map((key) {
                          return DropdownMenuItem<String>(
                            value: key,
                            child: Text(
                              key.replaceAll('_', ' ').toUpperCase(),
                              style: const TextStyle(fontSize: 10),
                              overflow: TextOverflow.ellipsis,
                            ),
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

                      // Operator and Value in Row
                      Row(
                        children: [
                          // Operator
                          Expanded(
                            flex: 1,
                            child: DropdownButtonFormField<String>(
                              initialValue: condition['op'] ?? '>',
                              decoration: InputDecoration(
                                labelText: 'Op',
                                labelStyle: TextStyle(
                                  color: Colors.blue.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide:
                                      BorderSide(color: Colors.blue.shade300),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide:
                                      BorderSide(color: Colors.blue.shade300),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                      color: Colors.blue.shade600, width: 2),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 4, vertical: 6),
                              ),
                              items: const [
                                DropdownMenuItem(value: '>', child: Text('>')),
                                DropdownMenuItem(value: '<', child: Text('<')),
                                DropdownMenuItem(value: '==', child: Text('=')),
                                DropdownMenuItem(value: '!=', child: Text('≠')),
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

                          // Value
                          Expanded(
                            flex: 2,
                            child: TextFormField(
                              initialValue:
                                  condition['value']?.toString() ?? '0',
                              decoration: InputDecoration(
                                labelText: 'Value',
                                labelStyle: TextStyle(
                                  color: Colors.blue.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide:
                                      BorderSide(color: Colors.blue.shade300),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide:
                                      BorderSide(color: Colors.blue.shade300),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                      color: Colors.blue.shade600, width: 2),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 4, vertical: 6),
                              ),
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              style: const TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w500),
                              onChanged: (value) {
                                condition['value'] =
                                    double.tryParse(value) ?? 0;
                                _notifyChange();
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ] else if (condition['type'] == 'time') ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Column(
                  children: [
                    // Time Operator
                    DropdownButtonFormField<String>(
                      initialValue: condition['op'] ?? '>',
                      decoration: InputDecoration(
                        labelText: 'When',
                        labelStyle: TextStyle(
                          color: Colors.orange.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.orange.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.orange.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                              color: Colors.orange.shade600, width: 2),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 6),
                      ),
                      items: const [
                        DropdownMenuItem(value: '>', child: Text('After')),
                        DropdownMenuItem(value: '<', child: Text('Before')),
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
                    const SizedBox(height: 8),

                    // Time Value
                    TextFormField(
                      initialValue: condition['value']?.toString() ?? '18:00',
                      decoration: InputDecoration(
                        labelText: 'Time',
                        labelStyle: TextStyle(
                          color: Colors.orange.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.orange.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.orange.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                              color: Colors.orange.shade600, width: 2),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 6),
                      ),
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w500),
                      onChanged: (value) {
                        condition['value'] = value;
                        _notifyChange();
                      },
                    ),
                  ],
                ),
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

  void _findAndUpdateParent(Map<String, dynamic> group,
      List<dynamic> targetSiblings, List<dynamic> newChildren) {
    final children = group['children'] as List<dynamic>?;
    if (children == targetSiblings) {
      group['children'] = newChildren;
      return;
    }

    if (children != null) {
      for (final child in children) {
        if (child is Map<String, dynamic> && child['children'] != null) {
          _findAndUpdateParent(child, targetSiblings, newChildren);
        }
      }
    }
  }

  String? _getValidDeviceId(String? deviceId, List<Device> devices) {
    if (devices.isEmpty) {
      return '';
    }

    if (deviceId == null || deviceId.isEmpty) {
      return null;
    }

    // Check if the deviceId exists in the available devices
    final deviceExists = devices.any((device) => device.id == deviceId);
    return deviceExists ? deviceId : null;
  }
}
