import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:sizer/sizer.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    await Future.delayed(const Duration(seconds: 2));
    const storage = FlutterSecureStorage();
    String? token = await storage.read(key: 'token');
    if (token != null && token.isNotEmpty) {
      Navigator.of(context).pushReplacementNamed('/main');
    } else {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background image with fade in
          Image.asset(
            'assets/images/Splash.png',
            fit: BoxFit.cover,
          ).animate().fadeIn(duration: 1200.ms),

          // Centered animated logo and text
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo with scale + fade
                Image.asset(
                  'assets/images/Logo.png',
                  width: 12.w,
                  height: 12.w,
                ).animate().scale(duration: 800.ms).fadeIn(),

                SizedBox(height: 3.h),

                // App name image with slide + fade
                Image.asset(
                  'assets/images/myresolve.png',
                  width: 60.w,
                  height: 25.w,
                ).animate().slideY(begin: 1, duration: 900.ms).fadeIn(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
