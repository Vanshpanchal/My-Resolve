import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:myresolve/Screens/Authentication/Register.dart';
import 'package:myresolve/Screens/Main/HomeScreen.dart';
import 'package:myresolve/Screens/Main/Profile.dart';
import 'package:myresolve/Utils/Colors.dart';
import 'package:sizer/sizer.dart';

import 'Screens/Authentication/Login.dart';
void main() {
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
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
          initialRoute: '/main', // Set the initial route
          routes: {
            '/login': (context) => const LoginScreen(),
            '/register': (context) => const RegisterScreen(),
            '/main': (context) => const HomeScreen()            // Add other routes as needed
          },
        );
      },
    );
  }
}