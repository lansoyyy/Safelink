import 'package:flutter/material.dart';
import 'package:safelink/models/alert_model.dart';
import 'package:safelink/services/alert_service.dart';
import 'package:safelink/utils/colors.dart';
import 'package:safelink/widgets/text_widget.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final AlertService _alertService = AlertService();
  List<AlertModel> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  void _loadNotifications() {
    _alertService.getAllAlertsStream().listen((alerts) {
      if (mounted) {
        setState(() {
          _notifications = alerts;
          _isLoading = false;
        });
      }
    });
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${dateTime.month}/${dateTime.day}/${dateTime.year}';
    }
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
          text: 'Notifications',
          fontSize: 20,
          fontFamily: 'Bold',
          color: Colors.white,
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: primary),
            )
          : _notifications.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: _notifications.length,
                  itemBuilder: (context, index) {
                    return _buildNotificationCard(_notifications[index], index);
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
            Icons.notifications_none,
            size: 100,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 20),
          TextWidget(
            text: 'No Notifications',
            fontSize: 20,
            fontFamily: 'Bold',
            color: Colors.grey[600],
          ),
          const SizedBox(height: 10),
          TextWidget(
            text: 'You\'re all caught up!',
            fontSize: 14,
            fontFamily: 'Regular',
            color: Colors.grey[500],
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(AlertModel alert, int index) {
    final isEmergency = alert.alertType.toLowerCase() == 'emergency';
    final icon = isEmergency ? Icons.emergency : Icons.warning_amber;
    final iconColor = isEmergency ? Colors.red : Colors.orange;
    final title = isEmergency ? 'Emergency Alert' : 'Warning Alert';
    final statusIcon = alert.isActive ? Icons.warning : Icons.check_circle_outline;
    final statusColor = alert.isActive ? Colors.orange : Colors.green;
    final statusText = alert.isActive ? 'Active' : 'Resolved';

    return Dismissible(
      key: Key('notification_$index'),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(15),
        ),
        alignment: Alignment.centerRight,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) {
        setState(() {
          _notifications.removeAt(index);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notification deleted')),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: alert.isActive ? primaryLight : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: alert.isActive
                ? primary.withOpacity(0.3)
                : Colors.grey.withOpacity(0.2),
            width: alert.isActive ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 25),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextWidget(
                          text: title,
                          fontSize: 16,
                          fontFamily: 'Bold',
                          color: Colors.black,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(statusIcon, size: 12, color: statusColor),
                            const SizedBox(width: 4),
                            TextWidget(
                              text: statusText,
                              fontSize: 10,
                              fontFamily: 'Bold',
                              color: statusColor,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  TextWidget(
                    text: alert.details,
                    fontSize: 14,
                    fontFamily: 'Regular',
                    color: Colors.grey[700],
                    maxLines: 2,
                  ),
                  const SizedBox(height: 5),
                  TextWidget(
                    text: alert.location,
                    fontSize: 13,
                    fontFamily: 'Medium',
                    color: Colors.grey[600],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.access_time,
                          size: 14, color: Colors.grey[500]),
                      const SizedBox(width: 5),
                      TextWidget(
                        text: _formatDateTime(alert.dateTime),
                        fontSize: 12,
                        fontFamily: 'Regular',
                        color: Colors.grey[500],
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
}
