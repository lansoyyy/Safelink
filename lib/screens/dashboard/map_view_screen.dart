import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:safelink/utils/colors.dart';
import 'package:safelink/widgets/text_widget.dart';

class MapViewScreen extends StatefulWidget {
  final bool isSinglePin;
  final Map<String, dynamic>? alertData;

  const MapViewScreen({
    super.key,
    this.isSinglePin = false,
    this.alertData,
  });

  @override
  State<MapViewScreen> createState() => _MapViewScreenState();
}

class _MapViewScreenState extends State<MapViewScreen> {
  final MapController _mapController = MapController();
  Map<String, dynamic>? _selectedPin;

  // Sample multiple alert locations
  final List<Map<String, dynamic>> _alertLocations = [
    {
      'id': 1,
      'type': 'emergency',
      'location': 'Block A, Street 5',
      'coordinates': const LatLng(14.5995, 120.9842), // Manila coordinates
      'time': '2025-10-10 14:30:00',
      'status': 'resolved',
      'description': 'Vehicle accident detected',
    },
    {
      'id': 2,
      'type': 'warning',
      'location': 'Block B, Street 2',
      'coordinates': const LatLng(14.6010, 120.9850),
      'time': '2025-10-10 09:15:00',
      'status': 'resolved',
      'description': 'Potential incident detected',
    },
    {
      'id': 3,
      'type': 'emergency',
      'location': 'Block C, Street 8',
      'coordinates': const LatLng(14.5980, 120.9860),
      'time': '2025-10-09 18:45:00',
      'status': 'resolved',
      'description': 'Emergency situation reported',
    },
    {
      'id': 4,
      'type': 'warning',
      'location': 'Block D, Street 3',
      'coordinates': const LatLng(14.6005, 120.9835),
      'time': '2025-10-09 12:20:00',
      'status': 'resolved',
      'description': 'Minor incident detected',
    },
  ];

  @override
  Widget build(BuildContext context) {
    // Use single alert data if provided, otherwise use sample data
    final singleAlert = widget.alertData ??
        {
          'type': 'emergency',
          'location': 'Block A, Street 5, Alsea Homes',
          'coordinates': const LatLng(14.5995, 120.9842),
          'time': DateTime.now().toString().substring(0, 19),
          'description': 'Emergency alert detected',
        };

    return Scaffold(
      backgroundColor: primaryLight,
      appBar: AppBar(
        backgroundColor: primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: TextWidget(
          text: widget.isSinglePin ? 'Alert Location' : 'All Alert Locations',
          fontSize: 20,
          fontFamily: 'Bold',
          color: Colors.white,
        ),
        actions: [
          if (!widget.isSinglePin)
            IconButton(
              icon: const Icon(Icons.my_location, color: Colors.white),
              onPressed: () {
                _mapController.move(const LatLng(14.5995, 120.9842), 14.0);
              },
              tooltip: 'Center Map',
            ),
        ],
      ),
      body: Stack(
        children: [
          // Map
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: widget.isSinglePin
                  ? singleAlert['coordinates']
                  : const LatLng(14.5995, 120.9842),
              initialZoom: widget.isSinglePin ? 16.0 : 14.0,
              onTap: (_, __) {
                if (!widget.isSinglePin) {
                  setState(() {
                    _selectedPin = null;
                  });
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.safelink.app',
              ),
              MarkerLayer(
                markers: widget.isSinglePin
                    ? [_buildSingleMarker(singleAlert)]
                    : _buildMultipleMarkers(),
              ),
            ],
          ),

          // Single Pin Info Card (always visible for single pin)
          if (widget.isSinglePin)
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: _buildAlertInfoCard(singleAlert),
            ),

          // Multiple Pins Info Card (visible when pin is selected)
          if (!widget.isSinglePin && _selectedPin != null)
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: _buildAlertInfoCard(_selectedPin!),
            ),

          // Legend for multiple pins
          if (!widget.isSinglePin)
            Positioned(
              top: 20,
              right: 20,
              child: _buildLegend(),
            ),
        ],
      ),
    );
  }

  Marker _buildSingleMarker(Map<String, dynamic> alert) {
    final isEmergency = alert['type'] == 'emergency';
    return Marker(
      point: alert['coordinates'],
      width: 50,
      height: 50,
      child: GestureDetector(
        onTap: () {
          // Already showing info card for single pin
        },
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isEmergency ? Colors.red : Colors.orange,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(
                isEmergency ? Icons.emergency : Icons.warning_amber,
                color: Colors.white,
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Marker> _buildMultipleMarkers() {
    return _alertLocations.map((alert) {
      final isEmergency = alert['type'] == 'emergency';
      final isSelected = _selectedPin?['id'] == alert['id'];

      return Marker(
        point: alert['coordinates'],
        width: isSelected ? 60 : 50,
        height: isSelected ? 60 : 50,
        child: GestureDetector(
          onTap: () {
            setState(() {
              _selectedPin = alert;
            });
            _mapController.move(alert['coordinates'], 16.0);
          },
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(isSelected ? 10 : 8),
                decoration: BoxDecoration(
                  color: isEmergency ? Colors.red : Colors.orange,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? Colors.yellow : Colors.white,
                    width: isSelected ? 4 : 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(
                  isEmergency ? Icons.emergency : Icons.warning_amber,
                  color: Colors.white,
                  size: isSelected ? 28 : 24,
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  Widget _buildAlertInfoCard(Map<String, dynamic> alert) {
    final isEmergency = alert['type'] == 'emergency';
    final color = isEmergency ? Colors.red : Colors.orange;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isEmergency ? Icons.emergency : Icons.warning_amber,
                  color: color,
                  size: 28,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextWidget(
                      text: isEmergency ? 'Emergency Alert' : 'Warning Alert',
                      fontSize: 18,
                      fontFamily: 'Bold',
                      color: color,
                    ),
                    const SizedBox(height: 3),
                    TextWidget(
                      text: alert['location'],
                      fontSize: 14,
                      fontFamily: 'Regular',
                      color: Colors.grey[700],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          const Divider(),
          const SizedBox(height: 10),
          _buildInfoRow(Icons.access_time, 'Time', alert['time']),
          const SizedBox(height: 8),
          if (alert['description'] != null)
            _buildInfoRow(Icons.info_outline, 'Details', alert['description']),
          if (alert['status'] != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.check_circle, size: 18, color: Colors.green),
                const SizedBox(width: 8),
                TextWidget(
                  text: 'Status: ',
                  fontSize: 14,
                  fontFamily: 'Bold',
                  color: Colors.grey[700],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextWidget(
                    text: alert['status'].toUpperCase(),
                    fontSize: 12,
                    fontFamily: 'Bold',
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 15),
          Row(
            children: [
              if (!widget.isSinglePin) ...[
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _selectedPin = null;
                      });
                    },
                    label: const Text('Close'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        const SizedBox(width: 8),
        TextWidget(
          text: '$label: ',
          fontSize: 14,
          fontFamily: 'Bold',
          color: Colors.grey[700],
        ),
        Expanded(
          child: TextWidget(
            text: value,
            fontSize: 14,
            fontFamily: 'Regular',
            color: Colors.grey[600],
            maxLines: 5,
          ),
        ),
      ],
    );
  }

  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextWidget(
            text: 'Legend',
            fontSize: 12,
            fontFamily: 'Bold',
            color: Colors.black,
          ),
          const SizedBox(height: 8),
          _buildLegendItem(Colors.red, 'Emergency'),
          const SizedBox(height: 5),
          _buildLegendItem(Colors.orange, 'Warning'),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        TextWidget(
          text: label,
          fontSize: 11,
          fontFamily: 'Regular',
          color: Colors.grey[700],
        ),
      ],
    );
  }
}
