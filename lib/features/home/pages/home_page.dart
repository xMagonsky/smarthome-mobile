import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/device_provider.dart';
import '../../devices/widgets/device_card.dart';
import '../../devices/pages/device_detail_page.dart';
import '../../devices/pages/add_device_page.dart';
import '../widgets/stats_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning!';
    } else if (hour < 18) {
      return 'Good afternoon!';
    } else {
      return 'Good evening!';
    }
  }

  String _getFormattedDateTime() {
    final now = DateTime.now();
    final weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];

    final weekday = weekdays[now.weekday - 1];
    final day = now.day;
    final month = months[now.month - 1];
    final hour = now.hour.toString().padLeft(2, '0');
    final minute = now.minute.toString().padLeft(2, '0');

    return '$weekday, $day $month • $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final deviceProvider = Provider.of<DeviceProvider>(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final isVerySmall = screenWidth < 360; // For very small screens

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              Colors.grey.shade50,
            ],
          ),
        ),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 120,
              floating: false,
              pinned: true,
              backgroundColor: Colors.white.withValues(alpha: 0.9),
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  'Smart Home',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                centerTitle: true,
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () {
                    deviceProvider.loadDevices();
                  },
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: _buildWelcomeBanner(context),
            ),
            SliverToBoxAdapter(
              child: _buildStatsSection(
                  context, deviceProvider, isTablet, isVerySmall),
            ),
            if (deviceProvider.devices.isEmpty)
              SliverToBoxAdapter(
                child: _buildEmptyState(context),
              )
            else ...[
              SliverToBoxAdapter(
                child: _buildDevicesHeader(context, deviceProvider),
              ),
              _buildDevicesList(deviceProvider, isTablet),
            ],
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddDevicePage()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildWelcomeBanner(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16.0),
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).primaryColor.withValues(alpha: 0.15),
            Theme.of(context).primaryColor.withValues(alpha: 0.08),
            Colors.white.withValues(alpha: 0.1),
          ],
          stops: const [0.0, 0.7, 1.0],
        ),
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
            blurRadius: 12.0,
            offset: const Offset(0, 4),
            spreadRadius: 1.0,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6.0,
            offset: const Offset(0, 1),
          ),
        ],
        border: Border.all(
          color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _getGreeting(),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Welcome to Your Smart Home!',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 8),
          Text(
            _getFormattedDateTime(),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[500],
                ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(
                Icons.home,
                size: 24,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(width: 8),
              Text(
                'My Home',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).primaryColor,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(BuildContext context, DeviceProvider deviceProvider,
      bool isTablet, bool isVerySmall) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Overview',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          isTablet
              ? Row(
                  children: [
                    Expanded(
                      child: StatsCard(
                        title: 'Online Devices',
                        value: '${deviceProvider.onlineDevicesCount}',
                        icon: Icons.wifi,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StatsCard(
                        title: 'Offline Devices',
                        value: '${deviceProvider.offlineDevicesCount}',
                        icon: Icons.wifi_off,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StatsCard(
                        title: deviceProvider.allDevicesOk
                            ? 'Everything OK'
                            : 'Not all devices working',
                        value: deviceProvider.allDevicesOk ? '✓' : 'Problems',
                        icon: deviceProvider.allDevicesOk
                            ? Icons.check_circle
                            : Icons.warning,
                        color: deviceProvider.allDevicesOk
                            ? Colors.green
                            : Colors.orange,
                      ),
                    ),
                  ],
                )
              : Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: StatsCard(
                            title: 'Online',
                            value: '${deviceProvider.onlineDevicesCount}',
                            icon: Icons.wifi,
                            color: Colors.green,
                            isCompact: true,
                          ),
                        ),
                        SizedBox(width: isVerySmall ? 6 : 8),
                        Expanded(
                          child: StatsCard(
                            title: 'Offline',
                            value: '${deviceProvider.offlineDevicesCount}',
                            icon: Icons.wifi_off,
                            color: Colors.red,
                            isCompact: true,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: StatsCard(
                        title: deviceProvider.allDevicesOk
                            ? 'Everything OK'
                            : 'Not all devices working',
                        value: deviceProvider.allDevicesOk ? '✓' : 'Problems',
                        icon: deviceProvider.allDevicesOk
                            ? Icons.check_circle
                            : Icons.warning,
                        color: deviceProvider.allDevicesOk
                            ? Colors.green
                            : Colors.orange,
                        isCompact: true,
                      ),
                    ),
                  ],
                ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(40),
              ),
              child: Icon(
                Icons.devices,
                size: 40,
                color: Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'You have no devices yet',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add your first device using the + button below',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade500,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDevicesHeader(
      BuildContext context, DeviceProvider deviceProvider) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 24, 16, 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.indigo.shade50,
            Colors.blue.shade50,
            Colors.white,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.indigo.shade200.withValues(alpha: 0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.shade100.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.indigo.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.devices,
              color: Colors.indigo.shade700,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My Devices',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo.shade800,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${deviceProvider.devices.length} ${deviceProvider.devices.length == 1 ? 'device' : 'devices'}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.indigo.shade600,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDevicesList(DeviceProvider deviceProvider, bool isTablet) {
    if (isTablet) {
      return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        sliver: SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.5,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) {
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
            childCount: deviceProvider.devices.length,
          ),
        ),
      );
    } else {
      return SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
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
          childCount: deviceProvider.devices.length,
        ),
      );
    }
  }
}
