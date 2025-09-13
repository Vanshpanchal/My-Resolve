import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:myresolve/Screens/Authentication/Register.dart';
import 'package:myresolve/Screens/Main/HomeScreen.dart';
import 'package:myresolve/Screens/OnBoardingScreen/OnBoardScreen.dart';
import 'package:myresolve/Screens/SplashScreen.dart';
import 'package:myresolve/Utils/Colors.dart';
import 'package:myresolve/Utils/auth_provider.dart';
import 'package:myresolve/Utils/user_model.dart' hide UserModel, UserModelAdapter;
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import 'Screens/Authentication/Login.dart';

import 'package:hive_flutter/hive_flutter.dart';
import 'Utils/user_model.dart';
import 'package:myresolve/Utils/pact_provider.dart';

void main() {
  // SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.top]); // Shows only status bar
  // SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
  //   statusBarColor: Colors.green,
  //   statusBarIconBrightness: Brightness.light,
  // ));
  // FlutterNativeSplash.remove();
  WidgetsFlutterBinding.ensureInitialized();
  _initHive().then((_) {
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => PactProvider()),
        ],
        child: const MyApp(),
      ),
    );
    configLoading();
  });
}

Future<void> _initHive() async {
  await Hive.initFlutter();
  Hive.registerAdapter(UserModelAdapter());
  await Hive.openBox<UserModel>('userBox');
}

void configLoading() {
  EasyLoading.instance
    ..indicatorType = EasyLoadingIndicatorType.fadingCircle
    ..loadingStyle = EasyLoadingStyle.custom
    ..indicatorSize = 45.0
    ..radius = 12.0
    ..backgroundColor = Colors.white
    ..indicatorColor = AppColors.mainColor
    ..textColor = AppColors.mainColor
    ..maskColor = AppColors.mainColor.withOpacity(0.15)
    ..progressColor = AppColors.mainColor
    ..boxShadow = [
      BoxShadow(
        color: AppColors.mainColor.withOpacity(0.08),
        blurRadius: 16,
        offset: const Offset(0, 8),
      ),
    ]
    ..userInteractions = false
    ..dismissOnTap = false;
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return Sizer(
          builder: (context, orientation, deviceType) {
            return MaterialApp(
              builder: EasyLoading.init(),
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
              routes: {
                '/splash': (context) => const SplashScreen(),
                '/onboarding': (context) => const OnboardingScreen(),
                '/login': (context) => const LoginScreen(),
                '/register': (context) => const RegisterScreen(),
                '/main': (context) => const HomeScreen(),
              },
            );
          },
        );
      },
    );
  }
}
