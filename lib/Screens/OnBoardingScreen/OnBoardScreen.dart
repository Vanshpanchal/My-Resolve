import 'package:flutter/material.dart';
import 'package:myresolve/Screens/Main/HomeScreen.dart';
import 'package:sizer/sizer.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<_OnboardingData> _screens = [
    _OnboardingData(
      image: 'assets/images/Object 1.png',
      title: 'Achieve Goals\nTogether.',
      description:
      'Create pacts with friends or groups where your success depends on each other. When one falls, all are impacted—build real accountability.',
    ),
    _OnboardingData(
      image: 'assets/images/Object 3.png',
      title: 'Commit. Check-In.\nVerify.',
      description:
      'Set custom goals, submit proof, and verify each other’s progress. If one fails, the pact breaks. Stay consistent as a team.',
    ),
    _OnboardingData(
      image: 'assets/images/Object 2.png',
      title: 'Motivate. Track. Win\nTogether.',
      description:
      'Get group-based rewards, transparent progress dashboards, and a social push to keep going. Your resolve starts here.',
    ),
  ];

  void _nextPage() {
    if (_currentPage < _screens.length - 1) {
      _controller.nextPage(duration: const Duration(milliseconds: 400), curve: Curves.ease);
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const HomeScreen(),
        ),
      );
    }
  }

  void _skip() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const HomeScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _currentPage == _screens.length - 1;
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Background image
            Positioned.fill(
              child: Image.asset(
                'assets/images/Splash.png',
                fit: BoxFit.cover,
              ),
            ),
            // Main content
            Column(
              children: [
                Expanded(
                  child: PageView.builder(
                    controller: _controller,
                    itemCount: _screens.length,
                    onPageChanged: (i) => setState(() => _currentPage = i),
                    itemBuilder: (context, i) {
                      return _OnboardingPage(data: _screens[i]);
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: _skip,
                        child: Text(
                          isLast ? '' : 'Skip',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ),
                      _PageIndicator(
                        currentIndex: _currentPage,
                        count: _screens.length,
                      ),
                      InkWell(
                        onTap: _nextPage,
                        borderRadius: BorderRadius.circular(100),
                        child: Container(
                          width: 12.w,
                          height: 12.w,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.arrow_forward_ios_outlined,
                            color: const Color(0xFF5B9BFF),
                            size: 18.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingData {
  final String image;
  final String title;
  final String description;

  _OnboardingData({
    required this.image,
    required this.title,
    required this.description,
  });
}

class _OnboardingPage extends StatelessWidget {
  final _OnboardingData data;

  const _OnboardingPage({required this.data});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          children: [
            SizedBox(height: 8.h),
            SizedBox(
              height: 38.h,
              child: Image.asset(
                data.image,
                fit: BoxFit.contain,
              ),
            ),
            const Spacer(),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 6.w),
              child: Column(
                children: [
                  Text(
                    data.title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 24.sp,
                      color: Colors.white,
                      height: 1.2,
                      letterSpacing: -1.2,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    data.description,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.normal,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(flex: 2),
          ],
        );
      },
    );
  }
}

class _PageIndicator extends StatelessWidget {
  final int currentIndex;
  final int count;

  const _PageIndicator({required this.currentIndex, required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        count,
            (i) {
          final isActive = i == currentIndex;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: EdgeInsets.symmetric(horizontal: 1.w),
            width: isActive ? 6.w : 2.w,
            height: 2.w,
            decoration: BoxDecoration(
              color: isActive ? Colors.white : Colors.white.withOpacity(0.4),
              borderRadius: BorderRadius.circular(1.w),
            ),
          );
        },
      ),
    );
  }
}