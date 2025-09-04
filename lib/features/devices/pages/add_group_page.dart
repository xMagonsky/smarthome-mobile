import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/group_provider.dart';
import '../../../core/providers/device_provider.dart';

class AddGroupPage extends StatefulWidget {
  const AddGroupPage({super.key});

  @override
  State<AddGroupPage> createState() => _AddGroupPageState();
}

class _AddGroupPageState extends State<AddGroupPage> {
  final _nameController = TextEditingController();
  final List<String> _selectedDeviceIds = [];

  @override
  Widget build(BuildContext context) {
    final groupProvider = Provider.of<GroupProvider>(context);
    final deviceProvider = Provider.of<DeviceProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Group'),
        actions: [
          TextButton(
            onPressed: () {
              if (_nameController.text.isNotEmpty) {
                groupProvider.addGroup(_nameController.text, _selectedDeviceIds);
                Navigator.pop(context);
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
              decoration: const InputDecoration(labelText: 'Group Name'),
            ),
            const SizedBox(height: 20),
            const Text('Select Devices:'),
            Expanded(
              child: ListView.builder(
                itemCount: deviceProvider.devices.length,
                itemBuilder: (context, index) {
                  final device = deviceProvider.devices[index];
                  return CheckboxListTile(
                    title: Text(device.name),
                    value: _selectedDeviceIds.contains(device.id),
                    onChanged: (bool? value) {
                      setState(() {
                        if (value == true) {
                          _selectedDeviceIds.add(device.id);
                        } else {
                          _selectedDeviceIds.remove(device.id);
                        }
                      });
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
