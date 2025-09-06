import 'package:flutter/material.dart';
import '../../../core/services/api_service.dart';

class AddDevicePage extends StatefulWidget {
  const AddDevicePage({super.key});

  @override
  State<AddDevicePage> createState() => _AddDevicePageState();
}

class _AddDevicePageState extends State<AddDevicePage> {
  final _nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Device'),
        actions: [
          TextButton(
            onPressed: () async {
              if (_nameController.text.isNotEmpty) {
                final response = await ApiService().setDeviceOwner(_nameController.text);
                if (response.statusCode == 200) {
                  if (mounted) Navigator.pop(this.context);
                } else {
                  print('Failed to add device: ${response.body}');
                  if (mounted) {
                    ScaffoldMessenger.of(this.context).showSnackBar(
                      const SnackBar(content: Text('Failed to add device')),
                    );
                  }
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Device Name'),
            ),
          ],
        ),
      ),
    );
  }
}
