import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:safelink/models/alert_model.dart';
import 'package:safelink/services/alert_service.dart';
import 'package:safelink/utils/colors.dart';
import 'package:safelink/widgets/text_widget.dart';

class MapViewScreen extends StatefulWidget {
  final AlertModel? singleAlert;

  const MapViewScreen({
    super.key,
    this.singleAlert,
  });

  @override
  State<MapViewScreen> createState() => _MapViewScreenState();
}

class _MapViewScreenState extends State<MapViewScreen> {
  final MapController _mapController = MapController();
  final AlertService _alertService = AlertService();
  String? _selectedPin; // Alert ID
  List<AlertModel> _alerts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAlerts();
  }

  Future<void> _loadAlerts() async {
    if (widget.singleAlert != null) {
      // Single alert mode
      setState(() {
        _alerts = [widget.singleAlert!];
        _isLoading = false;
      });
    } else {
      // Load all alerts from Firebase
      _alertService.getAllAlertsStream().listen((alerts) {
        if (mounted) {
          setState(() {
            _alerts = alerts;
            _isLoading = false;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
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
            text: 'Alert Locations',
            fontSize: 20,
            fontFamily: 'Bold',
            color: Colors.white,
          ),
        ),
        body: const Center(
          child: CircularProgressIndicator(color: primary),
        ),
      );
    }

    if (_alerts.isEmpty) {
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
            text: 'Alert Locations',
            fontSize: 20,
            fontFamily: 'Bold',
            color: Colors.white,
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.location_off, size: 80, color: Colors.grey[400]),
              const SizedBox(height: 20),
              TextWidget(
                text: 'No alerts available',
                fontSize: 18,
                fontFamily: 'Medium',
                color: Colors.grey[600],
              ),
            ],
          ),
        ),
      );
    }

    final isSingleAlert = widget.singleAlert != null;
    final displayAlerts = isSingleAlert ? [widget.singleAlert!] : _alerts;
    final centerLat = displayAlerts.first.latitude;
    final centerLng = displayAlerts.first.longitude;

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
          text: isSingleAlert ? 'Alert Location' : 'All Alert Locations',
          fontSize: 20,
          fontFamily: 'Bold',
          color: Colors.white,
        ),
        actions: [
          if (!isSingleAlert)
            IconButton(
              icon: const Icon(Icons.my_location, color: Colors.white),
              onPressed: () {
                _mapController.move(LatLng(centerLat, centerLng), 14.0);
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
              initialCenter: LatLng(centerLat, centerLng),
              initialZoom: isSingleAlert ? 16.0 : 14.0,
              onTap: (_, __) {
                if (!isSingleAlert) {
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
                markers: displayAlerts.map((alert) => _buildMarker(alert)).toList(),
              ),
            ],
          ),

          // Single Alert Info Card
          if (isSingleAlert)
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: _buildAlertInfoCard(widget.singleAlert!),
            ),

          // Multiple Alerts Info Card (when pin selected)
          if (!isSingleAlert && _selectedPin != null)
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: _buildSelectedPinCard(),
            ),

          // Legend for multiple alerts
          if (!isSingleAlert)
            Positioned(
              top: 20,
              right: 20,
              child: _buildLegend(),
            ),
        ],
      ),
    );
  }

  Marker _buildMarker(AlertModel alert) {
    final isEmergency = alert.alertType.toLowerCase() == 'emergency';
    final isSelected = _selectedPin == alert.id;
    final isSingleAlert = widget.singleAlert != null;

    return Marker(
      point: LatLng(alert.latitude, alert.longitude),
      width: isSelected ? 60 : 50,
      height: isSelected ? 60 : 50,
      child: GestureDetector(
        onTap: () {
          if (!isSingleAlert) {
            setState(() {
              _selectedPin = alert.id;
            });
            _mapController.move(LatLng(alert.latitude, alert.longitude), 16.0);
          }
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
  }

  Widget _buildSelectedPinCard() {
    final selectedAlert = _alerts.firstWhere((alert) => alert.id == _selectedPin);
    return _buildAlertInfoCard(selectedAlert);
  }

  Widget _buildAlertInfoCard(AlertModel alert) {
    final isEmergency = alert.alertType.toLowerCase() == 'emergency';
    final color = isEmergency ? Colors.red : Colors.orange;
    final statusColor = alert.isActive ? Colors.green : Colors.grey;
    final statusText = alert.isActive ? 'Active' : 'Resolved';

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
                      text: alert.location,
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
          _buildInfoRow(Icons.access_time, 'Time', _formatDateTime(alert.dateTime)),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.info_outline, 'Details', alert.details),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                alert.isActive ? Icons.warning : Icons.check_circle,
                size: 18,
                color: statusColor,
              ),
              const SizedBox(width: 8),
              TextWidget(
                text: 'Status: ',
                fontSize: 14,
                fontFamily: 'Bold',
                color: Colors.grey[700],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextWidget(
                  text: statusText.toUpperCase(),
                  fontSize: 12,
                  fontFamily: 'Bold',
                  color: statusColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          if (widget.singleAlert == null)
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _selectedPin = null;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
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
