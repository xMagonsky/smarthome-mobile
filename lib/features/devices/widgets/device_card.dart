import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/device.dart';
import '../../../core/providers/device_provider.dart';
import '../../../core/utils/device_icons.dart';

class DeviceCard extends StatefulWidget {
  final Device device;
  final VoidCallback onTap;

  const DeviceCard({super.key, required this.device, required this.onTap});

  @override
  State<DeviceCard> createState() => _DeviceCardState();
}

class _DeviceCardState extends State<DeviceCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final deviceProvider = Provider.of<DeviceProvider>(context, listen: false);
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    
    return GestureDetector(
      onTapDown: (_) => _animationController.forward(),
      onTapUp: (_) => _animationController.reverse(),
      onTapCancel: () => _animationController.reverse(),
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              margin: EdgeInsets.symmetric(
                horizontal: isTablet ? 8 : 16,
                vertical: 6,
              ),
              child: Card(
                elevation: widget.device.isOnline ? 2 : 1,
                color: widget.device.isOnline ? null : Colors.grey.shade100,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: widget.device.isOnline
                        ? LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white,
                              Colors.grey.shade50,
                            ],
                          )
                        : null,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: _buildCardContent(context, deviceProvider, isTablet),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCardContent(BuildContext context, DeviceProvider deviceProvider, bool isTablet) {
    if (widget.device.type == 'sensor') {
      return _buildSensorCard(deviceProvider, isTablet);
    } else {
      return _buildDeviceCard(deviceProvider, isTablet);
    }
  }

  Widget _buildSensorCard(DeviceProvider deviceProvider, bool isTablet) {
    return Row(
      children: [
        _buildDeviceIcon(),
        SizedBox(width: isTablet ? 20 : 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.device.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: widget.device.isOnline ? null : Colors.grey,
                      ),
                    ),
                  ),
                  _buildFavoriteButton(deviceProvider),
                ],
              ),
              const SizedBox(height: 8),
              if (widget.device.state.isNotEmpty) _buildSensorValues(),
              if (!widget.device.isOnline) _buildOfflineIndicator(),
            ],
          ),
        ),
        Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: widget.device.isOnline ? Colors.grey : Colors.grey.shade400,
        ),
      ],
    );
  }

  Widget _buildDeviceCard(DeviceProvider deviceProvider, bool isTablet) {
    return Row(
      children: [
        _buildDeviceIcon(),
        SizedBox(width: isTablet ? 20 : 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.device.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: widget.device.isOnline ? null : Colors.grey,
                      ),
                    ),
                  ),
                  _buildFavoriteButton(deviceProvider),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    widget.device.isOn ? 'Włączone' : 'Wyłączone',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: widget.device.isOnline
                          ? (widget.device.isOn ? Colors.green : Colors.grey.shade600)
                          : Colors.grey.shade400,
                    ),
                  ),
                  if (!widget.device.isOnline) ...[
                    const SizedBox(width: 8),
                    Text(
                      '• Offline',
                      style: TextStyle(
                        color: Colors.red.shade400,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
        Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: widget.device.isOnline ? Colors.grey : Colors.grey.shade400,
        ),
      ],
    );
  }

  Widget _buildDeviceIcon() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: DeviceIcons.getColorForDeviceType(
          widget.device.type,
          isOn: widget.device.isOn,
          isOnline: widget.device.isOnline,
        ).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: DeviceIcons.getColorForDeviceType(
            widget.device.type,
            isOn: widget.device.isOn,
            isOnline: widget.device.isOnline,
          ).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Stack(
        children: [
          Center(
            child: Icon(
              DeviceIcons.getIconForDeviceType(widget.device.type),
              size: 24,
              color: DeviceIcons.getColorForDeviceType(
                widget.device.type,
                isOn: widget.device.isOn,
                isOnline: widget.device.isOnline,
              ),
            ),
          ),
          if (!widget.device.isOnline)
            Positioned(
              right: 2,
              top: 2,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFavoriteButton(DeviceProvider deviceProvider) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => deviceProvider.toggleFavorite(widget.device.id),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Icon(
            widget.device.isFavorite ? Icons.star : Icons.star_border,
            color: widget.device.isFavorite ? Colors.amber : Colors.grey,
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildSensorValues() {
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: widget.device.state.entries.map((entry) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.shade100),
          ),
          child: Text(
            '${entry.key}: ${entry.value}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.blue.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildOfflineIndicator() {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade100),
      ),
      child: Text(
        'Urządzenie offline',
        style: TextStyle(
          fontSize: 11,
          color: Colors.red.shade600,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}