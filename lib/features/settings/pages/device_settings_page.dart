import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/device_provider.dart';

class DeviceSettingsPage extends StatelessWidget {
  const DeviceSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final deviceProvider = Provider.of<DeviceProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Device Settings'),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16),
          _buildSettingsSection(
            context,
            'Device Management',
            [
              ListTile(
                leading: const Icon(Icons.devices),
                title: const Text('Connected Devices'),
                subtitle: Text('${deviceProvider.devices.length} devices'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // Navigate to device list
                },
              ),
              ListTile(
                leading: const Icon(Icons.add),
                title: const Text('Add New Device'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // Navigate to add device page
                },
              ),
            ],
          ),
          _buildSettingsSection(
            context,
            'Device Groups',
            [
              ListTile(
                leading: const Icon(Icons.group_work),
                title: const Text('Manage Groups'),
                subtitle: const Text('Organize devices into rooms'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // Navigate to groups management
                },
              ),
            ],
          ),
          _buildSettingsSection(
            context,
            'Device Preferences',
            [
              _buildSwitchTile(
                context,
                'Auto-discover Devices',
                Icons.search,
                true, // This would be stored separately
                (value) {
                  // Handle auto-discover toggle
                },
              ),
              _buildSwitchTile(
                context,
                'Device Status Updates',
                Icons.sync,
                true, // This would be stored separately
                (value) {
                  // Handle status updates toggle
                },
              ),
            ],
          ),
          _buildSettingsSection(
            context,
            'Advanced',
            [
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Device Firmware Updates'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // Navigate to firmware updates
                },
              ),
              ListTile(
                leading: const Icon(Icons.security),
                title: const Text('Device Security'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // Navigate to security settings
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(BuildContext context, String title, List<Widget> tiles) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
        ...tiles,
      ],
    );
  }

  Widget _buildSwitchTile(
    BuildContext context,
    String title,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}
