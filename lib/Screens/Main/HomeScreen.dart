import 'package:awesome_bottom_bar/awesome_bottom_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:myresolve/Screens/Main/Create.dart';
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

  final List<Widget> screens = [
    const DashboardScreen(),
    Center(child: Text('Home', style: TextStyle(fontSize: 18))),
    const CreateScreen(),
    Center(child: Text('Alerts', style: TextStyle(fontSize: 18))),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    // ✅ Transparent status + nav bar
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
      statusBarIconBrightness: Brightness.dark,
    ));

    // ✅ Build bottom bar items dynamically so we can switch icons
    final List<TabItem> items = [
      TabItem(icon: CupertinoIcons.square_grid_2x2, title: ''),
      TabItem(icon: CupertinoIcons.book, title: ''),
      TabItem(
        icon: _selected == 2
            ? CupertinoIcons.add_circled_solid // when Create is active
            : CupertinoIcons.add_circled, // default
        title: '',
      ),
      TabItem(icon: CupertinoIcons.bell, title: ''),
      TabItem(icon: CupertinoIcons.person, title: ''),
    ];

    return Sizer(
      builder: (context, orientation, deviceType) {
        return Scaffold(
          extendBody: true, // ✅ content under bottom nav
          backgroundColor: const Color(0xFFF5F8FB),
          body: screens[_selected],
          bottomNavigationBar: BottomBarCreative(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
            items: items,
            backgroundColor: Colors.white,
            indexSelected: _selected,
            iconSize: 28,
            color: Colors.grey.shade400,
            colorSelected: AppColors.lightBlue,
            onTap: (index) {
              setState(() => _selected = index);
            },
          ),
        );
      },
    );
  }
}
