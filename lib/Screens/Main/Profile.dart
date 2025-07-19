// import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:myresolve/Utils/Colors.dart';
import 'package:sizer/sizer.dart';
// ... Your other imports

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int selectedTabIndex = 1; // 1 = ACTIVITY, 0 = ACHIEVEMENTS

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return Scaffold(
          backgroundColor: const Color(0xFFF5F8FB),
          body: Stack(
            children: [
              Positioned.fill(
                child: Image.asset('assets/images/Blur.png', fit: BoxFit.cover),
              ),
              SafeArea(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.h),
                        child: Column(
                          children: [
                            // ... Profile image and name
                            Container(
                              width: 14.h,
                              height: 14.h,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 3,
                                ),
                              ),
                              child: CircleAvatar(
                                radius: 7.h,
                                backgroundImage: const AssetImage(
                                  'assets/images/profile.jpg',
                                ),
                                backgroundColor: Colors.transparent,
                              ),
                            ),
                            SizedBox(height: 1.5.h),
                            Text(
                              'Virat Kohli',
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 3.h),
                            // Pass selectedTabIndex and onTap callback
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CustomSwitchTab(
                                  initialIndex: selectedTabIndex,
                                  onTap: (index) {
                                    setState(() {
                                      selectedTabIndex = index;
                                    });
                                  },
                                ),
                              ],
                            ),
                            SizedBox(height: 0.h),
                          ],
                        ),
                      ),
                      // Switch content based on selectedTabIndex
                      selectedTabIndex == 0
                          ? _buildActivityTab()
                          : _buildAchievementsTab(),
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

  // Activity Tab - Show pact list
  Widget _buildActivityTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PactCard(
          title: 'Fitness Pact',
          createdBy: 'Virat Kohli',
          createdDate: '18th July 2025',
          status: PactStatus.active,
          statusText: '',
          completedDays: 70,
          totalDays: 100,
        ),
        PactCard(
          title: 'No Social Media Pact',
          createdBy: 'Virat Kohli',
          createdDate: '18th July 2025',
          status: PactStatus.completed,
          statusText: 'GAINED',
          completedDays: 100,
          totalDays: 100,
        ),
        PactCard(
          title: 'No Social Media Pact',
          createdBy: 'Virat Kohli',
          createdDate: '18th July 2025',
          status: PactStatus.wasted,
          statusText: 'FAILED',
          completedDays: 100,
          totalDays: 100,
        ),
      ],
    );
  }

  Widget _buildAchievementsTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: _levelCard(),
        ),
        SizedBox(height: 3.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 3.w),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'MEDALS',
              style: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.bold,
                fontSize: 16.sp,
              ),
            ),
          ),
        ),
        SizedBox(height: 2.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 3.w),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _medalCard(
                'Gold',
                Colors.amber,
                '24',
                Colors.amber.shade50,
                "assets/images/Gold.svg",
                key: UniqueKey(),
              ),
              _medalCard(
                'Silver',
                Colors.grey,
                '18',
                Colors.grey.shade50,
                "assets/images/Silver.svg",
                key: UniqueKey(),
              ),
              _medalCard(
                'Bronze',
                Colors.brown.shade300,
                '11',
                Colors.brown.shade50,
                "assets/images/Bronze.svg",
                key: UniqueKey(),
              ),
            ],
          ),
        ),
        SizedBox(height: 3.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 3.w),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'CERTIFICATIONS',
              style: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.bold,
                fontSize: 16.sp,
              ),
            ),
          ),
        ),
        SizedBox(height: 2.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 3.w),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _certCard(
                  '10 pact\nCompleted',
                  'CERTIFIED',
                  Color(0x33D0C6AA),
                  Colors.grey.shade300,
                  key: UniqueKey(),
                ),
                _certCard(
                  '20 pact\nCompleted',
                  'CERTIFIED',
                  Colors.grey.shade50,
                  Colors.grey.shade300,
                  key: UniqueKey(),
                ),
                _certCard(
                  '30 pact\nCompleted',
                  'CERTIFIED',
                  Colors.grey.shade50,
                  Colors.grey.shade300,
                  key: UniqueKey(),
                ),
              ],

            ),
          ),
        ),
        SizedBox(height: 3.h),
      ],
    );
  }

  Widget _levelCard() {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(2.h),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 1.h,
            offset: Offset(0, 0.5.h),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 2.5.h,
                backgroundColor: Colors.blue.shade100,
                child: Text(
                  '2',
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                    fontSize: 17.sp,
                  ),
                ),
              ),
              SizedBox(width: 2.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Level 2',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18.sp,
                    ),
                  ),
                  Text(
                    '500 Points to next level',
                    style: TextStyle(color: Colors.grey, fontSize: 16.sp),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Stack(
            children: [
              Container(
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(2.h),
                ),
              ),
              FractionallySizedBox(
                widthFactor: 5200 / 6000,
                child: Container(
                  height: 4.h,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade300, Colors.blue.shade600],
                    ),
                    borderRadius: BorderRadius.circular(2.h),
                  ),
                ),
              ),
              Positioned.fill(
                child: Center(
                  child: Text(
                    '★ 5200/6000',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16.sp,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _medalCard(
    String name,
    Color color,
    String count,
    Color TextBg,
    String path, {
    Key? key,
  }) {
    return Container(
      key: key,
      width: 25.w,
      margin: EdgeInsets.only(right: 5.w),
      padding: EdgeInsets.only(top: 0.5.h, bottom: 1.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(3.5.h),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 1.h,
            offset: Offset(0, 0.5.h),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 1.h),
          SvgPicture.asset(path, width: 2.h, height: 5.h),
          SizedBox(height: 1.5.h),
          Text(
            name,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 17.sp,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 0.5.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.8.h),
            decoration: BoxDecoration(
              color: TextBg,
              borderRadius: BorderRadius.circular(1.h),
            ),
            child: Text(
              count,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.sp,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _certCard(
    String title,
    String subtitle,
    Color iconColor,
    Color bgColor, {
    Key? key,
  }) {
    return Container(
      key: key,
      width: 35.w,
      height: 22.h,
      margin: EdgeInsets.only(right: 5.w),
      padding: EdgeInsets.symmetric(vertical: 1.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(3.5.h),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 1.h,
            offset: Offset(0, 0.5.h),
          ),
        ],
      ),
      child: Column(
        children: [
          SvgPicture.asset(
            'assets/images/Medallions.svg',
            width: 0.h,
            height: 9.h,
          ),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
          ),
          SizedBox(height: 0.5.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
            decoration: BoxDecoration(
              color: const Color(0XFFDEE7FF),
              borderRadius: BorderRadius.circular(1.h),
            ),
            child: Text(
              subtitle,
              style: TextStyle(
                color: const Color(0XFF346AD4),
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CustomSwitchTab extends StatefulWidget {
  final Function(int selectedIndex)? onTap;
  final int initialIndex; // Add initialIndex to control which tab is selected

  const CustomSwitchTab({super.key, this.onTap, this.initialIndex = 0});

  @override
  State<CustomSwitchTab> createState() => _CustomSwitchTabState();
}

class _CustomSwitchTabState extends State<CustomSwitchTab> {
  late int selectedIndex;

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60.w,
      height: 4.0.h,
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        border: Border.all(color: Colors.blue.shade200, width: 0.2.w),
        borderRadius: BorderRadius.circular(1.5.h),
      ),
      child: Row(
        // Note: The order here (ACTIVITY then ACHIEVEMENTS) determines their visual position
        // and corresponds to the index passed to _tabItem.
        // ACTIVITY is index 0, ACHIEVEMENTS is index 1.
        children: [_tabItem("ACHIEVEMENTS", 1),_tabItem("ACTIVITY", 0), ],
      ),
    );
  }

  Widget _tabItem(String label, int index) {
    bool selected = selectedIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedIndex = index;
          });
          if (widget.onTap != null) {
            widget.onTap!(index); // Pass the selected index back to the parent
          }
        },
        child: Container(
          decoration: BoxDecoration(
            color: selected ? Colors.blue : Colors.transparent,
            borderRadius: BorderRadius.circular(1.5.h),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: selected ? Colors.white : Colors.black,
              fontSize: 15.sp,
              letterSpacing: 1,
            ),
          ),
        ),
      ),
    );
  }
}
enum PactStatus { active, completed, wasted }

class PactCard extends StatelessWidget {
  final String title;
  final String createdBy;
  final String createdDate;
  final PactStatus status;
  final String statusText;
  final int? completedDays;
  final int? totalDays;

  const PactCard({
    Key? key,
    required this.title,
    required this.createdBy,
    required this.createdDate,
    required this.status,
    required this.statusText,
    this.completedDays,
    this.totalDays,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.5.h, horizontal: 5.w),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            margin: EdgeInsets.only(bottom: 2.w),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(3.w),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.07),
                  blurRadius: 2.w,
                  spreadRadius: 0.5.w,
                  offset: Offset(0, 1.5.w),
                ),
              ],
            ),
            padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 3.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.5.sp,
                  ),
                ),
                SizedBox(height: 1.h),
                Text(
                  'Created by $createdBy',
                  style: TextStyle(color: Colors.grey[600], fontSize: 15.sp),
                ),
                Text(
                  'At $createdDate',
                  style: TextStyle(color: Colors.grey[500], fontSize: 14.sp),
                ),
              ],
            ),
          ),
          Positioned(
            top: -3.h,
            right: -3.w,
            child: PactStatusBadge(
              status: status,
              statusText: statusText,
              completedDays: completedDays,
              totalDays: totalDays,
            ),
          ),
        ],
      ),
    );
  }
}

class PactStatusBadge extends StatelessWidget {
  final PactStatus status;
  final String statusText;
  final int? completedDays;
  final int? totalDays;

  const PactStatusBadge({
    Key? key,
    required this.status,
    required this.statusText,
    this.completedDays,
    this.totalDays,
  }) : super(key: key);

  Color getBadgeColor() {
    switch (status) {
      case PactStatus.active:
        return Colors.blue;
      case PactStatus.completed:
        return Colors.green;
      case PactStatus.wasted:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    double badgeSize = 18.w;
    double progress = 0.0;

    // Calculate progress if status is active
    if (status == PactStatus.active && completedDays != null && totalDays != null && totalDays != 0) {
      progress = (completedDays! / totalDays!).clamp(0.0, 1.0);
    }
    // For completed/wasted, always show full progress
    if (status == PactStatus.completed || status == PactStatus.wasted) {
      progress = 1.0;
    }

    return SizedBox(
      width: badgeSize,
      height: badgeSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer progress arc
          SizedBox(
            width: badgeSize,
            height: badgeSize,
            child: CustomPaint(
              painter: CircleProgressPainter(
                progress: progress,
                color: getBadgeColor(),
                strokeWidth: 2.2.w,
              ),
            ),
          ),
          // Main badge content
          Container(
            width: badgeSize - 4.w,
            height: badgeSize - 4.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: getBadgeColor(),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 2.5.w,
                  spreadRadius: 0.5.w,
                ),
              ],
            ),
            alignment: Alignment.center,
            child: status == PactStatus.active && completedDays != null && totalDays != null
                ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "$completedDays",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 17.sp,
                  ),
                ),
                Text(
                  "Days",
                  style: TextStyle(color: Colors.white, fontSize: 14.sp),
                ),
              ],
            )
                : Center(
              child: Text(
                statusText,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16.sp,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CircleProgressPainter extends CustomPainter {
  final double progress; // from 0.0 to 1.0
  final Color color;
  final double strokeWidth;

  CircleProgressPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - strokeWidth / 2;

    // Background arc (greyed)
    final bgPaint = Paint()
      ..color = AppColors.background
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    double sweepAngle = 2 * 3.1415926535 * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -3.1415926535 / 2, // Start at top
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}