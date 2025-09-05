import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/device_provider.dart';
import 'device_detail_page.dart';
import '../widgets/device_card.dart';
import 'add_device_page.dart';

class AllDevicesPage extends StatelessWidget {
  const AllDevicesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final deviceProvider = Provider.of<DeviceProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Devices'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              deviceProvider.loadDevices();
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddDevicePage()),
              );
            },
          ),
        ],
      ),
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
