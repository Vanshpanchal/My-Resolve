import 'package:awesome_bottom_bar/awesome_bottom_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
    Center(
      child: Text('Home', style: TextStyle(fontSize: 18.sp)),
    ),
    Center(
      child: Text('Book', style: TextStyle(fontSize: 18.sp)),
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
    return Sizer(
      builder: (context, orientation, deviceType) {
        return Scaffold(
          backgroundColor: Colors.grey.shade100,
          body: SafeArea(child: screens[_selected]),
          bottomNavigationBar: BottomBarCreative(
            borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
            items: items,
            backgroundColor: Colors.white,
            // borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            // blurRadius: 8,
            // curve: Curves.easeInOut,
            // animated: true,
            indexSelected: _selected,
            // elevation: 8,
            iconSize: 28,
            // tabStyle: TabStyle.creative, // <-- Creative type!
            color: Colors.grey.shade400,
            // selectedColor: Colors.blue.shade600,
            onTap: (index) {
              setState(() {
                _selected = index;
              });
            },

            colorSelected: AppColors.lightBlue,
          ),
        );
      },
    );
  }
}
