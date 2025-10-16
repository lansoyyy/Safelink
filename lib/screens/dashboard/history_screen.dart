import 'package:flutter/material.dart';
import 'package:safelink/models/alert_model.dart';
import 'package:safelink/services/alert_service.dart';
import 'package:safelink/utils/colors.dart';
import 'package:safelink/widgets/text_widget.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final AlertService _alertService = AlertService();
  List<AlertModel> _alertHistory = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAlertHistory();
  }

  void _loadAlertHistory() {
    _alertService.getAllAlertsStream().listen((alerts) {
      if (mounted) {
        setState(() {
          _alertHistory = alerts;
          _isLoading = false;
        });
      }
    });
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _showImageDialog(AlertModel alert) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Close button
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),
            const SizedBox(height: 10),
            // Image container
            Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.7,
                maxWidth: MediaQuery.of(context).size.width * 0.9,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: alert.imageUrl.isNotEmpty
                    ? Image.network(
                        alert.imageUrl,
                        fit: BoxFit.contain,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(50),
                              child: CircularProgressIndicator(
                                color: primary,
                                value: loadingProgress.expectedTotalBytes !=
                                        null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            padding: const EdgeInsets.all(50),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.broken_image,
                                  size: 80,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 20),
                                TextWidget(
                                  text: 'Failed to load image',
                                  fontSize: 16,
                                  fontFamily: 'Medium',
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(height: 10),
                                TextWidget(
                                  text: 'Please check your internet connection',
                                  fontSize: 12,
                                  fontFamily: 'Regular',
                                  color: Colors.grey[500],
                                ),
                              ],
                            ),
                          );
                        },
                      )
                    : Container(
                        padding: const EdgeInsets.all(50),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.image_not_supported,
                              size: 80,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 20),
                            TextWidget(
                              text: 'No image available',
                              fontSize: 16,
                              fontFamily: 'Medium',
                              color: Colors.grey[600],
                            ),
                          ],
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 20),
            // Alert info
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        alert.alertType.toLowerCase() == 'emergency'
                            ? Icons.emergency
                            : Icons.warning_amber,
                        color: alert.alertType.toLowerCase() == 'emergency'
                            ? Colors.red
                            : Colors.orange,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextWidget(
                          text: alert.alertType.toLowerCase() == 'emergency'
                              ? 'Emergency Alert'
                              : 'Warning Alert',
                          fontSize: 16,
                          fontFamily: 'Bold',
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.location_on,
                          size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 5),
                      Expanded(
                        child: TextWidget(
                          text: alert.location,
                          fontSize: 13,
                          fontFamily: 'Regular',
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Icon(Icons.access_time,
                          size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 5),
                      TextWidget(
                        text: _formatDateTime(alert.dateTime),
                        fontSize: 12,
                        fontFamily: 'Regular',
                        color: Colors.grey[600],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
          text: 'Alert History',
          fontSize: 20,
          fontFamily: 'Bold',
          color: Colors.white,
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: primary),
            )
          : _alertHistory.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: _alertHistory.length,
                  itemBuilder: (context, index) {
                    return _buildAlertCard(_alertHistory[index]);
                  },
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 100,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 20),
          TextWidget(
            text: 'No Alert History',
            fontSize: 20,
            fontFamily: 'Bold',
            color: Colors.grey[600],
          ),
          const SizedBox(height: 10),
          TextWidget(
            text: 'Past alerts will appear here',
            fontSize: 14,
            fontFamily: 'Regular',
            color: Colors.grey[500],
          ),
        ],
      ),
    );
  }

  Widget _buildAlertCard(AlertModel alert) {
    final isEmergency = alert.alertType.toLowerCase() == 'emergency';
    final color = isEmergency ? Colors.red : Colors.orange;
    final statusColor = alert.isActive ? Colors.orange : Colors.green;
    final statusText = alert.isActive ? 'Active' : 'Resolved';

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
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
                  size: 25,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextWidget(
                      text: isEmergency ? 'Emergency Alert' : 'Warning Alert',
                      fontSize: 16,
                      fontFamily: 'Bold',
                      color: color,
                    ),
                    const SizedBox(height: 3),
                    TextWidget(
                      text: _formatDateTime(alert.dateTime),
                      fontSize: 12,
                      fontFamily: 'Regular',
                      color: Colors.grey[600],
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextWidget(
                  text: statusText.toUpperCase(),
                  fontSize: 11,
                  fontFamily: 'Bold',
                  color: statusColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Icon(Icons.location_on, size: 18, color: Colors.grey[600]),
              const SizedBox(width: 5),
              Expanded(
                child: TextWidget(
                  text: alert.location,
                  fontSize: 13,
                  fontFamily: 'Regular',
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline, size: 18, color: Colors.grey[600]),
              const SizedBox(width: 5),
              Expanded(
                child: TextWidget(
                  text: alert.details,
                  fontSize: 13,
                  fontFamily: 'Regular',
                  color: Colors.grey[700],
                  maxLines: 2,
                ),
              ),
            ],
          ),
          if (alert.imageUrl.isNotEmpty) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.image, size: 18, color: Colors.grey[600]),
                const SizedBox(width: 5),
                TextWidget(
                  text: 'Image attached',
                  fontSize: 14,
                  fontFamily: 'Regular',
                  color: Colors.grey[700],
                ),
              ],
            ),
          ],
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () {
                  _showImageDialog(alert);
                },
                icon: const Icon(Icons.visibility, size: 18),
                label: const Text('View Image'),
                style: TextButton.styleFrom(
                  foregroundColor: primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
