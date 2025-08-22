import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (ctx, orientation, deviceType) {
        return Scaffold(
          extendBodyBehindAppBar: true, // Lets body extend behind app bar
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            // backgroundColor:,
            elevation: 0,
            centerTitle: true,
            title: Text(
              "Settings",
              style: TextStyle(
                color: Colors.black,
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          backgroundColor: const Color(0xFFF5F8FB),
          body: Stack(
            children: [
              Positioned.fill(
                child: Image.asset('assets/images/Blur.png', fit: BoxFit.cover),
              ),
              Column(
                children: [
                  SizedBox(height: MediaQuery.of(context).padding.top + 5.h),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                        horizontal: 6.w,
                        vertical: 3.h,
                      ),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 6.5.h,
                            backgroundColor: Colors.white,
                            child: CircleAvatar(
                              radius: 6.h,
                              backgroundImage: const AssetImage(
                                'assets/images/profile.jpg',
                              ),
                            ),
                          ),
                          SizedBox(height: 4.h),
                          _SettingsButton(
                            icon: Icons.person_outline_rounded,
                            label: 'Edit Picture',
                            onTap: () {
                              // TODO: Implement edit picture logic
                            },
                          ),
                          SizedBox(height: 2.h),
                          _SettingsButton(
                            icon: Icons.lock_outline_rounded,
                            label: 'Forgot Password',
                            onTap: () {
                              // TODO: Implement forgot password logic
                            },
                          ),
                          SizedBox(height: 2.h),
                          _SettingsButton(
                            icon: Icons.logout_rounded,
                            label: 'Logout',
                            onTap: () {
                              // TODO: Implement logout logic
                            },
                          ),
                          SizedBox(height: 4.h),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return Container(
      padding: EdgeInsets.only(
        top: top + 1.2.h,
        left: 4.w,
        right: 4.w,
        bottom: 2.2.h,
      ),
      width: double.infinity,
      // decoration: const BoxDecoration(
      //   gradient: LinearGradient(
      //     colors: [Color(0xFFBFD6FF), Color(0xFFE7EFFA)],
      //     begin: Alignment.topLeft,
      //     end: Alignment.bottomRight,
      //   ),
      //   borderRadius: BorderRadius.only(
      //     bottomLeft: Radius.circular(26),
      //     bottomRight: Radius.circular(26),
      //   ),
      // ),
      child: Row(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(40),
            onTap: () => Navigator.pop(context),
            child: Padding(
              padding: EdgeInsets.all(1.2.h),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 2.2.h,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                'Settings',
                style: TextStyle(
                  fontSize: 16.5.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
          SizedBox(width: 4.w), // spacer to balance back button
        ],
      ),
    );
  }
}

class _SettingsButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SettingsButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 1.5,
      // color: Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        splashColor: Colors.white24,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF1D61E7),
                Color(0xBD1D61E7), // Blue
                // Color(0x1FFFFFFF), // Light Blue
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          height: 7.h,
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          alignment: Alignment.centerLeft,
          child: Row(
            children: [
              Container(
                width: 5.8.h,
                height: 5.8.h,

                child: Icon(icon, color: Colors.white, size: 2.6.h),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: Colors.white.withOpacity(.9),
                size: 3.2.h,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
