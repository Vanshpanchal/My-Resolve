import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:sizer/sizer.dart';
import 'package:myresolve/Utils/firebase_notification_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Map<String, dynamic>? _currentReminder;

  @override
  void initState() {
    super.initState();
    _loadCurrentReminder();
  }


  Future<void> _loadCurrentReminder() async {
    final reminder = await FirebaseNotificationService.getCurrentReminder();
    if (mounted) {
      setState(() {
        _currentReminder = reminder;
      });
    }
  }

  Future<void> _pickReminderTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Color(0xFF1D61E7), // App blue
              onPrimary: Colors.white, // Text on blue
              onSurface: Colors.black, // Text on white
            ),
            dialogTheme: DialogThemeData(
              backgroundColor: Colors.white,
            ),
            timePickerTheme: TimePickerThemeData(
              backgroundColor: Colors.white,
              hourMinuteColor: WidgetStateColor.resolveWith((states) => Color(0xFF1D61E7)),
              hourMinuteTextColor: WidgetStateColor.resolveWith((states) => Colors.white),
              dayPeriodColor: WidgetStateColor.resolveWith((states) => Color(0xFF1D61E7)),
              dayPeriodTextColor: WidgetStateColor.resolveWith((states) => Colors.white),
              dialHandColor: Color(0xFF1D61E7),
              dialBackgroundColor: Color(0xFFE7EFFA),
              entryModeIconColor: Color(0xFF1D61E7),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      final box = await Hive.openBox('reminderBox');
      await box.put('reminder', {'hour': picked.hour, 'minute': picked.minute});
      // Schedule Firebase notification
      await FirebaseNotificationService.scheduleDailyReminder(picked.hour, picked.minute, context: context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Daily reminder set for ${picked.format(context)}')),
      );
    }
  }

  Future<void> _cancelReminder(BuildContext context) async {
    await FirebaseNotificationService.cancelDailyReminder(context: context);
    await _loadCurrentReminder();
  }

  String _getReminderStatusText() {
    if (_currentReminder == null || _currentReminder!['enabled'] != true) {
      return 'No daily reminder set';
    }
    
    final hour = _currentReminder!['hour'] ?? 0;
    final minute = _currentReminder!['minute'] ?? 0;
    final timeString = '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
    
    return 'Daily reminder: $timeString';
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        Navigator.of(context).pop();
      },
      child: Sizer(
        builder: (ctx, orientation, deviceType) {
        return Scaffold(
          extendBodyBehindAppBar: true, // Lets body extend behind app bar
          appBar: AppBar(
            backgroundColor: Colors.transparent,
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
                            label: 'Edit Profile',
                            onTap: () {
                              // TODO: Implement edit profile logic
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
                          // Daily Reminder Status and Controls
                          Container(
                            padding: EdgeInsets.all(4.w),
                            margin: EdgeInsets.symmetric(vertical: 1.h),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.alarm,
                                      color: Color(0xFF1D61E7),
                                      size: 6.w,
                                    ),
                                    SizedBox(width: 3.w),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Daily Reminder',
                                            style: TextStyle(
                                              fontSize: 16.sp,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          Text(
                                            _getReminderStatusText(),
                                            style: TextStyle(
                                              fontSize: 12.sp,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 2.h),
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: () => _pickReminderTime(context),
                                        icon: Icon(
                                          _currentReminder?['enabled'] == true 
                                            ? Icons.edit_notifications 
                                            : Icons.add_alarm,
                                          size: 4.w,
                                        ),
                                        label: Text(
                                          _currentReminder?['enabled'] == true 
                                            ? 'Change Time' 
                                            : 'Set Reminder',
                                          style: TextStyle(fontSize: 12.sp),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Color(0xFF1D61E7),
                                          foregroundColor: Colors.white,
                                          padding: EdgeInsets.symmetric(vertical: 1.5.h),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                        ),
                                      ),
                                    ),
                                    if (_currentReminder?['enabled'] == true) ...[
                                      SizedBox(width: 3.w),
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          onPressed: () => _cancelReminder(context),
                                          icon: Icon(Icons.alarm_off, size: 4.w),
                                          label: Text(
                                            'Cancel',
                                            style: TextStyle(fontSize: 12.sp),
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.orange,
                                            foregroundColor: Colors.white,
                                            padding: EdgeInsets.symmetric(vertical: 1.5.h),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 2.h),
                          // Test notification button
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(4.w),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.orange.shade200),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.bug_report, color: Colors.orange, size: 5.w),
                                    SizedBox(width: 3.w),
                                    Text(
                                      'Test Notifications',
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.orange.shade800,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 1.h),
                                Text(
                                  'Test if local notifications work on your device',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                SizedBox(height: 2.h),
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: () async {
                                          await FirebaseNotificationService.testImmediateNotification(context: context);
                                        },
                                        icon: Icon(Icons.notifications_active, size: 4.w),
                                        label: Text(
                                          'Test Now',
                                          style: TextStyle(fontSize: 12.sp),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.purple,
                                          foregroundColor: Colors.white,
                                          padding: EdgeInsets.symmetric(vertical: 1.5.h),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 2.w),
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: () async {
                                          await FirebaseNotificationService.testScheduledLocalNotification(context: context);
                                        },
                                        icon: Icon(Icons.schedule, size: 4.w),
                                        label: Text(
                                          'Test 5s',
                                          style: TextStyle(fontSize: 12.sp),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.orange,
                                          foregroundColor: Colors.white,
                                          padding: EdgeInsets.symmetric(vertical: 1.5.h),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 1.h),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    onPressed: () async {
                                      await FirebaseNotificationService.requestAllPermissions(context);
                                    },
                                    icon: Icon(Icons.security, size: 4.w),
                                    label: Text(
                                      'Fix Permissions & Settings',
                                      style: TextStyle(fontSize: 12.sp),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      foregroundColor: Colors.white,
                                      padding: EdgeInsets.symmetric(vertical: 1.5.h),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
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
    ));
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
                color: Colors.white.withValues(alpha: 0.9),
                size: 3.2.h,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
