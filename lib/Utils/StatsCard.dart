import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class StatCard extends StatelessWidget {
  final String value;
  final String label;
  final String illustration;
  const StatCard({
    super.key,
    required this.value,
    required this.label,
    required this.illustration,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 16.h,
      padding: EdgeInsets.symmetric(vertical : 1.5.w, horizontal: 2.w),
      decoration: BoxDecoration(

        color: Color(0xFF3B73FF), // light gray background
        borderRadius: BorderRadius.circular(5.w),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.05),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        // fit: StackFit.expand,
        children: [
          Image.asset(
            illustration,
            // height: 10.h,
            width: 14.5.h,
            // fit: BoxFit.contain,
          ),

          // Text overlay at bottom
          SizedBox(height: 1.w,),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.all(0), // adjust spacing from bottom
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 17.sp,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,

                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(width: 1.w),
                  Flexible(
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color:Colors.white,
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis, // prevents overflow
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

    );
  }
}