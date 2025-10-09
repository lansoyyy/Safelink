import 'package:flutter/material.dart';
import 'package:safelink/utils/colors.dart';
import 'package:safelink/widgets/text_widget.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

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
          text: 'About / Help',
          fontSize: 20,
          fontFamily: 'Bold',
          color: Colors.white,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App Logo and Version
            Center(
              child: Column(
                children: [
                  Image.asset(
                    'assets/images/logo.png',
                    width: 150,
                    height: 150,
                  ),
                  const SizedBox(height: 15),
                  TextWidget(
                    text: 'SafeLink',
                    fontSize: 28,
                    fontFamily: 'Bold',
                    color: primary,
                  ),
                  const SizedBox(height: 5),
                  TextWidget(
                    text: 'Version 1.0.0',
                    fontSize: 14,
                    fontFamily: 'Regular',
                    color: Colors.grey[600],
                  ),
                  const SizedBox(height: 5),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: TextWidget(
                      text: 'IoT-Based Accident Detection System',
                      fontSize: 12,
                      fontFamily: 'Medium',
                      color: primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // About Section
            _buildSectionCard(
              title: 'About SafeLink',
              icon: Icons.info_outline,
              iconColor: Colors.blue,
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextWidget(
                    text:
                        'SafeLink is an IoT-based accident detection and alert system designed to enhance safety and emergency response within communities. The system uses advanced sensors and real-time monitoring to detect accidents and immediately notify authorized personnel.',
                    fontSize: 14,
                    fontFamily: 'Regular',
                    color: Colors.grey[700],
                    maxLines: 20,
                  ),
                  const SizedBox(height: 15),
                  TextWidget(
                    text:
                        'This mobile application serves as the monitoring interface for HOA officers and security personnel, enabling them to receive instant alerts and respond quickly to emergencies.',
                    fontSize: 14,
                    fontFamily: 'Regular',
                    color: Colors.grey[700],
                    maxLines: 20,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),

            // How It Works Section
            _buildSectionCard(
              title: 'How It Works',
              icon: Icons.settings_suggest,
              iconColor: Colors.green,
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHowItWorksStep(
                    number: '1',
                    title: 'Accident Detection',
                    description:
                        'IoT sensors continuously monitor for accidents using motion detection, impact sensors, and other advanced technologies.',
                  ),
                  const SizedBox(height: 15),
                  _buildHowItWorksStep(
                    number: '2',
                    title: 'Alert Classification',
                    description:
                        'The system classifies alerts as either Emergency (with image and location) or Warning (location only) based on severity.',
                  ),
                  const SizedBox(height: 15),
                  _buildHowItWorksStep(
                    number: '3',
                    title: 'Real-Time Notification',
                    description:
                        'Firebase Cloud Messaging (FCM) sends instant push notifications to the mobile app with alert details.',
                  ),
                  const SizedBox(height: 15),
                  _buildHowItWorksStep(
                    number: '4',
                    title: 'Alert Response',
                    description:
                        'Emergency alerts trigger continuous sound/vibration (5 minutes), while warnings provide short notifications (2-3 times).',
                  ),
                  const SizedBox(height: 15),
                  _buildHowItWorksStep(
                    number: '5',
                    title: 'Action & Resolution',
                    description:
                        'Officers can view location, images, and details to respond appropriately. Alerts can be acknowledged and cleared once handled.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),

            // Key Features Section
            _buildSectionCard(
              title: 'Key Features',
              icon: Icons.star_outline,
              iconColor: Colors.orange,
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFeatureItem(
                    Icons.emergency,
                    'Emergency Alert Detection',
                    'Immediate notification with image and GPS location',
                  ),
                  _buildFeatureItem(
                    Icons.warning_amber,
                    'Warning Alerts',
                    'Location-based warnings for potential incidents',
                  ),
                  _buildFeatureItem(
                    Icons.history,
                    'Alert History',
                    'Complete record of all past alerts and incidents',
                  ),
                  _buildFeatureItem(
                    Icons.contact_phone,
                    'Emergency Contacts',
                    'Store and notify saved contacts during emergencies',
                  ),
                  _buildFeatureItem(
                    Icons.map,
                    'Map View',
                    'Visual location tracking with GPS coordinates',
                  ),
                  _buildFeatureItem(
                    Icons.notifications_active,
                    'Real-Time Notifications',
                    'Instant alerts via Firebase Cloud Messaging',
                  ),
                  _buildFeatureItem(
                    Icons.settings,
                    'Customizable Settings',
                    'Configure sound, vibration, and notification preferences',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),

            // Alert Types Section
            _buildSectionCard(
              title: 'Alert Types',
              icon: Icons.notifications_active,
              iconColor: Colors.red,
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAlertTypeCard(
                    'Emergency Alert',
                    Colors.red,
                    Icons.emergency,
                    [
                      'Triggered by severe accidents',
                      'Includes accident image',
                      'GPS location data',
                      'Continuous sound/vibration (5 minutes)',
                      'Requires immediate attention',
                    ],
                  ),
                  const SizedBox(height: 15),
                  _buildAlertTypeCard(
                    'Warning Alert',
                    Colors.orange,
                    Icons.warning_amber,
                    [
                      'Triggered by potential incidents',
                      'GPS coordinates only',
                      'No image attached',
                      'Short notification (2-3 times)',
                      'Requires monitoring',
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),

            // FAQ Section
            _buildSectionCard(
              title: 'Frequently Asked Questions',
              icon: Icons.help_outline,
              iconColor: Colors.purple,
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFAQItem(
                    'How do I respond to an emergency alert?',
                    'Tap the alert notification to view details including location and image. Use the "View Location" button to see the exact GPS coordinates on a map. Once you\'ve responded, tap "Clear Alert" to acknowledge.',
                  ),
                  const SizedBox(height: 15),
                  _buildFAQItem(
                    'Can I customize notification settings?',
                    'Yes! Go to Settings to enable/disable notifications, sound alerts, vibration, and choose to receive emergency alerts only.',
                  ),
                  const SizedBox(height: 15),
                  _buildFAQItem(
                    'How do emergency contacts work?',
                    'Add contacts in the Emergency Contacts section. When an accident is detected, you can manually send alerts to all saved contacts. Primary contacts are notified first.',
                  ),
                  const SizedBox(height: 15),
                  _buildFAQItem(
                    'What if I miss an alert?',
                    'All alerts are saved in the History section. You can review past alerts, their timestamps, locations, and resolution status at any time.',
                  ),
                  const SizedBox(height: 15),
                  _buildFAQItem(
                    'Is my data secure?',
                    'Yes. All data is encrypted and transmitted securely through Firebase. Only authorized personnel with valid credentials can access the system.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),

            // System Requirements
            _buildSectionCard(
              title: 'System Requirements',
              icon: Icons.phone_android,
              iconColor: Colors.teal,
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildRequirementItem('Operating System', 'Android 5.0+ / iOS 11.0+'),
                  _buildRequirementItem('Internet Connection', 'Required for real-time alerts'),
                  _buildRequirementItem('Permissions', 'Notifications, Location (optional)'),
                  _buildRequirementItem('Storage', 'Minimum 50 MB available space'),
                ],
              ),
            ),
            const SizedBox(height: 15),

            // Contact & Support
            _buildSectionCard(
              title: 'Contact & Support',
              icon: Icons.support_agent,
              iconColor: Colors.indigo,
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildContactItem(Icons.email, 'Email', 'support@safelink.com'),
                  const SizedBox(height: 10),
                  _buildContactItem(Icons.phone, 'Phone', '+1 (555) 123-4567'),
                  const SizedBox(height: 10),
                  _buildContactItem(Icons.language, 'Website', 'www.safelink.com'),
                  const SizedBox(height: 10),
                  _buildContactItem(Icons.location_on, 'Address', 'Community Safety Center'),
                ],
              ),
            ),
            const SizedBox(height: 15),

            // Copyright
            Center(
              child: Column(
                children: [
                  const Divider(),
                  const SizedBox(height: 10),
                  TextWidget(
                    text: '© 2025 SafeLink. All rights reserved.',
                    fontSize: 12,
                    fontFamily: 'Regular',
                    color: Colors.grey[600],
                    align: TextAlign.center,
                  ),
                  const SizedBox(height: 5),
                  TextWidget(
                    text: 'IoT-Based Accident Detection System',
                    fontSize: 11,
                    fontFamily: 'Regular',
                    color: Colors.grey[500],
                    align: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required Widget content,
  }) {
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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextWidget(
                  text: title,
                  fontSize: 18,
                  fontFamily: 'Bold',
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          content,
        ],
      ),
    );
  }

  Widget _buildHowItWorksStep({
    required String number,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 35,
          height: 35,
          decoration: BoxDecoration(
            color: primary,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: TextWidget(
              text: number,
              fontSize: 16,
              fontFamily: 'Bold',
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextWidget(
                text: title,
                fontSize: 15,
                fontFamily: 'Bold',
                color: Colors.black,
              ),
              const SizedBox(height: 3),
              TextWidget(
                text: description,
                fontSize: 13,
                fontFamily: 'Regular',
                color: Colors.grey[600],
                maxLines: 10,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: primary, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextWidget(
                  text: title,
                  fontSize: 14,
                  fontFamily: 'Bold',
                  color: Colors.black,
                ),
                const SizedBox(height: 2),
                TextWidget(
                  text: description,
                  fontSize: 12,
                  fontFamily: 'Regular',
                  color: Colors.grey[600],
                  maxLines: 5,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertTypeCard(
    String title,
    Color color,
    IconData icon,
    List<String> features,
  ) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(width: 10),
              TextWidget(
                text: title,
                fontSize: 16,
                fontFamily: 'Bold',
                color: color,
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...features.map((feature) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 6),
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextWidget(
                        text: feature,
                        fontSize: 13,
                        fontFamily: 'Regular',
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextWidget(
          text: 'Q: $question',
          fontSize: 14,
          fontFamily: 'Bold',
          color: primary,
          maxLines: 10,
        ),
        const SizedBox(height: 5),
        TextWidget(
          text: 'A: $answer',
          fontSize: 13,
          fontFamily: 'Regular',
          color: Colors.grey[700],
          maxLines: 20,
        ),
      ],
    );
  }

  Widget _buildRequirementItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: TextWidget(
              text: label,
              fontSize: 13,
              fontFamily: 'Bold',
              color: Colors.grey[700],
            ),
          ),
          Expanded(
            child: TextWidget(
              text: value,
              fontSize: 13,
              fontFamily: 'Regular',
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: primary, size: 20),
        const SizedBox(width: 10),
        SizedBox(
          width: 80,
          child: TextWidget(
            text: label,
            fontSize: 13,
            fontFamily: 'Bold',
            color: Colors.grey[700],
          ),
        ),
        Expanded(
          child: TextWidget(
            text: value,
            fontSize: 13,
            fontFamily: 'Regular',
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
