import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/device.dart';
import '../../../core/providers/device_provider.dart';

class DeviceDetailPage extends StatelessWidget {
  final Device device;

  const DeviceDetailPage({super.key, required this.device});

  @override
  Widget build(BuildContext context) {
    final deviceProvider = Provider.of<DeviceProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(device.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // TODO: Navigate to edit device page
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Type: ${device.type}', style: const TextStyle(fontSize: 20)),
            Switch(
              value: device.isOn,
              onChanged: (value) {
                deviceProvider.toggleDevice(device.id, value);
              },
            ),
            const Text('Toggle On/Off'),
          ],
        ),
      ),
    );
  }
}