import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/device_provider.dart';
import 'device_detail_page.dart';
import '../widgets/device_card.dart';

class DeviceListPage extends StatelessWidget {
  final String room;

  const DeviceListPage({super.key, required this.room});

  @override
  Widget build(BuildContext context) {
    final deviceProvider = Provider.of<DeviceProvider>(context);
    // Filter devices by room in future; for now, show all mock devices
    // deviceProvider.loadDevices();  // Load mock data - moved to provider constructor

    return Scaffold(
      appBar: AppBar(title: Text('$room Devices')),
      body: ListView.builder(
        itemCount: deviceProvider.devices.length,
        itemBuilder: (context, index) {
          final device = deviceProvider.devices[index];
          return DeviceCard(
            device: device,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DeviceDetailPage(device: device),
                ),
              );
            },
          );
        },
      ),
    );
  }
}