import 'package:flutter/material.dart';
import 'package:myresolve/Screens/Main/Dashboard.dart';
import 'package:myresolve/Utils/PactFilterEnum.dart';
import 'package:sizer/sizer.dart';

class FilterBar extends StatelessWidget {
  final PactFilter current;
  final ValueChanged<PactFilter> onChanged;
  const FilterBar({super.key, required this.current, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final items = PactFilter.values;
    return Row(
      children: items.map((f) {
        final selected = f == current;
        final text = switch (f) {
          PactFilter.all => 'ALL',
          PactFilter.active => 'Active',
          PactFilter.failed => 'Failed',
          PactFilter.completed => 'Completed',
        };
        return Padding(
          padding: EdgeInsets.only(right: 4.w),
          child: GestureDetector(
            onTap: () => onChanged(f),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              padding: EdgeInsets.symmetric(
                horizontal: 3.5.w,
                vertical: 1.1.h,
              ),
              decoration: BoxDecoration(
                color: selected ? const Color(0xFF0B57D0) : Colors.transparent,
                borderRadius: BorderRadius.circular(2.w),
              ),
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 14.5.sp,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                  color: selected ? Colors.white : Colors.black,
                  letterSpacing: .5,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}