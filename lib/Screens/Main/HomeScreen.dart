import 'package:awesome_bottom_bar/awesome_bottom_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:myresolve/Screens/Main/Dashboard.dart';
import 'package:myresolve/Screens/Main/Profile.dart';
import 'package:myresolve/Utils/Colors.dart';
import 'package:sizer/sizer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selected = 0;

  final List<TabItem> items = [
    TabItem(icon: CupertinoIcons.square_grid_2x2, title: ''),
    TabItem(icon: CupertinoIcons.book, title: ''),
    TabItem(icon: CupertinoIcons.add_circled, title: ''),
    TabItem(icon: CupertinoIcons.bell, title: ''),
    TabItem(icon: CupertinoIcons.person, title: ''),
  ];

  final List<Widget> screens = [
    DashboardScreen(),
    Center(
      child: Text('Home', style: TextStyle(fontSize: 18.sp)),
    ),
    Center(
      child: Text('Add', style: TextStyle(fontSize: 18.sp)),
    ),
    Center(
      child: Text('Alerts', style: TextStyle(fontSize: 18.sp)),
    ),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    // Set status bar color to green and icons to light
    // SystemChrome.setSystemUIOverlayStyle(
    //   const SystemUiOverlayStyle(
    //     statusBarColor: Colors.blue,
    //     statusBarIconBrightness: Brightness.dark,
    //     // For Android 15 edge-to-edge, you may want to also set:
    //     systemNavigationBarColor: Colors.white,
    //     systemNavigationBarIconBrightness: Brightness.dark,
    //   ),
    // );

    return Sizer(
      builder: (context, orientation, deviceType) {
        return Scaffold(
          backgroundColor: const Color(0xFFF5F8FB),

          body: SafeArea(
            child: screens[_selected],
          ),
          bottomNavigationBar: BottomBarCreative(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
            items: items,
            backgroundColor: Colors.white,
            indexSelected: _selected,
            iconSize: 28,
            color: Colors.grey.shade400,
            colorSelected: AppColors.lightBlue,
            onTap: (index) {
              setState(() {
                _selected = index;
              });
            },
          ),
        );
      },
    );
  }
}