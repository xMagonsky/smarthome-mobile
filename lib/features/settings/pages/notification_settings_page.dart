import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/settings_provider.dart';

class NotificationSettingsPage extends StatelessWidget {
  const NotificationSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Settings'),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16),
          _buildSettingsSection(
            context,
            'General',
            [
              _buildSwitchTile(
                context,
                'Push Notifications',
                Icons.notifications,
                settingsProvider.settings.notificationsEnabled,
                (value) => settingsProvider.toggleNotifications(value),
              ),
            ],
          ),
          _buildSettingsSection(
            context,
            'Device Notifications',
            [
              _buildSwitchTile(
                context,
                'Device Status Changes',
                Icons.devices,
                true, // This would be stored separately
                (value) {
                  // Handle device notifications toggle
                },
              ),
              _buildSwitchTile(
                context,
                'Automation Triggers',
                Icons.autorenew,
                true, // This would be stored separately
                (value) {
                  // Handle automation notifications toggle
                },
              ),
              _buildSwitchTile(
                context,
                'Security Alerts',
                Icons.security,
                true, // This would be stored separately
                (value) {
                  // Handle security notifications toggle
                },
              ),
            ],
          ),
          _buildSettingsSection(
            context,
            'Schedule',
            [
              ListTile(
                leading: const Icon(Icons.schedule),
                title: const Text('Quiet Hours'),
                subtitle: const Text('10:00 PM - 8:00 AM'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showQuietHoursDialog(context),
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

  void _showQuietHoursDialog(BuildContext context) {
    TimeOfDay startTime = const TimeOfDay(hour: 22, minute: 0);
    TimeOfDay endTime = const TimeOfDay(hour: 8, minute: 0);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Quiet Hours'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Start Time'),
                trailing: Text(startTime.format(context)),
                onTap: () async {
                  final TimeOfDay? picked = await showTimePicker(
                    context: context,
                    initialTime: startTime,
                  );
                  if (picked != null) {
                    startTime = picked;
                  }
                },
              ),
              ListTile(
                title: const Text('End Time'),
                trailing: Text(endTime.format(context)),
                onTap: () async {
                  final TimeOfDay? picked = await showTimePicker(
                    context: context,
                    initialTime: endTime,
                  );
                  if (picked != null) {
                    endTime = picked;
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Save quiet hours
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
