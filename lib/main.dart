import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:permission_handler/permission_handler.dart';

// Providers
import 'providers/theme_provider.dart';

// Screens
import 'screens/normal_user/home_screen.dart';
import 'screens/blind_user/blind_home_screen.dart';
import 'screens/auth/login_screen.dart';

// FIXED: Import reminder screens with prefixes to avoid name conflict
import 'screens/normal_user/reminder_confirmation_screen.dart' as normal_reminder;
import 'screens/blind_user/reminder_confirmation_screen.dart' as blind_reminder;

// Services
import 'core/services/alarm_service.dart';

// Global navigator key for alarm → screen navigation
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  // Request permissions
  await Permission.notification.request();
  await Permission.scheduleExactAlarm.request();
  await Permission.ignoreBatteryOptimizations.request();

  await AlarmService().init(navigatorKey);

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
  Widget build(BuildContext ctxt) { // Renamed context to avoid conflict
    final themeProvider = Provider.of<ThemeProvider>(ctxt);

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
              fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
          bodyMedium: TextStyle(fontSize: 16, color: Colors.black54),
        ),
      ),
      darkTheme: ThemeData.dark(),
      themeMode: themeProvider.themeMode,
      
      // FIXED: Added routes for alarm navigation
      routes: {
        '/normalReminder': (context) {
          // This reads the arguments sent from the AlarmService
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return normal_reminder.ReminderConfirmationScreen(
            medicineName: args['medicineName'] ?? '',
            dosage: args['dosage'] ?? '',
            medicineId: args['medicineId'],
          );
        },
        '/blindReminder': (context) {
           final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return blind_reminder.ReminderConfirmationScreen(
            medicineName: args['medicineName'] ?? '',
            dosage: args['dosage'] ?? '',
            medicineId: args['medicineId'],
          );
        },
      },
      home: homeScreen,
    );
  }
}