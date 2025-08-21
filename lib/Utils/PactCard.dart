import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:myresolve/Screens/Main/Dashboard.dart';
import 'package:myresolve/Utils/PactCardModel.dart';
import 'package:myresolve/Utils/PactStatusEnum.dart';
import 'package:sizer/sizer.dart';

class PactCard extends StatelessWidget {
  final Pact pact;
  const PactCard({super.key, required this.pact});

  Color get statusColor {
    switch (pact.status) {
      case PactStatus.wasted:
        return const Color(0xFFE30000);
      case PactStatus.completed:
        return const Color(0xFF0B7D32);
      case PactStatus.active:
      default:
        return const Color(0xFF0B57D0);
    }
  }

  String get statusText {
    switch (pact.status) {
      case PactStatus.wasted:
        return 'Failed';
      case PactStatus.completed:
        return 'Gained';
      case PactStatus.completed:
        return 'Completed';
      case PactStatus.active:
      default:
        return '${pact.days} Days';
    }
  }

  bool get showProgress => pact.status == PactStatus.active;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 15.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5.w),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.05),
            blurRadius: 12,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
      child: Row(
        children: [
          Container(
            width: 12.w,
            height: 12.w,
            decoration: BoxDecoration(
              color: const Color(0xFFE9F1FF),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.groups_rounded,
              color: const Color(0xFF0B57D0),
              size: 6.w,
            ),
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pact.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.5.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: .6.h),
                Text(
                  'Created by ${pact.creator}',
                  style: TextStyle(
                    fontSize: 9.5.sp,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: .3.h),
                Text(
                  'At ${_formatDate(pact.createdAt)}',
                  style: TextStyle(
                    fontSize: 9.5.sp,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 3.w),
          showProgress
              ? DaysProgress(
            size: 17.w,
            days: pact.days,
            color: statusColor,
          )
              : StatusBadge(
            color: statusColor,
            text: statusText,
            diameter: 17.w,
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime d) {
    const months = [
      'jan','feb','mar','apr','may','jun','jul','aug','sep','oct','nov','dec'
    ];
    return '${d.day}${_suffix(d.day)} ${months[d.month - 1]} ${d.year}';
  }

  String _suffix(int day) {
    if (day >= 11 && day <= 13) return 'th';
    switch (day % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }
}

class StatusBadge extends StatelessWidget {
  final Color color;
  final String text;
  final double diameter;
  const StatusBadge({
    super.key,
    required this.color,
    required this.text,
    required this.diameter,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            color.withOpacity(.85),
            color,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(.35),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Padding(
        padding: EdgeInsets.all(1.w),
        child: FittedBox(
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 8.7.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class DaysProgress extends StatelessWidget {
  final int days;
  final double size;
  final Color color;
  const DaysProgress({
    super.key,
    required this.days,
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final progress = ((days % 100) / 100).clamp(0.05, 0.95);
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _CirclePainter(
              progress: progress,
              color: color,
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FittedBox(
                child: Text(
                  '$days',
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
              ),
              Text(
                'Days',
                style: TextStyle(
                  fontSize: 7.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CirclePainter extends CustomPainter {
  final double progress;
  final Color color;
  _CirclePainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.width * 0.12;
    final rect = Offset.zero & size;
    final bg = Paint()
      ..color = color.withOpacity(.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    final fg = Paint()
      ..shader = LinearGradient(
        colors: [color.withOpacity(.4), color],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    final center = size.center(Offset.zero);
    final radius = (size.width - stroke) / 2;
    canvas.drawCircle(center, radius, bg);

    final sweep = 2 * math.pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweep,
      false,
      fg,
    );
  }

  @override
  bool shouldRepaint(covariant _CirclePainter old) =>
      old.progress != progress || old.color != color;
}