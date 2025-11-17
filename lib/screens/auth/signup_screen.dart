import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart'; // Import TTS
import 'package:shared_preferences/shared_preferences.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  String _userType = "normal";

  final FlutterTts _tts = FlutterTts(); // TTS Added

  @override
  void initState() {
    super.initState();
    _speakIntro(); // Speak when screen opens
  }

  Future<void> _speakIntro() async {
    await _tts.setLanguage("en-US");
    await _tts.setSpeechRate(0.5);
    await _tts.speak("Are you a normal user or a blind user?");
  }

  Future<void> _signup() async {
    final prefs = await SharedPreferences.getInstance();

    // --- THIS IS THE FIX ---
    // Save credentials (if you want to use them in the login screen)
    await prefs.setString("savedUsername", _usernameController.text.trim());
    await prefs.setString("savedPassword", _passwordController.text.trim());
    await prefs.setString("savedUserType", _userType);

    // Create and save the activeUserId based on type
    // This ensures the new user saves data to the correct, separate path
    String uid = _userType == "normal"
        ? "local_normal_user_id" 
        : "local_blind_user_id";
    await prefs.setString("activeUserId", uid);
    // --- End of Fix ---

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Account created successfully!")),
    );

    Navigator.pop(context); // go back to login screen
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sign Up"),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Card(
            elevation: 5,
            color: const Color(0xFFF6F2FA),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Create Account",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Cursive',
                      color: Colors.deepPurple,
                    ),
                  ),
                  const SizedBox(height: 22),
                  DropdownButtonFormField(
                    value: _userType,
                    items: const [
                      DropdownMenuItem(
                        value: "normal",
                        child: Text("Normal User"),
                      ),
                      DropdownMenuItem(
                        value: "blind",
                        child: Text("Blind User"),
                      ),
                    ],
                    decoration: InputDecoration(
                      labelText: "Select User Type",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: (val) => setState(() => _userType = val!),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      labelText: "Username",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: "Password",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 26),
                  ElevatedButton(
                    onPressed: _signup,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      "Create Account",
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}