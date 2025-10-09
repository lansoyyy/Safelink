import 'package:flutter/material.dart';
import 'package:safelink/utils/colors.dart';
import 'package:safelink/widgets/button_widget.dart';
import 'package:safelink/widgets/text_widget.dart';
import 'package:safelink/widgets/textfield_widget.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // TODO: Implement Firebase authentication
      await Future.delayed(const Duration(seconds: 2));

      setState(() {
        _isLoading = false;
      });

      // TODO: Navigate to dashboard or show success message
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
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
                    width: 100,
                    height: 100,
                  ),
                  const SizedBox(height: 20),

                  // Title
                  TextWidget(
                    text: 'Create Account',
                    fontSize: 28,
                    fontFamily: 'Bold',
                    color: Colors.black,
                  ),
                  const SizedBox(height: 8),
                  TextWidget(
                    text: 'Sign up to get started',
                    fontSize: 14,
                    fontFamily: 'Regular',
                    color: Colors.grey[600],
                  ),
                  const SizedBox(height: 30),

                  // Full Name Field
                  TextFieldWidget(
                    label: 'Full Name',
                    hint: 'Enter your full name',
                    controller: _nameController,
                    inputType: TextInputType.name,
                    borderColor: primary,
                    prefix: const Icon(Icons.person_outline, size: 20),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your full name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),

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

                  // Phone Number Field
                  TextFieldWidget(
                    label: 'Phone Number',
                    hint: 'Enter your phone number',
                    controller: _phoneController,
                    inputType: TextInputType.phone,
                    borderColor: primary,
                    prefix: const Icon(Icons.phone_outlined, size: 20),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your phone number';
                      }
                      if (value.length < 10) {
                        return 'Please enter a valid phone number';
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

                  // Confirm Password Field
                  TextFieldWidget(
                    label: 'Confirm Password',
                    hint: 'Re-enter your password',
                    controller: _confirmPasswordController,
                    isObscure: true,
                    showEye: true,
                    borderColor: primary,
                    prefix: const Icon(Icons.lock_outline, size: 20),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your password';
                      }
                      if (value != _passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 30),

                  // Sign Up Button
                  ButtonWidget(
                    label: 'Sign Up',
                    onPressed: _isLoading ? null : _handleSignUp,
                    isLoading: _isLoading,
                    width: double.infinity,
                  ),
                  const SizedBox(height: 20),

                  // Login Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextWidget(
                        text: 'Already have an account? ',
                        fontSize: 14,
                        fontFamily: 'Regular',
                        color: Colors.grey[600],
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: TextWidget(
                          text: 'Login',
                          fontSize: 14,
                          fontFamily: 'Bold',
                          color: primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
