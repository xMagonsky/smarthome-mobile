import 'package:flutter/material.dart';
import '../widgets/dashboard_card.dart';
import '../../devices/pages/devices_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final rooms = ['Living Room', 'Kitchen', 'Bedroom'];

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: rooms.length,
      itemBuilder: (context, index) {
        return DashboardCard(
          title: rooms[index],
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => DeviceListPage(room: rooms[index]),
              ),
            );
          },
        );
      },
    );
  }
}