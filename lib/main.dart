import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:myresolve/Screens/Authentication/Register.dart';
import 'package:myresolve/Screens/Main/HomeScreen.dart';
import 'package:myresolve/Screens/OnBoardingScreen/OnBoardScreen.dart';
import 'package:myresolve/Screens/SplashScreen.dart';
import 'package:myresolve/Utils/Colors.dart';
import 'package:sizer/sizer.dart';

import 'Screens/Authentication/Login.dart';

void main() {
  // SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.top]); // Shows only status bar
  // SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
  //   statusBarColor: Colors.green,
  //   statusBarIconBrightness: Brightness.light,
  // ));
  // FlutterNativeSplash.remove();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {

    return Sizer(
      builder: (context, orientation, deviceType) {
        return MaterialApp(

          debugShowCheckedModeBanner: false,
          title: 'My Resolve',
          theme: ThemeData(
            textSelectionTheme: const TextSelectionThemeData(
              cursorColor: AppColors.mainColor,
            ),
            primarySwatch: AppColors.mainColor,


            fontFamily: 'Inter',
          ),
          initialRoute: '/splash',
          // Set the initial route
          routes: {
            '/splash': (context) => const SplashScreen(),
            '/onboarding': (context) => const OnboardingScreen(),
            '/login': (context) => const LoginScreen(),
            '/register': (context) => const RegisterScreen(),
            '/main': (context) => const HomeScreen(),
            // Add other routes as needed
          },
        );
      },
    );
  }
}
