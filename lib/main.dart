import 'package:flutter/material.dart';
import 'package:safelink/screens/auth/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SafeLink',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Regular',
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const SplashScreen(),
    );
  }
}
