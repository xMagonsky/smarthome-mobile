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
  String _selectedActionType = 'device_toggle';
  String _selectedActionDeviceId = '';
  String _timeValue = '18:00';
  bool _actionValue = true;

  @override
  void initState() {
    super.initState();
    if (widget.automation != null) {
      _nameController.text = widget.automation!.name;
      _selectedTriggerType = widget.automation!.trigger.type;
      _selectedDeviceId = widget.automation!.trigger.value;
      _selectedActionType = widget.automation!.action.type;
      _selectedActionDeviceId = widget.automation!.action.deviceId;
      _timeValue = widget.automation!.trigger.value;
      _actionValue = widget.automation!.action.value == 'true';
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
              ],
              onChanged: (value) {
                setState(() {
                  _selectedTriggerType = value!;
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
                initialValue: _selectedDeviceId.isEmpty ? null : _selectedDeviceId,
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
                    _selectedDeviceId = value!;
                  });
                },
              ),
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
              ],
              onChanged: (value) {
                setState(() {
                  _selectedActionType = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _selectedActionDeviceId.isEmpty ? null : _selectedActionDeviceId,
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
                  _selectedActionDeviceId = value!;
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
        value: _selectedTriggerType == 'time' ? _timeValue : _selectedDeviceId,
        description: _selectedTriggerType == 'time'
            ? 'Daily at $_timeValue'
            : 'When device state changes',
      );

      final action = AutomationAction(
        type: _selectedActionType,
        deviceId: _selectedActionDeviceId,
        value: _actionValue.toString(),
        description: _actionValue ? 'Turn on device' : 'Turn off device',
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
