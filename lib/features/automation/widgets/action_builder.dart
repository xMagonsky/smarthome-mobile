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

  @override
  void initState() {
    super.initState();
    actions = List<Map<String, dynamic>>.from(widget.initialActions);
    if (actions.isEmpty) {
      actions = [_createEmptyAction()];
    }
  }

  Map<String, dynamic> _createEmptyAction() {
    return {
      'action': 'set_state',
      'params': {'on': false},
      'device_id': '',
    };
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
        }).toList(),
        
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
    return Column(
      children: [
        // Action type
        DropdownButtonFormField<String>(
          value: action['action'] ?? 'set_state',
          decoration: const InputDecoration(
            labelText: 'Action Type',
            border: OutlineInputBorder(),
          ),
          items: const [
            DropdownMenuItem(value: 'set_state', child: Text('Set Device State')),
            DropdownMenuItem(value: 'set_brightness', child: Text('Set Brightness')),
            DropdownMenuItem(value: 'set_temperature', child: Text('Set Temperature')),
            DropdownMenuItem(value: 'set_color', child: Text('Set Color')),
            DropdownMenuItem(value: 'send_notification', child: Text('Send Notification')),
            DropdownMenuItem(value: 'delay', child: Text('Delay')),
          ],
          onChanged: (value) {
            setState(() {
              action['action'] = value!;
              // Reset params when action type changes
              switch (value) {
                case 'set_state':
                  action['params'] = {'on': false};
                  break;
                case 'set_brightness':
                  action['params'] = {'brightness': 100};
                  break;
                case 'set_temperature':
                  action['params'] = {'temperature': 20};
                  break;
                case 'set_color':
                  action['params'] = {'color': '#FFFFFF'};
                  break;
                case 'send_notification':
                  action['params'] = {'message': '', 'title': ''};
                  action['device_id'] = ''; // No device needed for notifications
                  break;
                case 'delay':
                  action['params'] = {'seconds': 5};
                  action['device_id'] = ''; // No device needed for delays
                  break;
              }
              _notifyChange();
            });
          },
        ),
        const SizedBox(height: 12),
        
        // Device selection (if needed)
        if (action['action'] != 'send_notification' && action['action'] != 'delay')
          DropdownButtonFormField<String>(
            value: _getValidDeviceId(action['device_id']?.toString()),
            decoration: const InputDecoration(
              labelText: 'Target Device',
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
              }).toList(),
            ],
            onChanged: (value) {
              setState(() {
                action['device_id'] = value ?? '';
                _notifyChange();
              });
            },
          ),
        
        if (action['action'] != 'send_notification' && action['action'] != 'delay')
          const SizedBox(height: 12),
        
        // Parameters based on action type
        ..._buildParameterFields(action),
      ],
    );
  }

  List<Widget> _buildParameterFields(Map<String, dynamic> action) {
    final params = action['params'] as Map<String, dynamic>? ?? {};
    final actionType = action['action'] ?? 'set_state';
    
    switch (actionType) {
      case 'set_state':
        return [
          SwitchListTile(
            title: const Text('Turn On'),
            value: params['on'] == true,
            onChanged: (value) {
              setState(() {
                params['on'] = value;
                _notifyChange();
              });
            },
          ),
        ];
        
      case 'set_brightness':
        return [
          TextFormField(
            initialValue: params['brightness']?.toString() ?? '100',
            decoration: const InputDecoration(
              labelText: 'Brightness (0-100)',
              border: OutlineInputBorder(),
              suffixText: '%',
            ),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              final brightness = int.tryParse(value) ?? 100;
              params['brightness'] = brightness.clamp(0, 100);
              _notifyChange();
            },
          ),
        ];
        
      case 'set_temperature':
        return [
          TextFormField(
            initialValue: params['temperature']?.toString() ?? '20',
            decoration: const InputDecoration(
              labelText: 'Temperature',
              border: OutlineInputBorder(),
              suffixText: '°C',
            ),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              params['temperature'] = double.tryParse(value) ?? 20.0;
              _notifyChange();
            },
          ),
        ];
        
      case 'set_color':
        return [
          TextFormField(
            initialValue: params['color']?.toString() ?? '#FFFFFF',
            decoration: const InputDecoration(
              labelText: 'Color (Hex)',
              border: OutlineInputBorder(),
              hintText: '#FFFFFF',
            ),
            onChanged: (value) {
              params['color'] = value;
              _notifyChange();
            },
          ),
        ];
        
      case 'send_notification':
        return [
          TextFormField(
            initialValue: params['title']?.toString() ?? '',
            decoration: const InputDecoration(
              labelText: 'Notification Title',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              params['title'] = value;
              _notifyChange();
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            initialValue: params['message']?.toString() ?? '',
            decoration: const InputDecoration(
              labelText: 'Notification Message',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
            onChanged: (value) {
              params['message'] = value;
              _notifyChange();
            },
          ),
        ];
        
      case 'delay':
        return [
          TextFormField(
            initialValue: params['seconds']?.toString() ?? '5',
            decoration: const InputDecoration(
              labelText: 'Delay (seconds)',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              params['seconds'] = int.tryParse(value) ?? 5;
              _notifyChange();
            },
          ),
        ];
        
      default:
        return [];
    }
  }

  void _notifyChange() {
    widget.onChanged(actions);
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
