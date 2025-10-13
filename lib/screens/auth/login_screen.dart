import 'package:flutter/material.dart';
import 'package:safelink/screens/auth/signup_screen.dart';
import 'package:safelink/screens/dashboard/dashboard_screen.dart';
import 'package:safelink/services/auth_service.dart';
import 'package:safelink/utils/colors.dart';
import 'package:safelink/widgets/button_widget.dart';
import 'package:safelink/widgets/text_widget.dart';
import 'package:safelink/widgets/textfield_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Sign in with Firebase
      final result = await _authService.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        if (result['success']) {
          // Navigate to dashboard after successful login
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const DashboardScreen()),
          );
        } else {
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message']),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    }
  }

  Future<void> _handleForgotPassword() async {
    final emailController = TextEditingController(
      text: _emailController.text.trim(),
    );
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
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
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.lock_reset,
                        color: primary,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextWidget(
                            text: 'Forgot Password?',
                            fontSize: 20,
                            fontFamily: 'Bold',
                            color: Colors.black,
                          ),
                          const SizedBox(height: 3),
                          TextWidget(
                            text: 'Reset your password',
                            fontSize: 13,
                            fontFamily: 'Regular',
                            color: Colors.grey[600],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                TextWidget(
                  text:
                      'Enter your email address and we\'ll send you a link to reset your password.',
                  fontSize: 14,
                  fontFamily: 'Regular',
                  color: Colors.grey[700],
                  maxLines: 5,
                ),
                const SizedBox(height: 20),
                TextFieldWidget(
                  label: 'Email Address',
                  hint: 'Enter your email',
                  controller: emailController,
                  inputType: TextInputType.emailAddress,
                  borderColor: primary,
                  prefix: const Icon(Icons.email_outlined, size: 20),
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
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        emailController.dispose();
                        Navigator.pop(context);
                      },
                      child: TextWidget(
                        text: 'Cancel',
                        fontSize: 14,
                        fontFamily: 'Medium',
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () async {
                        if (formKey.currentState!.validate()) {
                          // Close dialog
                          Navigator.pop(context);

                          // Show loading
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) => const Center(
                              child: CircularProgressIndicator(
                                color: primary,
                              ),
                            ),
                          );

                          // Send reset email
                          final result = await _authService.resetPassword(
                            email: emailController.text.trim(),
                          );

                          // Close loading
                          if (mounted) Navigator.pop(context);

                          // Show result
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(result['message']),
                                backgroundColor:
                                    result['success'] ? Colors.green : Colors.red,
                                duration: const Duration(seconds: 4),
                              ),
                            );
                          }

                          emailController.dispose();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: TextWidget(
                        text: 'Send Reset Link',
                        fontSize: 14,
                        fontFamily: 'Bold',
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  Image.asset(
                    'assets/images/icon.png',
                    width: 120,
                    height: 120,
                  ),
                  const SizedBox(height: 20),

                  // App Name
                  TextWidget(
                    text: 'SafeLink',
                    fontSize: 32,
                    fontFamily: 'Bold',
                    color: primary,
                  ),
                  const SizedBox(height: 10),

                  // Subtitle
                  TextWidget(
                    text: 'Accident Detection & Alert System',
                    fontSize: 14,
                    fontFamily: 'Regular',
                    color: Colors.grey[600],
                    align: TextAlign.center,
                  ),
                  const SizedBox(height: 40),

                  // Welcome Text
                  TextWidget(
                    text: 'Welcome Back',
                    fontSize: 24,
                    fontFamily: 'Bold',
                    color: Colors.black,
                  ),
                  const SizedBox(height: 8),
                  TextWidget(
                    text: 'Sign in to continue',
                    fontSize: 14,
                    fontFamily: 'Regular',
                    color: Colors.grey[600],
                  ),
                  const SizedBox(height: 30),

                  // Email Field
                  TextFieldWidget(
                    label: 'Email',
                    hint: 'Enter your email',
                    controller: _emailController,
                    inputType: TextInputType.emailAddress,
                    borderColor: primary,
                    prefix: const Icon(Icons.email_outlined, size: 20),
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

                  // Password Field
                  TextFieldWidget(
                    label: 'Password',
                    hint: 'Enter your password',
                    controller: _passwordController,
                    isObscure: true,
                    showEye: true,
                    borderColor: primary,
                    prefix: const Icon(Icons.lock_outline, size: 20),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),

                  // Forgot Password
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _handleForgotPassword,
                      child: TextWidget(
                        text: 'Forgot Password?',
                        fontSize: 14,
                        fontFamily: 'Medium',
                        color: primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Login Button
                  ButtonWidget(
                    label: 'Login',
                    onPressed: _isLoading ? null : _handleLogin,
                    isLoading: _isLoading,
                    width: double.infinity,
                  ),
                  const SizedBox(height: 20),

                  // Sign Up Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextWidget(
                        text: "Don't have an account? ",
                        fontSize: 14,
                        fontFamily: 'Regular',
                        color: Colors.grey[600],
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const SignUpScreen(),
                            ),
                          );
                        },
                        child: TextWidget(
                          text: 'Sign Up',
                          fontSize: 14,
                          fontFamily: 'Bold',
                          color: primary,
                        ),
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
}
