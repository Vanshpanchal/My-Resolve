import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:myresolve/Screens/Main/Dashboard.dart';
import 'package:myresolve/Screens/Main/PactDetail.dart';
import 'package:myresolve/Utils/FilterBar.dart';
import 'package:myresolve/Utils/PactCardModel.dart';
import 'package:myresolve/Utils/PactFilterEnum.dart';
import 'package:myresolve/Utils/PactStatusEnum.dart';
import 'package:myresolve/Utils/StatsCard.dart';
import 'package:sizer/sizer.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Duration remaining = const Duration(hours: 12, minutes: 10, seconds: 32);
  Timer? timer;
  PactFilter currentFilter = PactFilter.all;

  // NOTE: Assuming Pact.days represents how many days have been completed so far.
  // If you also have a "target / total" days count, replace the hard‑coded
  // totalDays logic below with the real field.
  final List<Pact> pacts = [
    Pact(
      title: 'Fitness Pact',
      creator: 'Virat Kohli',
      createdAt: DateTime(2025, 7, 18),
      days: 70,
      status: PactStatus.active,
    ),
    Pact(
      title: 'No Social Media Pact',
      creator: 'Virat Kohli',
      createdAt: DateTime(2025, 7, 18),
      days: 12,
      status: PactStatus.wasted,
    ),
    Pact(
      title: 'No Social Media Pact',
      creator: 'Virat Kohli',
      createdAt: DateTime(2025, 7, 18),
      days: 45,
      status: PactStatus.completed,
    ),
  ];

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        remaining -= const Duration(seconds: 1);
        if (remaining.isNegative) remaining = Duration.zero;
      });
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  bool _isFailed(Pact p) => p.status == PactStatus.wasted;
  bool _isCompleted(Pact p) => p.status == PactStatus.completed;

  List<Pact> get filteredPacts {
    switch (currentFilter) {
      case PactFilter.active:
        return pacts.where((p) => p.status == PactStatus.active).toList();
      case PactFilter.failed:
        return pacts.where(_isFailed).toList();
      case PactFilter.completed:
        return pacts.where(_isCompleted).toList();
      case PactFilter.all:
      default:
        return pacts;
    }
  }

  String _two(int n) => n.toString().padLeft(2, '0');

  String statusTextFor(PactStatus status) {
    switch (status) {
      case PactStatus.active:
        return 'Active';
      case PactStatus.completed:
        return 'Done';
      case PactStatus.wasted:
        return 'Failed';
    }
  }

  // Provide an estimated "total days" for active pacts (for progress ring).
  // Replace with actual business logic / model field if available.
  int totalDaysFor(Pact pact) {
    // Example heuristic: assume a 90-day target for active pacts
    if (pact.status == PactStatus.active) return 90;
    return pact.days; // For completed/failed we show full circle anyway
  }

  @override
  Widget build(BuildContext context) {
    final timeStr =
        '${_two(remaining.inHours)} : ${_two(remaining.inMinutes % 60)} : ${_two(remaining.inSeconds % 60)}';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FB),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/images/Blur.png', fit: BoxFit.cover),
          ),
          SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: SizedBox(height: 2.2.h)),
                SliverToBoxAdapter(child: _header()),
                SliverToBoxAdapter(child: SizedBox(height: 2.0.h)),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 5.w),
                    child: _countdownCard(timeStr),
                  ),
                ),
                SliverToBoxAdapter(child: SizedBox(height: 2.4.h)),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 5.w),
                    child: Row(
                      children: [
                        Expanded(
                          child: StatCard(
                            value: '12',
                            label: 'Active Pacts',
                            illustration: 'assets/images/pact.png',
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: StatCard(
                            value: '32',
                            label: 'Current Streak',
                            illustration: 'assets/images/streak.png',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(child: SizedBox(height: 3.h)),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 5.w),
                    child: FilterBar(
                      current: currentFilter,
                      onChanged: (f) => setState(() => currentFilter = f),
                    ),
                  ),
                ),
                SliverToBoxAdapter(child: SizedBox(height: 1.2.h)),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, i) {
                      final pact = filteredPacts[i];
                      return PactCardProfile(
                        title: pact.title,
                        createdBy: pact.creator,
                        createdDate: DateFormat('dd MMM yyyy').format(pact.createdAt),
                        status: pact.status,
                        statusText: statusTextFor(pact.status),
                        completedDays: pact.status == PactStatus.active ? pact.days : null,
                        totalDays: pact.status == PactStatus.active ? totalDaysFor(pact) : null,
                      );
                    },
                    childCount: filteredPacts.length,
                  ),
                ),
                SliverToBoxAdapter(child: SizedBox(height: 4.h)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _header() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 5.w),
      child: Row(
        children: [
          Container(
            width: 13.w,
            height: 13.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: const DecorationImage(
                image: AssetImage('assets/images/profile.jpg'),
                fit: BoxFit.cover,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 19.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                    children: [
                      const TextSpan(text: 'Hi, '),
                      const TextSpan(
                        text: 'Travis',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                      TextSpan(
                        text: ' 👋',
                        style: TextStyle(fontSize: 18.sp),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: .6.h),
                Text(
                  "Here's your accountability progress today.",
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

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
}

/* ================== New Pact Card Design (Profile style) ================== */

class PactCardProfile extends StatelessWidget {
  final String title;
  final String createdBy;
  final String createdDate;
  final PactStatus status;
  final String statusText;
  final int? completedDays;
  final int? totalDays;

  const PactCardProfile({
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
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PactDetailScreen(), // Replace with actual detail screen
                ),
              );
            },
            child: Container(
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
    }
  }

  @override
  Widget build(BuildContext context) {
    double badgeSize = 18.w;
    double progress = 0.0;
    if (status == PactStatus.active &&
        completedDays != null &&
        totalDays != null &&
        totalDays != 0) {
      progress = (completedDays! / totalDays!).clamp(0.0, 1.0);
    }
    if (status == PactStatus.completed || status == PactStatus.wasted) {
      progress = 1.0;
    }

    return SizedBox(
      width: badgeSize,
      height: badgeSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
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
            child: status == PactStatus.active &&
                completedDays != null &&
                totalDays != null
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
                  style:
                  TextStyle(color: Colors.white, fontSize: 14.sp),
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
  final double progress;
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

    final bgPaint = Paint()
      ..color = Colors.grey.shade200
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, bgPaint);

    final progressPaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * 3.1415926535 * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -3.1415926535 / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}