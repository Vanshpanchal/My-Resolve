import 'package:flutter/material.dart';
import 'package:myresolve/Utils/Colors.dart';
import 'package:sizer/sizer.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscureText = true;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Widget _buildLogo() {
    // Placeholder for logo. Replace with your asset if needed.
    return Container(
      width: 15.w,
      height: 15.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [Colors.blue.shade100, Colors.blue.shade300],
          tileMode: TileMode.clamp,

          // begin: Alignment.topCenter,
          // end: Alignment.bottomCenter,
        ),
      ),
      child: Center(
        child: Icon(Icons.security, color: Colors.blue, size: 10.w),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FB),
      body: Stack(
        children: [
          // Blue wavy background at the top
          SizedBox(
            height: 20.h,
            width: 100.w,
            child: Stack(
              fit: StackFit.expand,
              children: [

                Image.asset(
                  'assets/images/Blur.png',
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                ),
              ],
            ),
          ),
          // Main UI
          SingleChildScrollView(
            child: SizedBox(
              width: 100.w,
              height: 100.h,
              child: Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: 8.h),
                      _buildLogo(),
                      SizedBox(height: 5.h),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Sign in to your\nAccount",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 24.sp,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      SizedBox(height: 1.5.h),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Enter your email and password to log in",
                          style: TextStyle(
                            fontSize: 15.sp,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                      SizedBox(height: 4.h),
                      TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 2.0.h,
                            horizontal: 4.w,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          hintText: "Enter your email",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(3.w),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        style: TextStyle(fontSize: 16.sp),
                      ),
                      SizedBox(height: 2.h),
                      TextField(
                        controller: _passwordController,
                        obscureText: _obscureText,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 2.0.h,
                            horizontal: 4.w,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          hintText: "Enter your password",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(3.w),
                            borderSide: BorderSide.none,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureText
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureText = !_obscureText;
                              });
                            },
                          ),
                        ),
                        style: TextStyle(fontSize: 16.sp),
                      ),
                      SizedBox(height: 1.5.h),
                      Align(
                        alignment: Alignment.center,
                        child: TextButton(
                          onPressed: () {
                            // Forgot Password logic here
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size(0, 0),
                          ),
                          child: Text(
                            "Forgot Password ?",
                            style: TextStyle(
                              color: AppColors.information,
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 2.h),
                      SizedBox(
                        width: double.infinity,
                        height: 6.5.h,
                        child: gradientButton(
                          context,
                          onPressed: () {
                            // Login logic here
                          },
                          text: "Login",
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don’t have an account? ",
                            style: TextStyle(
                              fontSize: 15.sp,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              // Sign Up logic here
                            },
                            child: Text(
                              "Sign Up",
                              style: TextStyle(
                                fontSize: 15.sp,
                                color: AppColors.information,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 5.h),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BlueWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    // This creates a wavy effect at the bottom of the blue background
    Path path = Path();
    path.lineTo(0, size.height - 40);
    path.cubicTo(
      size.width * 0.25,
      size.height,
      size.width * 0.75,
      size.height - 80,
      size.width,
      size.height - 40,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

Widget gradientButton(
  BuildContext context, {
  required VoidCallback onPressed,
  required String text,
}) {
  return SizedBox(
    width: double.infinity,
    height: 6.5.h,
    child: Stack(
      children: [
        // Blue background
        Container(
          decoration: BoxDecoration(
            color: AppColors.buttonBlue,
            borderRadius: BorderRadius.circular(3.w),
          ),
        ),
        // White linear gradient overlay at 12% opacity
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3.w),
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.12),
                Colors.white.withOpacity(0.12),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        // ElevatedButton with transparent background
        Positioned.fill(
          child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              // Make button background and shadow transparent
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(3.w),
              ),
              // Remove minimum size if needed
              minimumSize: Size(0, 0),
              padding: EdgeInsets.zero,
            ),
            child: Text(
              text,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
