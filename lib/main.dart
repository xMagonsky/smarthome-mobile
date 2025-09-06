import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smarthome_mobile/core/providers/rule_provider.dart';

import 'core/theme/app_theme.dart';
import 'core/providers/device_provider.dart';
import 'core/providers/automation_provider.dart';
import 'core/providers/settings_provider.dart';
import 'core/providers/auth_provider.dart';
import 'core/services/automation_service.dart';
import 'core/services/automation_api_service.dart';
import 'core/config/api_config.dart';
import 'features/home/pages/home_page.dart';
import 'features/automation/pages/automation_page.dart';
import 'features/settings/pages/settings_page.dart';
import 'features/auth/screens/login_screen.dart';

void main() {
  runApp(const MainApp());
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.checkAuthStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        if (auth.isAuthenticated) {
          // Load devices after authentication is confirmed
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final deviceProvider = Provider.of<DeviceProvider>(context, listen: false);
            deviceProvider.loadDevices();
          });
          return const MainScreen();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  late AutomationService automationService;

  @override
  void initState() {
    super.initState();
    // AutomationService will be initialized after providers are created
  }

  @override
  Widget build(BuildContext context) {
    // Create the API service first
    final automationApiService = AutomationApiService(baseUrl: ApiConfig.baseUrl);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DeviceProvider()),
        ChangeNotifierProvider(create: (_) => AutomationProvider(apiService: automationApiService)),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => RuleProvider()),
        // Add more providers for other features as needed
      ],
      child: Builder(
        builder: (context) {
          // Initialize AutomationService after providers are available
          final deviceProvider = Provider.of<DeviceProvider>(context, listen: false);
          final automationProvider = Provider.of<AutomationProvider>(context, listen: false);
          automationService = AutomationService(
            deviceProvider: deviceProvider,
            automationProvider: automationProvider,
          );

          return MaterialApp(
            title: 'Smart Home App',
            theme: appTheme,
            home: const AuthWrapper(),
            routes: {
              '/home': (context) => const MainScreen(),
            },
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    automationService.dispose();
    super.dispose();
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  bool _isNavigatingToLogin = false;

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

    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        // If user is no longer authenticated, navigate back to login
        if (!auth.isAuthenticated && !_isNavigatingToLogin) {
          _isNavigatingToLogin = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
            }
          });
          return const SizedBox.shrink(); // Return empty widget while navigating
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
      },
    );
  }
}
