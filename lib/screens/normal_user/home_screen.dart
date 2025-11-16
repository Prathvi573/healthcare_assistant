import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import '../auth/login_screen.dart';
import '../settings/settings_screen.dart';
import 'add_medicine_screen.dart';
import 'health_input_screen.dart';
import 'diet_recommendation_screen.dart';
import 'pill_capture_screen.dart';
import 'reminder_confirmation_screen.dart';

class NormalUserHome extends StatelessWidget {
  const NormalUserHome({super.key});

  Future<void> _triggerSOS(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final sosNumber = prefs.getString('sosNumber');

    if (sosNumber == null || sosNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ No SOS number set in Settings")),
      );
      return;
    }

    try {
      // Directly make the phone call
      await FlutterPhoneDirectCaller.callNumber(sosNumber);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Failed to call $sosNumber")),
      );
    }
  }

  void _logout(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _triggerSOS(context),
        backgroundColor: Colors.redAccent,
        icon: const Icon(Icons.warning_amber_rounded, color: Colors.white),
        label: const Text("SOS", style: TextStyle(color: Colors.white)),
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
            _buildOption(
              context,
              icon: Icons.alarm,
              label: "Reminders",
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ReminderConfirmationScreen(
                    medicineName: "Example",
                    dosage: "Example dosage",
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

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
