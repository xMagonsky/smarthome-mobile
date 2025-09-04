import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/automation_provider.dart';
import '../../../core/providers/device_provider.dart';
import '../models/automation.dart';

class AddAutomationPage extends StatefulWidget {
  final Automation? automation;

  const AddAutomationPage({super.key, this.automation});

  @override
  State<AddAutomationPage> createState() => _AddAutomationPageState();
}

class _AddAutomationPageState extends State<AddAutomationPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String _selectedTriggerType = 'time';
  String _selectedDeviceId = '';
  String _selectedSensorType = 'temperature';
  String _selectedActionType = 'device_toggle';
  String _selectedActionDeviceId = '';
  String _timeValue = '18:00';
  String _sensorValue = '25';
  String _sensorOperator = '>';
  dynamic _actionValue = true;

  @override
  void initState() {
    super.initState();
    if (widget.automation != null) {
      _nameController.text = widget.automation!.name;
      _selectedTriggerType = widget.automation!.trigger.type;
      _selectedActionType = widget.automation!.action.type;
      _selectedActionDeviceId = widget.automation!.action.deviceId;
      _actionValue = widget.automation!.action.value == 'true';

      // Set values based on trigger type
      if (_selectedTriggerType == 'time') {
        _timeValue = widget.automation!.trigger.value;
        _selectedDeviceId = '';
      } else if (_selectedTriggerType == 'device') {
        _selectedDeviceId = widget.automation!.trigger.value;
        _timeValue = '18:00'; // Default time value
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceProvider = Provider.of<DeviceProvider>(context);
    final automationProvider = Provider.of<AutomationProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.automation == null ? 'Add Automation' : 'Edit Automation'),
        actions: [
          if (widget.automation != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                automationProvider.removeAutomation(widget.automation!.id);
                Navigator.pop(context);
              },
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Automation Name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            const Text('Trigger', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            DropdownButtonFormField<String>(
              initialValue: _selectedTriggerType,
              decoration: const InputDecoration(
                labelText: 'Trigger Type',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'time', child: Text('Time')),
                DropdownMenuItem(value: 'device', child: Text('Device State')),
                DropdownMenuItem(value: 'sensor', child: Text('Sensor Value')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedTriggerType = value!;
                  // Reset dependent values when trigger type changes
                  if (value == 'time') {
                    _selectedDeviceId = '';
                  } else if (value == 'device') {
                    _timeValue = '18:00'; // Reset to default
                    _selectedDeviceId = ''; // Reset device selection
                  }
                });
              },
            ),
            const SizedBox(height: 16),
            if (_selectedTriggerType == 'time')
              TextFormField(
                initialValue: _timeValue,
                decoration: const InputDecoration(
                  labelText: 'Time (HH:MM)',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  _timeValue = value;
                },
              ),
            if (_selectedTriggerType == 'device')
              DropdownButtonFormField<String>(
                initialValue: (_selectedDeviceId.isNotEmpty && deviceProvider.devices.any((device) => device.id == _selectedDeviceId))
                    ? _selectedDeviceId
                    : null,
                decoration: const InputDecoration(
                  labelText: 'Device',
                  border: OutlineInputBorder(),
                ),
                items: deviceProvider.devices.map((device) {
                  return DropdownMenuItem(
                    value: device.id,
                    child: Text(device.name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedDeviceId = value ?? '';
                  });
                },
              ),
            if (_selectedTriggerType == 'sensor') ...[
              DropdownButtonFormField<String>(
                initialValue: (_selectedDeviceId.isNotEmpty && deviceProvider.devices.any((device) => device.id == _selectedDeviceId))
                    ? _selectedDeviceId
                    : null,
                decoration: const InputDecoration(
                  labelText: 'Sensor Device',
                  border: OutlineInputBorder(),
                ),
                items: deviceProvider.devices
                    .where((device) => device.sensorValues != null && device.sensorValues!.isNotEmpty)
                    .map((device) {
                  return DropdownMenuItem(
                    value: device.id,
                    child: Text(device.name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedDeviceId = value ?? '';
                  });
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedSensorType,
                decoration: const InputDecoration(
                  labelText: 'Sensor Type',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'temperature', child: Text('Temperature (°C)')),
                  DropdownMenuItem(value: 'humidity', child: Text('Humidity (%)')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedSensorType = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<String>(
                      initialValue: _sensorOperator,
                      decoration: const InputDecoration(
                        labelText: 'Operator',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: '>', child: Text('>')),
                        DropdownMenuItem(value: '<', child: Text('<')),
                        DropdownMenuItem(value: '>=', child: Text('≥')),
                        DropdownMenuItem(value: '<=', child: Text('≤')),
                        DropdownMenuItem(value: '==', child: Text('=')),
                        DropdownMenuItem(value: '!=', child: Text('≠')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _sensorOperator = value!;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      initialValue: _sensorValue,
                      decoration: const InputDecoration(
                        labelText: 'Value',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        _sensorValue = value;
                      },
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            const Text('Action', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            DropdownButtonFormField<String>(
              initialValue: _selectedActionType,
              decoration: const InputDecoration(
                labelText: 'Action Type',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'device_toggle', child: Text('Toggle Device')),
                DropdownMenuItem(value: 'device_set_value', child: Text('Set Device Value')),
                DropdownMenuItem(value: 'notification', child: Text('Send Notification')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedActionType = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: (_selectedActionDeviceId.isNotEmpty && deviceProvider.devices.any((device) => device.id == _selectedActionDeviceId))
                  ? _selectedActionDeviceId
                  : null,
              decoration: const InputDecoration(
                labelText: 'Target Device',
                border: OutlineInputBorder(),
              ),
              items: deviceProvider.devices.map((device) {
                return DropdownMenuItem(
                  value: device.id,
                  child: Text(device.name),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedActionDeviceId = value ?? '';
                });
              },
            ),
            const SizedBox(height: 16),
            if (_selectedActionType == 'device_toggle')
              SwitchListTile(
                title: const Text('Turn On'),
                value: _actionValue,
                onChanged: (value) {
                  setState(() {
                    _actionValue = value;
                  });
                },
              ),
            if (_selectedActionType == 'device_set_value')
              TextFormField(
                initialValue: _actionValue.toString(),
                decoration: const InputDecoration(
                  labelText: 'Value',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  // For now, just store as string, can be parsed later based on device type
                  _actionValue = value.isNotEmpty ? double.tryParse(value) ?? true : true;
                },
              ),
            if (_selectedActionType == 'notification')
              TextFormField(
                initialValue: _actionValue.toString(),
                decoration: const InputDecoration(
                  labelText: 'Notification Message',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                onChanged: (value) {
                  _actionValue = value;
                },
              ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saveAutomation,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Save Automation'),
            ),
          ],
        ),
      ),
    );
  }

  void _saveAutomation() {
    if (_formKey.currentState!.validate()) {
      final automationProvider = Provider.of<AutomationProvider>(context, listen: false);

      final trigger = Trigger(
        type: _selectedTriggerType,
        value: _selectedTriggerType == 'time'
            ? _timeValue
            : _selectedTriggerType == 'sensor'
                ? _selectedDeviceId
                : _selectedDeviceId,
        sensorType: _selectedTriggerType == 'sensor' ? _selectedSensorType : '',
        description: _selectedTriggerType == 'time'
            ? 'Daily at $_timeValue'
            : _selectedTriggerType == 'sensor'
                ? 'When $_selectedSensorType $_sensorOperator $_sensorValue'
                : 'When device state changes',
      );

      final action = AutomationAction(
        type: _selectedActionType,
        deviceId: _selectedActionType == 'notification' ? '' : _selectedActionDeviceId,
        value: _actionValue,
        description: _selectedActionType == 'device_toggle'
            ? (_actionValue ? 'Turn on device' : 'Turn off device')
            : _selectedActionType == 'device_set_value'
                ? 'Set device value to $_actionValue'
                : 'Send notification: $_actionValue',
      );

      if (widget.automation == null) {
        // Add new automation
        final automation = Automation(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: _nameController.text,
          trigger: trigger,
          action: action,
        );
        automationProvider.addAutomation(automation);
      } else {
        // Update existing automation
        final updatedAutomation = Automation(
          id: widget.automation!.id,
          name: _nameController.text,
          trigger: trigger,
          action: action,
          isEnabled: widget.automation!.isEnabled,
        );
        automationProvider.removeAutomation(widget.automation!.id);
        automationProvider.addAutomation(updatedAutomation);
      }

      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}
