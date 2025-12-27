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
        final live =
            deviceProvider.getDeviceById(widget.device.id) ?? widget.device;

        return Scaffold(
          appBar: AppBar(
            title: Text(live.name),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () =>
                    _showRenameDialog(context, deviceProvider, live),
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () =>
                    _showDeleteDialog(context, deviceProvider, live),
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
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                if (live.type == 'sensor')
                  _buildSensorDetails(live)
                else if (live.type == 'thermostat')
                  _buildThermostatDetails(deviceProvider, live)
                else
                  _buildLightDetails(deviceProvider, live),
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

  // For light and similar devices: list each state entry with a toggle.
  Widget _buildLightDetails(DeviceProvider deviceProvider, Device live) {
    if (live.state.isEmpty) {
      return const Text('No controllable states');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Controls:',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 10),
        ...live.state.entries.map((entry) {
          final key = entry.key;
          final current = entry.value;
          final currentAsBool =
              current == true; // anything else treated as false
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: ListTile(
              leading: const Icon(Icons.toggle_on, color: Colors.amber),
              title: Text(key.toUpperCase()),
              subtitle: current is bool
                  ? null
                  : Text('Current: $current',
                      style: const TextStyle(color: Colors.grey)),
              trailing: Switch(
                value: currentAsBool,
                onChanged: (val) {
                  deviceProvider.publishStateToggle(live, key, val);
                },
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildThermostatDetails(DeviceProvider deviceProvider, Device live) {
    final isOn = live.state['on'] ?? false;
    final currentTemp = (live.state['temperature'] ?? 20.0).toDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Controls:',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 10),
        // Power toggle
        Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            leading: Icon(
              Icons.power_settings_new,
              color: isOn ? Colors.orange : Colors.grey,
            ),
            title: const Text('POWER'),
            trailing: Switch(
              value: isOn,
              onChanged: (val) {
                deviceProvider.publishStateToggle(live, 'on', val);
              },
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Temperature slider
        Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.thermostat,
                          color: isOn ? Colors.orange : Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'TEMPERATURE',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${currentTemp.toStringAsFixed(0)}°C',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: isOn ? Colors.orange : Colors.grey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Slider(
                  value: currentTemp,
                  min: 15.0,
                  max: 30.0,
                  divisions: 30,
                  label: '${currentTemp.toStringAsFixed(0)}°C',
                  activeColor: isOn ? Colors.orange : Colors.grey,
                  inactiveColor: Colors.grey.shade300,
                  onChanged: isOn
                      ? (value) {
                          deviceProvider.updateThermostatTemperature(
                            live,
                            value,
                          );
                        }
                      : null,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '15°C',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    Text(
                      '30°C',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
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

  void _showRenameDialog(
      BuildContext context, DeviceProvider deviceProvider, Device device) {
    final TextEditingController controller =
        TextEditingController(text: device.name);

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Rename Device'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Device Name',
              border: OutlineInputBorder(),
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final newName = controller.text.trim();
                if (newName.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Name cannot be empty')),
                  );
                  return;
                }

                Navigator.of(dialogContext).pop();

                final success =
                    await deviceProvider.updateDeviceName(device.id, newName);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(success
                          ? 'Device renamed successfully'
                          : 'Failed to rename device'),
                    ),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteDialog(
      BuildContext context, DeviceProvider deviceProvider, Device device) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Delete Device'),
          content: Text(
              'Are you sure you want to delete "${device.name}"? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();

                final success = await deviceProvider.deleteDevice(device.id);
                if (context.mounted) {
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Device deleted successfully')),
                    );
                    Navigator.of(context).pop();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Failed to delete device')),
                    );
                  }
                }
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
