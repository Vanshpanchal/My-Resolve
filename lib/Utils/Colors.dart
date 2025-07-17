import 'dart:ui';

import 'package:flutter/material.dart';

class AppColors {

  static const Color buttonBlue = Color(0xFF1D61E7);
  static const Color information = Color(0xFF4D81E7);
  static const Color background = Color(0xFFF5F5F5);
  static const int _lightBluePrimaryValue = 0xFF1D61E7;

  static const MaterialColor mainColor = MaterialColor(_lightBluePrimaryValue, <int, Color>{
    50: Color(0xFFE1F5FE),
    100: Color(0xFFB3E5FC),
    200: Color(0xFF81D4FA),
    300: Color(0xFF4FC3F7),
    400: Color(0xFF29B6F6),
    500: Color(_lightBluePrimaryValue),
    600: Color(0xFF039BE5),
    700: Color(0xFF0288D1),
    800: Color(0xFF0277BD),
    900: Color(0xFF01579B),
  });
}