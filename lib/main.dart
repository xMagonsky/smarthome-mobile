
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/providers/device_provider.dart';
import 'features/home/pages/home_page.dart';
import 'features/automation/pages/automation_page.dart';
import 'features/settings/pages/settings_page.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DeviceProvider()),
        // Add more providers for other features as needed
      ],
      child: MaterialApp(
        title: 'Smart Home App',
        theme: appTheme,
        home: const MainScreen(),
        // For named routes in future: routes: AppRoutes.routes,
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    HomePage(),
    AutomationPage(),
    SettingsPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    String title;
    switch (_selectedIndex) {
      case 0:
        title = 'Home Dashboard';
        break;
      case 1:
        title = 'Automation';
        break;
      case 2:
        title = 'Settings';
        break;
      default:
        title = 'Smart Home App';
    }

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_remote),
            label: 'Automation',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }
}
