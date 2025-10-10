import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:safelink/screens/auth/login_screen.dart';
import 'package:safelink/screens/dashboard/about_screen.dart';
import 'package:safelink/screens/dashboard/emergency_contacts_screen.dart';
import 'package:safelink/screens/dashboard/history_screen.dart';
import 'package:safelink/screens/dashboard/map_view_screen.dart';
import 'package:safelink/screens/dashboard/notifications_screen.dart';
import 'package:safelink/screens/dashboard/settings_screen.dart';
import 'package:safelink/utils/colors.dart';
import 'package:safelink/widgets/text_widget.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _hasIncomingAlert = false;
  String _alertType = 'none'; // 'emergency', 'warning', 'none'
  String _lastAlertTime = 'No alerts yet';
  String _lastAlertLocation = 'N/A';

  // Simulation toggle
  bool _simulationMode = false;

  // Simulate checking for incoming alerts
  void _checkForAlerts() {
    // TODO: Implement Firebase Cloud Messaging listener
    // This will be replaced with actual FCM implementation
  }

  void _toggleSimulation(bool value) {
    setState(() {
      _simulationMode = value;
      if (_simulationMode) {
        // Simulate an emergency alert
        _hasIncomingAlert = true;
        _alertType = 'emergency';
        _lastAlertTime = DateTime.now().toString().substring(0, 19);
        _lastAlertLocation = 'Block A, Street 5, Alsea Homes';
      } else {
        // Clear alerts
        _hasIncomingAlert = false;
        _alertType = 'none';
        _lastAlertTime = 'No alerts yet';
        _lastAlertLocation = 'N/A';
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _checkForAlerts();
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

  void _viewMapLocation() {
    // Navigate to map view with single alert location
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapViewScreen(
          isSinglePin: true,
          alertData: {
            'type': _alertType,
            'location': _lastAlertLocation,
            'coordinates': const LatLng(14.5995, 120.9842),
            'time': _lastAlertTime,
            'description': _alertType == 'emergency'
                ? 'Emergency alert detected'
                : 'Warning alert detected',
          },
        ),
      ),
    );
  }

  void _acknowledgeAlert() {
    setState(() {
      _hasIncomingAlert = false;
      _alertType = 'none';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Alert acknowledged and cleared')),
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
      body: RefreshIndicator(
        onRefresh: () async {
          _checkForAlerts();
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

                // Simulation Toggle
                _buildSimulationToggle(),
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
                _buildSystemStatusCard(),
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

  Widget _buildSimulationToggle() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: _simulationMode ? primary : Colors.grey.withOpacity(0.3),
          width: 2,
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
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _simulationMode
                  ? primary.withOpacity(0.1)
                  : Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.science_outlined,
              color: _simulationMode ? primary : Colors.grey[600],
              size: 28,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextWidget(
                  text: 'Simulation Mode',
                  fontSize: 16,
                  fontFamily: 'Bold',
                  color: Colors.black,
                ),
                const SizedBox(height: 3),
                TextWidget(
                  text: _simulationMode
                      ? 'Active Alert Simulation ON'
                      : 'No Alerts Simulation',
                  fontSize: 13,
                  fontFamily: 'Regular',
                  color: _simulationMode ? primary : Colors.grey[600],
                ),
              ],
            ),
          ),
          Switch(
            value: _simulationMode,
            activeColor: primary,
            onChanged: _toggleSimulation,
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
                    onPressed: _viewMapLocation,
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
                builder: (context) => const MapViewScreen(
                  isSinglePin: false,
                ),
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
