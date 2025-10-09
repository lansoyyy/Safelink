import 'package:flutter/material.dart';
import 'package:safelink/utils/colors.dart';
import 'package:safelink/widgets/button_widget.dart';
import 'package:safelink/widgets/text_widget.dart';
import 'package:safelink/widgets/textfield_widget.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Alert Preferences
  bool _notificationsEnabled = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  bool _emergencyAlertsOnly = false;

  // Profile data
  String _userName = 'HOA Officer';
  String _userEmail = 'officer@safelink.com';
  String _userPhone = '+1 (555) 123-4567';

  void _showUpdateProfileDialog() {
    final nameController = TextEditingController(text: _userName);
    final emailController = TextEditingController(text: _userEmail);
    final phoneController = TextEditingController(text: _userPhone);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.edit, color: primary, size: 28),
                      const SizedBox(width: 10),
                      TextWidget(
                        text: 'Update Profile',
                        fontSize: 22,
                        fontFamily: 'Bold',
                        color: Colors.black,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  TextFieldWidget(
                    label: 'Full Name',
                    hint: 'Enter your full name',
                    controller: nameController,
                    borderColor: primary,
                    prefix: const Icon(Icons.person, size: 20),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFieldWidget(
                    label: 'Email',
                    hint: 'Enter your email',
                    controller: emailController,
                    inputType: TextInputType.emailAddress,
                    borderColor: primary,
                    prefix: const Icon(Icons.email, size: 20),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!value.contains('@')) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFieldWidget(
                    label: 'Phone Number',
                    hint: 'Enter your phone number',
                    controller: phoneController,
                    inputType: TextInputType.phone,
                    borderColor: primary,
                    prefix: const Icon(Icons.phone, size: 20),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your phone number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: TextWidget(
                          text: 'Cancel',
                          fontSize: 14,
                          fontFamily: 'Medium',
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(width: 10),
                      ButtonWidget(
                        label: 'Save',
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            setState(() {
                              _userName = nameController.text;
                              _userEmail = emailController.text;
                              _userPhone = phoneController.text;
                            });
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Profile updated successfully'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        },
                        width: 120,
                        height: 45,
                        fontSize: 14,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showChangePasswordDialog() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.lock, color: primary, size: 28),
                      const SizedBox(width: 10),
                      TextWidget(
                        text: 'Change Password',
                        fontSize: 22,
                        fontFamily: 'Bold',
                        color: Colors.black,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  TextFieldWidget(
                    label: 'Current Password',
                    hint: 'Enter current password',
                    controller: currentPasswordController,
                    isObscure: true,
                    showEye: true,
                    borderColor: primary,
                    prefix: const Icon(Icons.lock_outline, size: 20),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter current password';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFieldWidget(
                    label: 'New Password',
                    hint: 'Enter new password',
                    controller: newPasswordController,
                    isObscure: true,
                    showEye: true,
                    borderColor: primary,
                    prefix: const Icon(Icons.lock_outline, size: 20),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter new password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFieldWidget(
                    label: 'Confirm New Password',
                    hint: 'Re-enter new password',
                    controller: confirmPasswordController,
                    isObscure: true,
                    showEye: true,
                    borderColor: primary,
                    prefix: const Icon(Icons.lock_outline, size: 20),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm new password';
                      }
                      if (value != newPasswordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: TextWidget(
                          text: 'Cancel',
                          fontSize: 14,
                          fontFamily: 'Medium',
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(width: 10),
                      ButtonWidget(
                        label: 'Change',
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            // TODO: Implement password change with Firebase Auth
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Password changed successfully'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        },
                        width: 120,
                        height: 45,
                        fontSize: 14,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
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
          text: 'Settings',
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
            // Profile Section
            _buildSectionTitle('Profile Management'),
            _buildProfileCard(),
            const SizedBox(height: 25),

            // Alert Preferences
            _buildSectionTitle('Alert Preferences'),
            _buildAlertPreferencesCard(),
            const SizedBox(height: 25),

            // Security Section
            _buildSectionTitle('Security'),
            _buildSecurityCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextWidget(
        text: title,
        fontSize: 18,
        fontFamily: 'Bold',
        color: Colors.black,
      ),
    );
  }

  Widget _buildProfileCard() {
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
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: primary.withOpacity(0.1),
                child: const Icon(Icons.person, size: 45, color: primary),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextWidget(
                      text: _userName,
                      fontSize: 18,
                      fontFamily: 'Bold',
                      color: Colors.black,
                    ),
                    const SizedBox(height: 3),
                    TextWidget(
                      text: _userEmail,
                      fontSize: 14,
                      fontFamily: 'Regular',
                      color: Colors.grey[600],
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Icon(Icons.phone, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 5),
                        TextWidget(
                          text: _userPhone,
                          fontSize: 13,
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
          const SizedBox(height: 15),
          const Divider(),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _showUpdateProfileDialog,
              icon: const Icon(Icons.edit, size: 20),
              label: const Text('Update Profile'),
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
      ),
    );
  }

  Widget _buildAlertPreferencesCard() {
    return Container(
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
        children: [
          SwitchListTile(
            title: TextWidget(
              text: 'Enable Notifications',
              fontSize: 16,
              fontFamily: 'Medium',
              color: Colors.black,
            ),
            subtitle: TextWidget(
              text: 'Receive alert notifications',
              fontSize: 12,
              fontFamily: 'Regular',
              color: Colors.grey[600],
            ),
            value: _notificationsEnabled,
            activeColor: primary,
            onChanged: (value) => setState(() => _notificationsEnabled = value),
          ),
          const Divider(height: 1),
          SwitchListTile(
            title: TextWidget(
              text: 'Sound Alerts',
              fontSize: 16,
              fontFamily: 'Medium',
              color: Colors.black,
            ),
            subtitle: TextWidget(
              text: 'Play sound for emergency alerts',
              fontSize: 12,
              fontFamily: 'Regular',
              color: Colors.grey[600],
            ),
            value: _soundEnabled,
            activeColor: primary,
            onChanged: _notificationsEnabled
                ? (value) => setState(() => _soundEnabled = value)
                : null,
          ),
          const Divider(height: 1),
          SwitchListTile(
            title: TextWidget(
              text: 'Vibration',
              fontSize: 16,
              fontFamily: 'Medium',
              color: Colors.black,
            ),
            subtitle: TextWidget(
              text: 'Vibrate on alerts',
              fontSize: 12,
              fontFamily: 'Regular',
              color: Colors.grey[600],
            ),
            value: _vibrationEnabled,
            activeColor: primary,
            onChanged: _notificationsEnabled
                ? (value) => setState(() => _vibrationEnabled = value)
                : null,
          ),
          const Divider(height: 1),
          SwitchListTile(
            title: TextWidget(
              text: 'Emergency Alerts Only',
              fontSize: 16,
              fontFamily: 'Medium',
              color: Colors.black,
            ),
            subtitle: TextWidget(
              text: 'Only show emergency alerts, hide warnings',
              fontSize: 12,
              fontFamily: 'Regular',
              color: Colors.grey[600],
            ),
            value: _emergencyAlertsOnly,
            activeColor: primary,
            onChanged: _notificationsEnabled
                ? (value) => setState(() => _emergencyAlertsOnly = value)
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityCard() {
    return Container(
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
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.lock_outline, color: primary, size: 28),
        ),
        title: TextWidget(
          text: 'Change Password',
          fontSize: 16,
          fontFamily: 'Bold',
          color: Colors.black,
        ),
        subtitle: TextWidget(
          text: 'Update your account password',
          fontSize: 12,
          fontFamily: 'Regular',
          color: Colors.grey[600],
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: _showChangePasswordDialog,
      ),
    );
  }
}
