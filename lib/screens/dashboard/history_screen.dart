import 'package:flutter/material.dart';
import 'package:safelink/utils/colors.dart';
import 'package:safelink/widgets/text_widget.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  // Sample alert history data
  final List<Map<String, dynamic>> _alertHistory = [
    {
      'type': 'emergency',
      'time': '2025-10-09 14:30:00',
      'location': 'Block A, Street 5',
      'status': 'resolved',
      'hasImage': true,
    },
    {
      'type': 'warning',
      'time': '2025-10-08 09:15:00',
      'location': 'Block B, Street 2',
      'status': 'resolved',
      'hasImage': false,
    },
    {
      'type': 'emergency',
      'time': '2025-10-07 18:45:00',
      'location': 'Block C, Street 8',
      'status': 'resolved',
      'hasImage': true,
    },
  ];

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
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onPressed: () {
              // TODO: Implement filter functionality
            },
          ),
        ],
      ),
      body: _alertHistory.isEmpty
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

  Widget _buildAlertCard(Map<String, dynamic> alert) {
    final isEmergency = alert['type'] == 'emergency';
    final color = isEmergency ? Colors.red : Colors.orange;

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
                      text: alert['time'],
                      fontSize: 12,
                      fontFamily: 'Regular',
                      color: Colors.grey[600],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextWidget(
                  text: alert['status'].toUpperCase(),
                  fontSize: 11,
                  fontFamily: 'Bold',
                  color: Colors.green,
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
                  text: alert['location'],
                  fontSize: 14,
                  fontFamily: 'Regular',
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
          if (alert['hasImage']) ...[
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
                  // TODO: View details
                },
                icon: const Icon(Icons.visibility, size: 18),
                label: const Text('View Details'),
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
