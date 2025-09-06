import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/automation_provider.dart';
import '../../../core/providers/device_provider.dart';
import '../models/rule.dart';
import '../widgets/condition_builder.dart';
import '../widgets/action_builder.dart';
import '../widgets/automation_preview.dart';

class AddAutomationPage extends StatefulWidget {
  final Rule? automation;

  const AddAutomationPage({super.key, this.automation});

  @override
  State<AddAutomationPage> createState() => _AddAutomationPageState();
}

class _AddAutomationPageState extends State<AddAutomationPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  
  Map<String, dynamic> conditions = {};
  List<Map<String, dynamic>> actions = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.automation != null) {
      _nameController.text = widget.automation!.name;
      conditions = _conditionsToMap(widget.automation!.conditions);
      actions = widget.automation!.actions.map((action) => {
        'action': action.action,
        'params': Map<String, dynamic>.from(action.params),
        'device_id': action.device_id.toString(), // Ensure device_id is always a string
      }).toList();
    } else {
      // Initialize with default structure
      conditions = {
        'operator': 'AND',
        'children': [
          {
            'type': 'sensor',
            'op': '>',
            'value': 0,
            'key': 'temperature',
            'device_id': '',
          }
        ],
      };
      actions = [
        {
          'action': 'set_state',
          'params': {'on': false},
          'device_id': '',
        }
      ];
    }
  }

  Map<String, dynamic> _conditionsToMap(Conditions conditions) {
    return {
      'operator': conditions.operator,
      'children': conditions.children.map((child) => {
        'type': child.type,
        'op': child.op,
        'value': child.value, // Keep as dynamic since it can be int, double, or string
        'key': child.key,
        'device_id': child.device_id?.toString() ?? '', // Ensure deviceId is always a string
        'min_change': child.min_change,
      }).toList(),
    };
  }

  @override
  Widget build(BuildContext context) {
    final deviceProvider = Provider.of<DeviceProvider>(context);
    final automationProvider = Provider.of<AutomationProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.automation == null ? 'Add Automation' : 'Edit Automation'),
        actions: [
          if (widget.automation != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _deleteAutomation(),
            ),
        ],
      ),
      body: Stack(
        children: [
          Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Automation name
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Automation Name',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.label),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Conditions builder
                ConditionBuilder(
                  initialConditions: conditions,
                  onChanged: (newConditions) {
                    setState(() {
                      conditions = newConditions;
                    });
                  },
                  devices: deviceProvider.devices,
                ),
                const SizedBox(height: 24),

                // Actions builder
                ActionBuilder(
                  initialActions: actions,
                  onChanged: (newActions) {
                    setState(() {
                      actions = newActions;
                    });
                  },
                  devices: deviceProvider.devices,
                ),
                const SizedBox(height: 24),

                // Preview
                AutomationPreviewWidget(
                  conditions: conditions,
                  actions: actions,
                ),
                const SizedBox(height: 32),

                // Save button
                ElevatedButton(
                  onPressed: isLoading ? null : () => _saveAutomation(),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 56),
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Save Automation',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
          
          // Loading overlay for provider operations
          if (automationProvider.isLoading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _saveAutomation() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validate that required fields are filled
    if (!_validateConditions() || !_validateActions()) {
      _showErrorSnackBar('Please fill all required fields');
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final automationProvider = Provider.of<AutomationProvider>(context, listen: false);

      if (widget.automation == null) {
        // Create new automation
        await automationProvider.addAutomation(
          _nameController.text,
          conditions,
          actions,
        );
      } else {
        // Update existing automation
        await automationProvider.updateAutomation(
          widget.automation!.id,
          _nameController.text,
          conditions,
          actions,
        );
      }

      if (automationProvider.errorMessage == null) {
        if (mounted) Navigator.pop(context);
        _showSuccessSnackBar(widget.automation == null ? 'Automation created successfully' : 'Automation updated successfully');
      } else {
        _showErrorSnackBar(automationProvider.errorMessage!);
      }
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _deleteAutomation() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Automation'),
        content: const Text('Are you sure you want to delete this automation?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && widget.automation != null) {
      final automationProvider = Provider.of<AutomationProvider>(context, listen: false);
      await automationProvider.removeAutomation(widget.automation!.id);
      
      if (automationProvider.errorMessage == null) {
        if (mounted) Navigator.pop(context);
        _showSuccessSnackBar('Automation deleted successfully');
      } else {
        _showErrorSnackBar(automationProvider.errorMessage!);
      }
    }
  }

  bool _validateConditions() {
    final children = conditions['children'] as List<dynamic>?;
    if (children == null || children.isEmpty) {
      return false;
    }

    for (final child in children) {
      if (child is Map<String, dynamic>) {
        if (child['type'] == 'sensor') {
          if (child['device_id'] == null || child['device_id'].toString().isEmpty) {
            return false;
          }
        }
      }
    }
    return true;
  }

  bool _validateActions() {
    if (actions.isEmpty) {
      return false;
    }

    for (final action in actions) {
      if (action['action'] != 'send_notification' && action['action'] != 'delay') {
        if (action['device_id'] == null || action['device_id'].toString().isEmpty) {
          return false;
        }
      }
    }
    return true;
  }

  void _showSuccessSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}
