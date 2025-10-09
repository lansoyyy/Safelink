import 'package:flutter/material.dart';
import 'package:safelink/utils/colors.dart';
import 'package:safelink/widgets/text_widget.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  // Sample notifications data
  final List<Map<String, dynamic>> _notifications = [
    {
      'title': 'System Status Update',
      'message': 'All systems are operational',
      'time': '2 hours ago',
      'type': 'info',
      'isRead': false,
    },
    {
      'title': 'Emergency Alert Resolved',
      'message': 'Emergency at Block A has been resolved',
      'time': '1 day ago',
      'type': 'success',
      'isRead': true,
    },
    {
      'title': 'Warning Alert',
      'message': 'Potential incident detected at Block B',
      'time': '2 days ago',
      'type': 'warning',
      'isRead': true,
    },
  ];

  void _markAllAsRead() {
    setState(() {
      for (var notification in _notifications) {
        notification['isRead'] = true;
      }
    });
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
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all, color: Colors.white),
            onPressed: _markAllAsRead,
            tooltip: 'Mark all as read',
          ),
        ],
      ),
      body: _notifications.isEmpty
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

  Widget _buildNotificationCard(Map<String, dynamic> notification, int index) {
    IconData icon;
    Color iconColor;

    switch (notification['type']) {
      case 'info':
        icon = Icons.info_outline;
        iconColor = Colors.blue;
        break;
      case 'success':
        icon = Icons.check_circle_outline;
        iconColor = Colors.green;
        break;
      case 'warning':
        icon = Icons.warning_amber;
        iconColor = Colors.orange;
        break;
      default:
        icon = Icons.notifications;
        iconColor = Colors.grey;
    }

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
          color: notification['isRead'] ? Colors.white : primaryLight,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: notification['isRead']
                ? Colors.grey.withOpacity(0.2)
                : primary.withOpacity(0.3),
            width: notification['isRead'] ? 1 : 2,
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
                          text: notification['title'],
                          fontSize: 16,
                          fontFamily: 'Bold',
                          color: Colors.black,
                        ),
                      ),
                      if (!notification['isRead'])
                        Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  TextWidget(
                    text: notification['message'],
                    fontSize: 14,
                    fontFamily: 'Regular',
                    color: Colors.grey[700],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 14, color: Colors.grey[500]),
                      const SizedBox(width: 5),
                      TextWidget(
                        text: notification['time'],
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
