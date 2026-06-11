import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task/core/app_color.dart';
import 'package:task/core/shared_prefs.dart';
import 'auth/controllers/auth_controller.dart';
import 'auth/screens/login_screen.dart';
import 'auth/screens/signup_screen.dart';
import 'onboarding/screens/splash_screen.dart';
import 'dashboard/screens/dashboard_screen.dart';
import 'database/db_initializer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Database Factory (Desktop FFI or Web stub)
  initDatabaseFactory();
  // Initialize SharedPreferences utility
  await SharedPrefs.init();
  // Initialize Global Auth Controller
  Get.put(AuthController(), permanent: true);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Dating Swipe App',
      debugShowCheckedModeBanner: false,

      // Define a custom modern premium dark theme
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColor.background,
        primaryColor: AppColor.primary,
        colorScheme: const ColorScheme.dark(
          primary: AppColor.primary,
          secondary: AppColor.secondary,
          surface: AppColor.surface,
          error: AppColor.error,
          onSurface: AppColor.background,
        ),
        fontFamily: 'Lato',

        // Custom Font & Text styling
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          bodyLarge: TextStyle(fontSize: 16, color: Colors.white70),
          bodyMedium: TextStyle(fontSize: 14, color: Colors.white60),
        ),

        // Input decoration theme for forms
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.05),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColor.primary, width: 2),
          ),
          labelStyle: const TextStyle(color: Colors.white54),
        ),
      ),

      // Routing configuration
      initialRoute: '/',
      getPages: [
        GetPage(
          name: '/',
          page: () => const SplashScreen(),
          transition: Transition.fade,
        ),
        GetPage(
          name: '/login',
          page: () => const LoginPage(),
          transition: Transition.rightToLeftWithFade,
        ),
        GetPage(
          name: '/register',
          page: () => const RegisterPage(),
          transition: Transition.rightToLeftWithFade,
        ),
        GetPage(
          name: '/dashboard',
          page: () => const DashboardScreen(),
          transition: Transition.fadeIn,
        ),
      ],
    );
  }
}
