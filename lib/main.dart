
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/providers/device_provider.dart';
import 'features/home/pages/home_page.dart';

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
        home: const HomePage(),
        // For named routes in future: routes: AppRoutes.routes,
      ),
    );
  }
}
