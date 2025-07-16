import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import 'Screens/Authentication/Login.dart';
void main() {
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
            primarySwatch: Colors.blue,
            fontFamily: 'Inter',
          ),
          home: const LoginScreen(),
        );
      },
    );
  }
}