import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:luneva_application/screens/dashboard_screen.dart';
import 'package:luneva_application/screens/login_screen.dart';
import 'package:luneva_application/screens/signup_screen.dart';
import 'package:luneva_application/screens/splash_screen.dart';
import 'package:luneva_application/screens/onboarding/onboarding_screen.dart'; 
import 'package:luneva_application/screens/diet/diet_planner_screen.dart';
import 'package:luneva_application/screens/trainer/physical_trainer_screen.dart';
import 'package:luneva_application/screens/stress/stress_handler_screen.dart';
import 'package:luneva_application/theme/app_theme.dart';
import 'package:luneva_application/theme/app_theme_dark.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const LunevaApp());
}

class LunevaApp extends StatelessWidget {
  const LunevaApp({super.key});

  static final ValueNotifier<ThemeData> themeNotifier =
      ValueNotifier(AppTheme.lightTheme);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeData>(
      valueListenable: themeNotifier,
      builder: (_, theme, __) {
        return MaterialApp(
          title: 'Luneva',
          debugShowCheckedModeBanner: false,
          theme: theme,
          initialRoute: '/',
          routes: {
            '/': (ctx) => const SplashScreen(),
            '/login': (ctx) => const LoginScreen(),
            '/signup': (ctx) => const SignUpScreen(),
            '/onboarding': (ctx) => const OnboardingScreen(), 
            '/dashboard': (ctx) => const DashboardScreen(),
            '/diet': (ctx) => const DietPlannerScreen(),
            '/trainer': (ctx) => const PhysicalTrainerScreen(),
            '/stress': (ctx) => const StressHandlerScreen(),
          },
        );
      },
    );
  }
}
