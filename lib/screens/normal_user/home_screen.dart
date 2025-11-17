import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:healthcare_assistant/screens/auth/login_screen.dart';
import 'package:healthcare_assistant/screens/settings/settings_screen.dart';
import 'package:healthcare_assistant/screens/normal_user/add_medicine_screen.dart';
import 'package:healthcare_assistant/screens/normal_user/health_input_screen.dart';
import 'package:healthcare_assistant/screens/normal_user/diet_recommendation_screen.dart';
import 'package:healthcare_assistant/screens/normal_user/pill_capture_screen.dart';
// FIXED: Import the correct list screen
import 'package:healthcare_assistant/screens/reminder/medicines_list_screen.dart';


class NormalUserHome extends StatelessWidget {
  const NormalUserHome({super.key});

  Future<void> _triggerSOS(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final sosNumber = prefs.getString('sosNumber');

    if (sosNumber == null || sosNumber.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("⚠️ No SOS number set in Settings")),
        );
      }
      return;
    }

    try {
      await FlutterPhoneDirectCaller.callNumber(sosNumber);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ Failed to call $sosNumber")),
        );
      }
    }
  }

  void _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userType');
    await prefs.remove('activeUserId'); // Clear the active user ID

    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Normal User Dashboard",
          style: TextStyle(fontFamily: "Cursive"),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: "Logout",
            onPressed: () => _logout(context),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: "Settings",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      // FIXED: Restored your original Floating Action Button
      floatingActionButton: FloatingActionButton(
        onPressed: () => _triggerSOS(context),
        backgroundColor: Colors.red,
        child: const Icon(Icons.warning, color: Colors.white, size: 28),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: [
            const SizedBox(height: 6),
            _buildOption(
              context,
              icon: Icons.medical_services,
              label: "Add Medicine",
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddMedicineScreen()),
              ),
            ),
            _buildOption(
              context,
              icon: Icons.monitor_heart,
              label: "Enter Health Data",
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HealthInputScreen()),
              ),
            ),
            _buildOption(
              context,
              icon: Icons.restaurant_menu,
              label: "Diet Recommendations",
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const DietRecommendationScreen()),
              ),
            ),
            _buildOption(
              context,
              icon: Icons.camera_alt,
              label: "Pill Recognition",
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PillCaptureScreen()),
              ),
            ),
            // FIXED: This button now goes to the correct list screen
            _buildOption(
              context,
              icon: Icons.alarm,
              label: "Reminders",
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const MedicinesListScreen(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // FIXED: Restored your original pastel button styling
  Widget _buildOption(BuildContext context,
      {required IconData icon,
      required String label,
      required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: ElevatedButton.icon(
        icon: Icon(icon, color: Colors.deepPurple),
        label: Text(
          label,
          style: const TextStyle(
            fontSize: 18,
            fontFamily: "Cursive",
            color: Colors.deepPurple,
          ),
        ),
        style: ElevatedButton.styleFrom(
          elevation: 3,
          backgroundColor: const Color(0xFFF6F2FA),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          minimumSize: const Size(double.infinity, 55),
        ),
        onPressed: onTap,
      ),
    );
  }
}