import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/settings_provider.dart';
import '../pages/profile_settings_page.dart';
import '../pages/app_settings_page.dart';
import '../pages/device_settings_page.dart';
import '../pages/notification_settings_page.dart';

class SettingsList extends StatelessWidget {
  const SettingsList({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);

    return ListView(
      children: [
        const SizedBox(height: 16),
        _buildSettingsSection(
          context,
          'Account',
          [
            _buildSettingsTile(
              context,
              'Profile',
              Icons.person,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ProfileSettingsPage(),
                  ),
                );
              },
            ),
          ],
        ),
        _buildSettingsSection(
          context,
          'App Settings',
          [
            _buildSettingsTile(
              context,
              'Appearance',
              Icons.palette,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AppSettingsPage(),
                  ),
                );
              },
            ),
            _buildSettingsTile(
              context,
              'Notifications',
              Icons.notifications,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const NotificationSettingsPage(),
                  ),
                );
              },
            ),
            _buildSwitchTile(
              context,
              'Auto Update',
              Icons.system_update,
              settingsProvider.settings.autoUpdateEnabled,
              (value) => settingsProvider.toggleAutoUpdate(value),
            ),
          ],
        ),
        _buildSettingsSection(
          context,
          'Devices & Services',
          [
            _buildSettingsTile(
              context,
              'Device Settings',
              Icons.devices,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const DeviceSettingsPage(),
                  ),
                );
              },
            ),
            _buildSwitchTile(
              context,
              'Location Services',
              Icons.location_on,
              settingsProvider.settings.locationServicesEnabled,
              (value) => settingsProvider.toggleLocationServices(value),
            ),
          ],
        ),
        _buildSettingsSection(
          context,
          'Support',
          [
            _buildSettingsTile(
              context,
              'Help & Support',
              Icons.help,
              () {
                // Navigate to help page
              },
            ),
            _buildSettingsTile(
              context,
              'About',
              Icons.info,
              () {
                // Navigate to about page
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildSettingsTile(
          context,
          'Sign Out',
          Icons.logout,
          () {
            // Handle sign out
            _showSignOutDialog(context);
          },
          color: Colors.red,
        ),
      ],
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

  Widget _buildSettingsTile(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap, {
    Color? color,
  }) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title, style: TextStyle(color: color)),
      trailing: Icon(Icons.chevron_right, color: color ?? Colors.grey),
      onTap: onTap,
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

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sign Out'),
          content: const Text('Are you sure you want to sign out?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Handle sign out logic
                Navigator.of(context).pop();
              },
              child: const Text('Sign Out', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
