import 'package:flutter/material.dart';
import 'package:safelink/screens/auth/signup_screen.dart';
import 'package:safelink/screens/dashboard/dashboard_screen.dart';
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

      // TODO: Implement Firebase authentication
      await Future.delayed(const Duration(seconds: 2));

      setState(() {
        _isLoading = false;
      });

      // Navigate to dashboard after successful login
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
        );
      }
    }
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
                      onPressed: () {
                        // TODO: Implement forgot password
                      },
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
