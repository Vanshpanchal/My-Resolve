import 'package:awesome_bottom_bar/awesome_bottom_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:myresolve/Screens/Main/Create.dart';
import 'package:myresolve/Screens/Main/Dashboard.dart';
import 'package:myresolve/Screens/Main/Profile.dart';
import 'package:myresolve/Screens/Main/Notification.dart';
import 'package:myresolve/Screens/Main/Feed.dart';
import 'package:myresolve/Utils/Colors.dart';
import 'package:myresolve/Utils/notification_provider.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selected = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selected);
    // Initialize notifications when app starts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
      notificationProvider.fetchNotifications();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  final List<Widget> screens = [
    const DashboardScreen(),
    const FeedScreen(),
    const CreateScreen(),
    const NotificationScreen(),
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
    return Consumer<NotificationProvider>(
      builder: (context, notificationProvider, child) {
        final List<TabItem> items = [
          TabItem(icon: CupertinoIcons.square_grid_2x2, title: ''),
          TabItem(icon: CupertinoIcons.doc_text, title: ''),
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
        return PopScope(
          canPop: false,
          onPopInvoked: (didPop) async {
            if (didPop) return;
            
            // If we're on the dashboard (index 0), close the app
            if (_selected == 0) {
              SystemNavigator.pop();
            } else {
              // Otherwise, navigate to dashboard
              setState(() {
                _selected = 0;
              });
              _pageController.jumpToPage(0);
            }
          },
          child: Scaffold(
            extendBody: true, // ✅ content under bottom nav
            backgroundColor: const Color(0xFFF5F8FB),
            body: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _selected = index;
                });
              },
              children: screens,
            ),
            bottomNavigationBar: Stack(
            children: [
              BottomBarCreative(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
                items: items,
                backgroundColor: Colors.white,
                indexSelected: _selected,
                iconSize: 28,
                color: Colors.grey.shade400,
                colorSelected: AppColors.lightBlue,
                onTap: (index) {
                  setState(() => _selected = index);
                  _pageController.jumpToPage(index);
                },
              ),
              // Notification badge
              if (notificationProvider.unreadCount > 0)
                Positioned(
                  top: 10,
                  left: MediaQuery.of(context).size.width * 0.75 - 22, // Position over bell icon
                  child: Container(
                    padding: EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: AppColors.lightBlue,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    constraints: BoxConstraints(
                      minWidth: 20,
                      minHeight: 20,
                    ),
                    child: Text(
                      '${notificationProvider.unreadCount > 99 ? '99+' : notificationProvider.unreadCount}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          ),
        );
      },
    );
      },
    );
  }
}
