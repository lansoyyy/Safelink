import 'dart:async';
import 'package:flutter/material.dart';
import 'package:safelink/models/alert_model.dart';
import 'package:safelink/screens/auth/login_screen.dart';
import 'package:safelink/screens/dashboard/about_screen.dart';
import 'package:safelink/screens/dashboard/emergency_contacts_screen.dart';
import 'package:safelink/screens/dashboard/history_screen.dart';
import 'package:safelink/screens/dashboard/map_view_screen.dart';
import 'package:safelink/screens/dashboard/notifications_screen.dart';
import 'package:safelink/screens/dashboard/settings_screen.dart';
import 'package:safelink/services/alert_service.dart';
import 'package:safelink/utils/colors.dart';
import 'package:safelink/widgets/text_widget.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final AlertService _alertService = AlertService();
  StreamSubscription<List<AlertModel>>? _alertSubscription;

  AlertModel? _currentAlert;
  bool _hasIncomingAlert = false;
  String _alertType = 'none'; // 'emergency', 'warning', 'none'
  String _lastAlertTime = 'No alerts yet';
  String _lastAlertLocation = 'N/A';
  String? _currentAlertId;

  @override
  void initState() {
    super.initState();
    _listenToAlerts();
  }

  @override
  void dispose() {
    _alertSubscription?.cancel();
    super.dispose();
  }

  // Listen to Firebase Realtime Database for active alerts
  void _listenToAlerts() {
    _alertSubscription = _alertService.getActiveAlertsStream().listen((alerts) {
      if (alerts.isNotEmpty) {
        // Get the most recent active alert
        final latestAlert = alerts.first;

        setState(() {
          _currentAlert = latestAlert;
          _currentAlertId = latestAlert.id;
          _hasIncomingAlert = true;
          _alertType = latestAlert.alertType.toLowerCase();
          _lastAlertTime = _formatDateTime(latestAlert.dateTime);
          _lastAlertLocation = latestAlert.location;
        });
      } else {
        setState(() {
          _currentAlert = null;
          _currentAlertId = null;
          _hasIncomingAlert = false;
          _alertType = 'none';
          _lastAlertTime = 'No alerts yet';
          _lastAlertLocation = 'N/A';
        });
      }
    });
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}';
  }

  void _navigateToHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const HistoryScreen()),
    );
  }

  void _navigateToNotifications() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NotificationsScreen()),
    );
  }

  void _navigateToSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsScreen()),
    );
  }

  void _navigateToEmergencyContacts() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const EmergencyContactsScreen()),
    );
  }

  void _navigateToAbout() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AboutScreen()),
    );
  }

  void _navigateToMapView() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapViewScreen(
          singleAlert: _currentAlert,
        ),
      ),
    );
  }

  void _acknowledgeAlert() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.warning_amber_rounded,
                color: Colors.orange,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Clear Alert',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to clear this alert?',
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _alertType == 'emergency'
                            ? Icons.emergency
                            : Icons.warning,
                        size: 16,
                        color: _alertType == 'emergency'
                            ? Colors.red
                            : Colors.orange,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _alertType == 'emergency'
                            ? 'Emergency Alert'
                            : 'Warning Alert',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _lastAlertLocation,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _lastAlertTime,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'This action will mark the alert as resolved.',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_currentAlertId != null) {
                // Clear alert in Firebase
                await _alertService.clearAlert(_currentAlertId!);
              }
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Alert acknowledged and cleared'),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 2),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Clear Alert',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: Row(
          children: [
            const Icon(Icons.logout, color: Colors.red, size: 28),
            const SizedBox(width: 10),
            TextWidget(
              text: 'Logout',
              fontSize: 20,
              fontFamily: 'Bold',
              color: Colors.black,
            ),
          ],
        ),
        content: TextWidget(
          text: 'Are you sure you want to logout from SafeLink?',
          fontSize: 14,
          fontFamily: 'Regular',
          color: Colors.grey[700],
          maxLines: 5,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: TextWidget(
              text: 'Cancel',
              fontSize: 14,
              fontFamily: 'Medium',
              color: Colors.grey[600],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // Close dialog
              Navigator.pop(context);
              // Close drawer
              Navigator.pop(context);
              // Navigate to login screen and remove all previous routes
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: TextWidget(
              text: 'Logout',
              fontSize: 14,
              fontFamily: 'Bold',
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryLight,
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: primary,
        elevation: 0,
        title: TextWidget(
          text: 'SafeLink Dashboard',
          fontSize: 20,
          fontFamily: 'Bold',
          color: Colors.white,
        ),
        actions: [
          // Notifications Bell
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined,
                    color: Colors.white),
                onPressed: _navigateToNotifications,
              ),
              if (_hasIncomingAlert)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.yellow,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      drawer: _buildDrawer(),
      // floatingActionButton: FloatingActionButton.extended(
      //   onPressed: () async {
      //     // Add sample alerts to Firebase
      //     await _alertService.addSampleAlerts();
      //     if (mounted) {
      //       ScaffoldMessenger.of(context).showSnackBar(
      //         const SnackBar(
      //           content: Text('Sample alerts added to Firebase!'),
      //           backgroundColor: Colors.green,
      //           duration: Duration(seconds: 2),
      //         ),
      //       );
      //     }
      //   },
      //   backgroundColor: primary,
      //   icon: const Icon(Icons.add_alert),
      //   label: const Text('Add Sample Data'),
      // ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Refresh is handled automatically by the stream
          await Future.delayed(const Duration(seconds: 1));
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Section
                _buildWelcomeSection(),
                const SizedBox(height: 20),

                // Alert Status Card
                _buildAlertStatusCard(),
                const SizedBox(height: 20),

                // Quick Actions Grid
                TextWidget(
                  text: 'Quick Actions',
                  fontSize: 18,
                  fontFamily: 'Bold',
                  color: Colors.black,
                ),
                const SizedBox(height: 15),
                _buildQuickActionsGrid(),
                const SizedBox(height: 20),

                // Last Alert Information
                _buildLastAlertCard(),
                const SizedBox(height: 20),

                // System Status
                // _buildSystemStatusCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Container(
        color: Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: primary,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Image.asset(
                    'assets/images/icon.png',
                    width: 60,
                    height: 60,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 10),
                  TextWidget(
                    text: 'SafeLink',
                    fontSize: 24,
                    fontFamily: 'Bold',
                    color: Colors.white,
                  ),
                  TextWidget(
                    text: 'Accident Detection System',
                    fontSize: 12,
                    fontFamily: 'Regular',
                    color: Colors.white70,
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard, color: primary),
              title: TextWidget(
                text: 'Dashboard',
                fontSize: 16,
                fontFamily: 'Medium',
              ),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.history, color: primary),
              title: TextWidget(
                text: 'History',
                fontSize: 16,
                fontFamily: 'Medium',
              ),
              onTap: () {
                Navigator.pop(context);
                _navigateToHistory();
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications, color: primary),
              title: TextWidget(
                text: 'Notifications',
                fontSize: 16,
                fontFamily: 'Medium',
              ),
              onTap: () {
                Navigator.pop(context);
                _navigateToNotifications();
              },
            ),
            ListTile(
              leading: const Icon(Icons.contact_phone, color: primary),
              title: TextWidget(
                text: 'Emergency Contacts',
                fontSize: 16,
                fontFamily: 'Medium',
              ),
              onTap: () {
                Navigator.pop(context);
                _navigateToEmergencyContacts();
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings, color: primary),
              title: TextWidget(
                text: 'Settings',
                fontSize: 16,
                fontFamily: 'Medium',
              ),
              onTap: () {
                Navigator.pop(context);
                _navigateToSettings();
              },
            ),
            ListTile(
              leading: const Icon(Icons.help_outline, color: primary),
              title: TextWidget(
                text: 'About / Help',
                fontSize: 16,
                fontFamily: 'Medium',
              ),
              onTap: () {
                Navigator.pop(context);
                _navigateToAbout();
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: TextWidget(
                text: 'Logout',
                fontSize: 16,
                fontFamily: 'Medium',
                color: Colors.red,
              ),
              onTap: _showLogoutDialog,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [primary, Color(0xFFFF1744)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: primary.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextWidget(
                  text: 'Welcome Back!',
                  fontSize: 22,
                  fontFamily: 'Bold',
                  color: Colors.white,
                ),
                const SizedBox(height: 5),
                TextWidget(
                  text: 'Monitoring the Community',
                  fontSize: 14,
                  fontFamily: 'Regular',
                  color: Colors.white70,
                ),
              ],
            ),
          ),
          const Icon(
            Icons.security,
            size: 50,
            color: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildAlertStatusCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _hasIncomingAlert
            ? (_alertType == 'emergency' ? Colors.red[50] : Colors.orange[50])
            : Colors.green[50],
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: _hasIncomingAlert
              ? (_alertType == 'emergency' ? Colors.red : Colors.orange)
              : Colors.green,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                _hasIncomingAlert
                    ? Icons.warning_amber_rounded
                    : Icons.check_circle,
                color: _hasIncomingAlert
                    ? (_alertType == 'emergency' ? Colors.red : Colors.orange)
                    : Colors.green,
                size: 40,
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextWidget(
                      text: _hasIncomingAlert
                          ? (_alertType == 'emergency'
                              ? 'EMERGENCY ALERT!'
                              : 'Warning Alert')
                          : 'All Clear',
                      fontSize: 20,
                      fontFamily: 'Bold',
                      color: _hasIncomingAlert
                          ? (_alertType == 'emergency'
                              ? Colors.red
                              : Colors.orange)
                          : Colors.green,
                    ),
                    TextWidget(
                      text: _hasIncomingAlert
                          ? 'Immediate attention required'
                          : 'No active alerts',
                      fontSize: 14,
                      fontFamily: 'Regular',
                      color: Colors.grey[700],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (_hasIncomingAlert) ...[
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _navigateToMapView,
                    icon: const Icon(
                      Icons.map,
                      color: Colors.white,
                    ),
                    label: const Text(
                      'View Location',
                      style: TextStyle(fontSize: 12),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _acknowledgeAlert,
                    icon: const Icon(
                      Icons.check,
                      color: Colors.white,
                    ),
                    label: const Text(
                      'Clear Alert',
                      style: TextStyle(fontSize: 12),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickActionsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 15,
      crossAxisSpacing: 15,
      children: [
        _buildQuickActionCard(
          icon: Icons.history,
          title: 'History',
          subtitle: 'View past alerts',
          color: Colors.blue,
          onTap: _navigateToHistory,
        ),
        _buildQuickActionCard(
          icon: Icons.notifications_active,
          title: 'Notifications',
          subtitle: 'System alerts',
          color: Colors.orange,
          onTap: _navigateToNotifications,
        ),
        _buildQuickActionCard(
          icon: Icons.map,
          title: 'Map View',
          subtitle: 'Location tracking',
          color: Colors.green,
          onTap: () {
            // Navigate to map view with multiple pins
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const MapViewScreen(),
              ),
            );
          },
        ),
        _buildQuickActionCard(
          icon: Icons.settings,
          title: 'Settings',
          subtitle: 'App preferences',
          color: Colors.purple,
          onTap: _navigateToSettings,
        ),
      ],
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 35),
            ),
            const SizedBox(height: 10),
            TextWidget(
              text: title,
              fontSize: 16,
              fontFamily: 'Bold',
              color: Colors.black,
              align: TextAlign.center,
            ),
            const SizedBox(height: 3),
            TextWidget(
              text: subtitle,
              fontSize: 12,
              fontFamily: 'Regular',
              color: Colors.grey[600],
              align: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLastAlertCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
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
              const Icon(Icons.access_time, color: primary),
              const SizedBox(width: 10),
              TextWidget(
                text: 'Last Alert',
                fontSize: 18,
                fontFamily: 'Bold',
                color: Colors.black,
              ),
            ],
          ),
          const SizedBox(height: 15),
          _buildInfoRow(Icons.schedule, 'Time', _lastAlertTime),
          const SizedBox(height: 10),
          _buildInfoRow(Icons.location_on, 'Location', _lastAlertLocation),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 10),
        TextWidget(
          text: '$label: ',
          fontSize: 14,
          fontFamily: 'Medium',
          color: Colors.grey[700],
        ),
        Expanded(
          child: TextWidget(
            text: value,
            fontSize: 14,
            fontFamily: 'Regular',
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildSystemStatusCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
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
              const Icon(Icons.info_outline, color: primary),
              const SizedBox(width: 10),
              TextWidget(
                text: 'System Status',
                fontSize: 18,
                fontFamily: 'Bold',
                color: Colors.black,
              ),
            ],
          ),
          const SizedBox(height: 15),
          _buildStatusRow('IoT Connection', true),
          const SizedBox(height: 10),
          _buildStatusRow('Firebase Cloud Messaging', true),
          const SizedBox(height: 10),
          _buildStatusRow('GPS Tracking', true),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String label, bool isActive) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: isActive ? Colors.green : Colors.red,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: TextWidget(
            text: label,
            fontSize: 14,
            fontFamily: 'Regular',
            color: Colors.grey[700],
          ),
        ),
        TextWidget(
          text: isActive ? 'Active' : 'Inactive',
          fontSize: 14,
          fontFamily: 'Medium',
          color: isActive ? Colors.green : Colors.red,
        ),
      ],
    );
  }
}
