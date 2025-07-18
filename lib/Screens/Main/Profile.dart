import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:myresolve/Utils/Colors.dart';
import 'package:sizer/sizer.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return Scaffold(
          backgroundColor: const Color(0xFFF5F8FB),
          body: Stack(
            children: [
              // Background color
              // Container(color: AppColors.background),
              // Main content
              // _buildProfileContent(context),
              Positioned.fill(
                child: Image.asset(
                  'assets/images/Blur.png', // Your image path
                  fit: BoxFit.cover,
                ),
              ),
              SafeArea(
                child: SingleChildScrollView(
                  child: Column(
                    // mainAxisSize: MainAxisSize.min,
                    children: [
                      // Blue wavy header background
                      Padding(
                        padding: EdgeInsets.symmetric(
                          // horizontal: 5.w,
                          vertical: 8.h,
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: 14.h, // diameter = 2 * radius
                              height: 14.h,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white, // Change color as needed
                                  width: 3, // Change width as needed
                                ),
                              ),
                              child: CircleAvatar(
                                radius: 7.h,
                                backgroundImage: const AssetImage(
                                  'assets/images/profile.jpg',
                                ),
                                backgroundColor: Colors.transparent, // optional
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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CustomSwitchTab(
                                  onTap: (index) {
                                    // Handle tab change
                                  },
                                ),
                              ],
                            ),
                            SizedBox(height: 3.h),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8.0,
                              ),
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
                                mainAxisAlignment:
                                MainAxisAlignment.start,
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
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceAround,
                                  children: [
                                    _certCard(
                                      '10 pact\nCompleted',
                                      'Bronze Certified',
                                      Color(0x33D0C6AA),
                                      Colors.grey.shade300,
                                      key: UniqueKey(),
                                    ),
                                    _certCard(
                                      '20 pact\nCompleted',
                                      'Silver Certified',
                                      Colors.grey.shade50,
                                      Colors.grey.shade300,
                                      key: UniqueKey(),
                                    ),_certCard(
                                      '20 pact\nCompleted',
                                      'Silver Certified',
                                      Colors.grey.shade50,
                                      Colors.grey.shade300,
                                      key: UniqueKey(),
                                    ),

                                  ],
                                ),
                              ),
                            ),

                            // SizedBox(height: 5.h),
                          ],
                          // ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // bottomNavigationBar: _bottomNavBar(),
        );
      },
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
                    // color: ,
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
          // SizedBox(height: 2.h),
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //   children: [
          //     CircleAvatar(
          //       radius: 1.7.h,
          //       backgroundColor: Colors.blue.shade100,
          //       child: Text(
          //         '2',
          //         style: TextStyle(
          //           color: Colors.blue,
          //           fontSize: 10.sp,
          //           fontWeight: FontWeight.bold,
          //         ),
          //       ),
          //     ),
          //     CircleAvatar(
          //       radius: 1.7.h,
          //       backgroundColor: Colors.blue.shade100,
          //       child: Text(
          //         '3',
          //         style: TextStyle(
          //           color: Colors.blue,
          //           fontSize: 10.sp,
          //           fontWeight: FontWeight.bold,
          //         ),
          //       ),
          //     ),
          //   ],
          // ),
        ],
      ),
    );
  }

  Widget _medalCard(String name,
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
          // CircleAvatar(
          //   radius: 3.0.h,
          //   backgroundColor: Colors.transparent,
          //   backgroundImage: AssetImage(path),
          // ),

          SvgPicture.asset(
            path,
            width: 2.h,
            height: 5.h,
          ),
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
              // color: colorhade200,
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

  Widget _certCard(String title,
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
            // color: iconColor,
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
              color: Color(0XFFDEE7FF),
              borderRadius: BorderRadius.circular(1.h),
            ),
            child: Text(
              subtitle,
              style: TextStyle(

                color: Color(0XFF346AD4),
                fontSize: 16.sp,
                // backgroundColor: bgColor,
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
  final int initialIndex;

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
        children: [_tabItem("ACTIVITY", 1), _tabItem("ACHIEVEMENTS", 0)],
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
          if (widget.onTap != null) widget.onTap!(index);
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
