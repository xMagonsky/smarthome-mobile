import 'package:flutter/material.dart';

class DashboardCard extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const DashboardCard({super.key, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        child: Center(
          child: Text(title, style: const TextStyle(fontSize: 18)),
        ),
      ),
    );
  }
}