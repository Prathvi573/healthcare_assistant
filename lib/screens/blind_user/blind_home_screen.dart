import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';

import '../auth/login_screen.dart';
import '../settings/settings_screen.dart';
import '../sos/sos_screen.dart';

import 'add_medicine_screen.dart';
import 'pill_capture_screen.dart';
import 'health_input_screen.dart';
import 'diet_recommendation_screen.dart';
import 'voice_command_screen.dart';

class BlindUserHome extends StatefulWidget {
  const BlindUserHome({super.key});

  @override
  State<BlindUserHome> createState() => _BlindUserHomeState();
}

class _BlindUserHomeState extends State<BlindUserHome> {
  final FlutterTts _tts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _speak("Welcome to blind user mode. Use the buttons to navigate."" "
            "   you can choose Add medicine,Pill Recognition,Enter health data,diet recomendation ");
  }

  Future<void> _speak(String text) async {
    await _tts.setLanguage("en-US");
    await _tts.setSpeechRate(0.45);
    await _tts.speak(text);
  }

  Future<void> _logout() async {
    await _speak("Logging out");

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userType');

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  Future<void> _triggerSOS(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final sosNumber = prefs.getString('sosNumber');

    if (sosNumber == null || sosNumber.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("⚠️ No SOS number set")));
      await _speak("No SOS number set in settings");
      return;
    }

    try {
      await FlutterPhoneDirectCaller.callNumber(sosNumber);
      await _speak("SOS alert sent. Calling emergency contact.");
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Failed to call $sosNumber")));
      await _speak("Failed to place the call.");
    }
  }

  // NAVIGATION WITH TTS
  Future<void> _navigateWithSpeech(String msg, Widget screen) async {
    await _speak(msg);
    if (!mounted) return;
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Blind User Dashboard"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.deepPurple),
            tooltip: "Settings",
            onPressed: () => _navigateWithSpeech("Opening settings", const SettingsScreen()),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.deepPurple),
            tooltip: "Logout",
            onPressed: _logout,
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () => _triggerSOS(context),
        backgroundColor: Colors.red,
        child: const Icon(Icons.warning, color: Colors.white, size: 28),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: [
            _buildOption(
              icon: Icons.medical_services,
              label: "Add Medicine",
              onTap: () => _navigateWithSpeech("Opening add medicine", const BlindAddMedicineScreen()),
            ),
            _buildOption(
              icon: Icons.camera_alt,
              label: "Pill Recognition",
              onTap: () => _navigateWithSpeech("Opening pill recognition", const PillCaptureScreen()),
            ),
            _buildOption(
              icon: Icons.monitor_heart,
              label: "Enter Health Data",
              onTap: () => _navigateWithSpeech("Opening health data entry", const HealthInputScreen()),
            ),
            _buildOption(
              icon: Icons.food_bank,
              label: "Diet Recommendation",
              onTap: () => _navigateWithSpeech("Opening diet recommendations", const DietRecommendationScreen()),
            ),
            _buildOption(
              icon: Icons.mic,
              label: "Voice Commands",
              onTap: () => _navigateWithSpeech("Opening voice command mode", const VoiceCommandScreen()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: ElevatedButton.icon(
        icon: Icon(icon, color: Colors.deepPurple),
        label: Text(
          label,
          style: const TextStyle(
            fontSize: 20,
            color: Colors.deepPurple,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          elevation: 3,
          backgroundColor: const Color(0xFFF6F2FA),
          minimumSize: const Size(double.infinity, 60),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        onPressed: onTap,
      ),
    );
  }
}
