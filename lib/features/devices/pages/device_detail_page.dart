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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Type: ${device.type}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            if (device.type == 'sensor')
              _buildSensorDetails()
            else
              _buildDeviceControls(deviceProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildSensorDetails() {
    if (device.state.isEmpty) {
      return const Text('No sensor data available');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Sensor Readings:',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 10),
        ...device.state.entries.map((entry) => Card(
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: ListTile(
                leading: _getSensorIcon(entry.key),
                title: Text(entry.key.toUpperCase()),
                trailing: Text(
                  '${entry.value}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            )),
      ],
    );
  }

  Widget _buildDeviceControls(DeviceProvider deviceProvider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Switch(
            value: device.isOn,
            onChanged: (value) {
              deviceProvider.toggleDevice(device.id, value);
            },
          ),
          const Text('Toggle On/Off'),
        ],
      ),
    );
  }

  Icon _getSensorIcon(String sensorType) {
    switch (sensorType.toLowerCase()) {
      case 'temperature':
        return const Icon(Icons.thermostat, color: Colors.red);
      case 'humidity':
        return const Icon(Icons.water_drop, color: Colors.blue);
      case 'co2':
        return const Icon(Icons.cloud, color: Colors.green);
      default:
        return const Icon(Icons.sensors, color: Colors.grey);
    }
  }
}