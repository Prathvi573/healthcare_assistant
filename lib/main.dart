import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';

// Providers
import 'providers/theme_provider.dart';

// Screens
import 'screens/normal_user/home_screen.dart';
import 'screens/blind_user/blind_home_screen.dart';
import 'screens/auth/login_screen.dart';

// Services
import 'core/services/alarm_service.dart';

// Global navigator key for alarm → screen navigation
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Initialize Alarm Service (VERY IMPORTANT)
  await AlarmService().init(navigatorKey);

  // Auto-login check
  final prefs = await SharedPreferences.getInstance();
  final userType = prefs.getString('userType');

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: HealthcareAssistantApp(initialUserType: userType),
    ),
  );
}

class HealthcareAssistantApp extends StatelessWidget {
  final String? initialUserType;
  const HealthcareAssistantApp({super.key, this.initialUserType});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    // Decide starting screen
    Widget homeScreen;
    if (initialUserType == 'normal') {
      homeScreen = const NormalUserHome();
    } else if (initialUserType == 'blind') {
      homeScreen = const BlindUserHome();
    } else {
      homeScreen = const LoginScreen();
    }

    return MaterialApp(
      title: 'Healthcare Assistant',
      debugShowCheckedModeBanner: false,

      navigatorKey: navigatorKey, // REQUIRED FOR ALARM REDIRECTION

      theme: ThemeData(
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: Colors.white,
        textTheme: const TextTheme(
          headlineMedium: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          bodyMedium: TextStyle(
            fontSize: 16,
            color: Colors.black54,
          ),
        ),
      ),

      darkTheme: ThemeData.dark(),
      themeMode: themeProvider.themeMode,

      home: homeScreen,
    );
  }
}
