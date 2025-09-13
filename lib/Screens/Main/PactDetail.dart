import 'dart:async';

import 'package:flutter/material.dart';
import 'package:myresolve/Utils/reminder_helper.dart';
import 'package:sizer/sizer.dart';

class PactDetailScreen extends StatefulWidget {
  const PactDetailScreen({Key? key}) : super(key: key);

  @override
  State<PactDetailScreen> createState() => _PactDetailScreenState();
}

class _PactDetailScreenState extends State<PactDetailScreen> {
  final ValueNotifier<String> _reminderTimeStrNotifier = ValueNotifier('00:00:00');
  Timer? _reminderTimer;

  @override
  void initState() {
    super.initState();
    _updateReminderCountdown();
    _reminderTimer = Timer.periodic(const Duration(seconds: 1), (_) => _updateReminderCountdown());
  }

  void _updateReminderCountdown() async {
    final duration = await ReminderHelper.getTimeUntilNextReminder();
    _reminderTimeStrNotifier.value = ReminderHelper.formatDuration(duration);
  }

  @override
  @override
  void dispose() {
    _reminderTimer?.cancel();
    _reminderTimeStrNotifier.dispose();
    super.dispose();
  }
  // Countdown card widget (copied from Dashboard/Profile for consistency)
  Widget _countdownCard(String timeStr) {
    return Container(
      padding: EdgeInsets.all(5.w),
      decoration: BoxDecoration(
        color: const Color(0xFF3B73FF),
        borderRadius: BorderRadius.circular(5.w),
      ),
      child: SizedBox(
        height: 16.h,
        child: Row(
          children: [
            Expanded(
              flex: 50,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Next Check-in Due',
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Colors.white.withOpacity(.85),
                      fontWeight: FontWeight.w500,
                      letterSpacing: .3,
                    ),
                  ),
                  SizedBox(height: 1.5.h),
                  FittedBox(
                    child: Text(
                      timeStr,
                      style: TextStyle(
                        fontSize: 26.sp,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                  SizedBox(height: 1.5.h),
                  InkWell(
                    borderRadius: BorderRadius.circular(4.w),
                    onTap: () {
                      // TODO: Implement check-in logic
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 6.w,
                        vertical: 1.5.h,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6F98FF),
                        border: Border.all(color: Colors.white, width: 1.8),
                        borderRadius: BorderRadius.circular(4.w),
                      ),
                      child: Center(
                        child: Text(
                          'Check-In',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: .5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 5.w),
            Expanded(
              flex: 60,
              child: Align(
                alignment: Alignment.bottomRight,
                child: Image.asset(
                  'assets/images/check_pic.png',
                  fit: BoxFit.contain,
                  height: 20.h,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckInCard(BuildContext context) {
    // Match countdownCard padding, margin, and radius
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(5.w),
      margin: EdgeInsets.only(top: 0),
      decoration: BoxDecoration(
        color: const Color(0xFF377CFD),
        borderRadius: BorderRadius.circular(5.w),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.10),
            offset: Offset(0, 4),
            blurRadius: 12,
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 2.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4.w),
            ),
            child: InkWell(
              onTap: () {},
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.attach_file, color: Color(0xFF377CFD)),
                  SizedBox(width: 2.w),
                  Text(
                    "Upload Here",
                    style: TextStyle(
                      color: Color(0xFF377CFD),
                      fontWeight: FontWeight.bold,
                      fontSize: 16.sp,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 2.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4.w),
            ),
            child: TextField(
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: "Add Comment (optional)",
                hintStyle: TextStyle(fontSize: 14.sp, color: Colors.grey),
              ),
            ),
          ),
          SizedBox(height: 2.h),
          InkWell(
            borderRadius: BorderRadius.circular(4.w),
            onTap: () {
              // TODO: Implement check-in logic
            },
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                vertical: 1.5.h,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF6F98FF),
                border: Border.all(color: Colors.white, width: 1.8),
                borderRadius: BorderRadius.circular(4.w),
              ),
              child: Center(
                child: Text(
                  'Check-In',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: .5,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMembersHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 0.w, vertical: 1.h),
      child: Container(
        width: double.infinity,
        height: 3.h,
        decoration: BoxDecoration(
          color: Color(0xFF377CFD),
          borderRadius: BorderRadius.circular(2.w), // Added border radius
        ),
        alignment: Alignment.center,
        child: Text(
          "Members",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16.sp,
          ),
        ),
      ),
    );
  }

  Widget _buildMemberTile({
    required String name,
    required String status,
    required String statusType, // active, failed
    required String action,
    required Color statusColor,
    required Color actionColor,
    required String profileImage,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.0.h, horizontal: 0.w),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 1.0.h, horizontal: 2.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4.w),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 2,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 6.5.w,
              backgroundImage: AssetImage(profileImage),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.sp,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 5.w,
                      vertical: 0.2.h,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor,
                      border: Border.all(
                        color: Color(0xFF377CFD),
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(4.w),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        color: statusType == "active"
                            ? Color(0xFF2E8701)
                            : Color(0xFFC84E4F),
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 0.w),
            InkWell(
              onTap: () {},

              child: Container(
                width: 35.w,
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(vertical: 1.h, horizontal: 2.w),
                decoration: BoxDecoration(
                  color: actionColor,
                  borderRadius: BorderRadius.circular(3.w),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min, // Ensures content fits tightly
                  children: [
                    Text(
                      action,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15.sp,
                      ),
                    ),
                    SizedBox(width: 1.5.w),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 15.sp,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get pact title from arguments (Navigator push: arguments: {'title': ...})
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final pactTitle = args != null && args['title'] != null ? args['title'] as String : 'Pact';
    return Sizer(
      builder: (context, orientation, deviceType) {
        return Scaffold(
          extendBodyBehindAppBar: true,
          backgroundColor: const Color(0xFFF5F8FB),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            title: Text(
              pactTitle,
              style: TextStyle(
                color: Colors.black,
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          body: Stack(
            children: [
              Positioned.fill(
                child: Image.asset('assets/images/Blur.png', fit: BoxFit.cover),
              ),
              SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 5.w),
                  child: Column(
                    children: [
                      SizedBox(height: 12.h),
                      // Next Check-in Due widget with reminder countdown
                      ValueListenableBuilder(
                        valueListenable: _reminderTimeStrNotifier,
                        builder: (context, String timeStr, _) {
                          return _countdownCard(timeStr);
                        },
                      ),
                      SizedBox(height: 2.0.h),
                      _buildCheckInCard(context),
                      SizedBox(height: 2.4.h),
                      _buildMembersHeader(),
                      _buildMemberTile(
                        name: "Travis Scott",
                        status: "Active",
                        statusType: "active",
                        action: "Pending",
                        statusColor: Color(0xFF4AFFB3),
                        actionColor: Color(0xFF6CA8FF),
                        profileImage: 'assets/images/person1.jpg',
                      ),
                      _buildMemberTile(
                        name: "Virat Kohli",
                        status: "Active",
                        statusType: "active",
                        action: "Verified",
                        statusColor: Color(0xFF4AFFB3),
                        actionColor: Color(0xFF42D393),
                        profileImage: 'assets/images/person2.jpg',
                      ),
                      _buildMemberTile(
                        name: "Harsh Bhatt",
                        status: "Failed",
                        statusType: "failed",
                        action: "Failed",
                        statusColor: Color(0xFFFFA2A3),
                        actionColor: Color(0xFFF47272),
                        profileImage: 'assets/images/person3.jpg',
                      ),
                      SizedBox(height: 6.h),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}