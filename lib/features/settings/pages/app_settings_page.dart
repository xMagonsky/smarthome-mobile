import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/settings_provider.dart';

class AppSettingsPage extends StatelessWidget {
  const AppSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('App Settings'),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16),
          _buildSettingsSection(
            context,
            'Appearance',
            [
              _buildSwitchTile(
                context,
                'Dark Mode',
                Icons.dark_mode,
                settingsProvider.settings.darkModeEnabled,
                (value) => settingsProvider.toggleDarkMode(value),
              ),
            ],
          ),
          _buildSettingsSection(
            context,
            'Language',
            [
              ListTile(
                leading: const Icon(Icons.language),
                title: const Text('Language'),
                subtitle: Text(_getLanguageName(settingsProvider.settings.language)),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showLanguageDialog(context, settingsProvider),
              ),
            ],
          ),
          _buildSettingsSection(
            context,
            'Updates',
            [
              _buildSwitchTile(
                context,
                'Auto Update',
                Icons.system_update,
                settingsProvider.settings.autoUpdateEnabled,
                (value) => settingsProvider.toggleAutoUpdate(value),
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

  String _getLanguageName(String languageCode) {
    switch (languageCode) {
      case 'en':
        return 'English';
      case 'pl':
        return 'Polski';
      case 'es':
        return 'Español';
      case 'de':
        return 'Deutsch';
      default:
        return 'English';
    }
  }

  void _showLanguageDialog(BuildContext context, SettingsProvider settingsProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Language'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildLanguageOption(context, 'English', 'en', settingsProvider),
              _buildLanguageOption(context, 'Polski', 'pl', settingsProvider),
              _buildLanguageOption(context, 'Español', 'es', settingsProvider),
              _buildLanguageOption(context, 'Deutsch', 'de', settingsProvider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLanguageOption(BuildContext context, String languageName, String languageCode, SettingsProvider settingsProvider) {
    return ListTile(
      title: Text(languageName),
      trailing: settingsProvider.settings.language == languageCode
          ? const Icon(Icons.check, color: Colors.green)
          : null,
      onTap: () {
        settingsProvider.updateLanguage(languageCode);
        Navigator.of(context).pop();
      },
    );
  }
}
