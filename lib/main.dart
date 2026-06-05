import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controllers/auth_controller.dart';
import 'login.dart';
import 'account.dart';
import 'views/splash_screen.dart';
import 'views/dashboard_screen.dart';
import 'database/db_initializer.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Database Factory (Desktop FFI or Web stub)
  initDatabaseFactory();

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
        scaffoldBackgroundColor: const Color(0xFF0F0C20),
        primaryColor: Colors.pinkAccent,
        colorScheme: const ColorScheme.dark(
          primary: Colors.pinkAccent,
          secondary: Colors.purpleAccent,
          surface: Color(0xFF1E1E2C),
          error: Colors.redAccent,
        ),

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
          fillColor: Colors.white.withOpacity(0.05),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.pinkAccent, width: 2),
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
