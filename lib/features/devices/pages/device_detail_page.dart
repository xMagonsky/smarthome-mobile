import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/device.dart';
import '../../../core/providers/device_provider.dart';

class DeviceDetailPage extends StatefulWidget {
  final Device device;

  const DeviceDetailPage({super.key, required this.device});

  @override
  State<DeviceDetailPage> createState() => _DeviceDetailPageState();
}

class _DeviceDetailPageState extends State<DeviceDetailPage> {
  DeviceProvider? _deviceProvider;
  bool _subscribed = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Safely obtain ancestor references here
    _deviceProvider ??= context.read<DeviceProvider>();
    if (!_subscribed && _deviceProvider != null) {
      _deviceProvider!.subscribeToDeviceState(widget.device);
      _subscribed = true;
    }
  }

  @override
  void dispose() {
    // Unsubscribe using cached provider reference (no context lookup)
    _deviceProvider?.unsubscribeFromDeviceState(widget.device);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DeviceProvider>(
      builder: (context, deviceProvider, _) {
        // Get the freshest device instance from provider by id
        final live = deviceProvider.getDeviceById(widget.device.id) ?? widget.device;

        return Scaffold(
          appBar: AppBar(
            title: Text(live.name),
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
                  'Type: ${live.type}',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                if (live.type == 'sensor')
                  _buildSensorDetails(live)
                else
                  _buildDeviceControls(deviceProvider, live),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSensorDetails(Device live) {
    if (live.state.isEmpty) {
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
        ...live.state.entries.map((entry) => Card(
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: ListTile(
                leading: _getSensorIcon(entry.key),
                title: Text(entry.key.toUpperCase()),
                trailing: Text(
                  '${entry.value}',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            )),
      ],
    );
  }

  Widget _buildDeviceControls(DeviceProvider deviceProvider, Device live) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Switch(
            value: live.isOn,
            onChanged: (value) {
              deviceProvider.toggleDevice(live.id, value);
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
