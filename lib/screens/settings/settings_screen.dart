import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/theme_provider.dart';
// FIXED: We only need app_settings
import 'package:app_settings/app_settings.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String selectedLanguage = "English";
  bool notificationsEnabled = true;
  final FlutterTts flutterTts = FlutterTts();
  final TextEditingController sosController = TextEditingController();

  bool _isBlindMode = false; 

  @override
  void initState() {
    super.initState();
    _checkUserMode();
    _loadSOSNumber();
  }

  Future<void> _checkUserMode() async {
    final prefs = await SharedPreferences.getInstance();
    final userType = prefs.getString('userType');
    setState(() {
      _isBlindMode = (userType == 'blind');
    });
    if (_isBlindMode) {
      _speak("Settings screen.");
    }
  }

  Future<void> _loadSOSNumber() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      sosController.text = prefs.getString('sosNumber') ?? '';
    });
  }

  Future<void> _saveSOSNumber() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('sosNumber', sosController.text.trim());
    _speak("SOS number saved");
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ SOS number saved successfully")),
      );
    }
  }

  Future<void> _speak(String text) async {
    if (!_isBlindMode) return;
    await flutterTts.setLanguage("en-US");
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.speak(text);
  }

  @override
  void dispose() {
    sosController.dispose();
    flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // 🌙 Dark Mode Switch
          SwitchListTile(
            title: const Text("Dark Mode"),
            subtitle: const Text("Enable dark theme"),
            value: themeProvider.isDarkMode,
            onChanged: (value) {
              themeProvider.toggleTheme(value);
              _speak(value ? "Dark mode enabled" : "Light mode enabled");
            },
            secondary: const Icon(Icons.brightness_6, color: Colors.teal),
          ),
          const Divider(),

          // 🌐 Language Selector
          ListTile(
            leading: const Icon(Icons.language, color: Colors.teal),
            title: const Text("Language"),
            subtitle: Text(selectedLanguage),
            onTap: () => _speak("Select language. Current is $selectedLanguage"),
            trailing: DropdownButton<String>(
              value: selectedLanguage,
              items: const [
                DropdownMenuItem(value: "English", child: Text("English")),
                DropdownMenuItem(value: "Kannada", child: Text("Kannada")),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    selectedLanguage = value;
                  });
                  _speak("$selectedLanguage selected");
                }
              },
            ),
          ),
          const Divider(),

          // 🔔 Notifications
          SwitchListTile(
            title: const Text("Notifications"),
            subtitle: const Text("Receive medicine and health reminders"),
            value: notificationsEnabled,
            onChanged: (value) {
              setState(() {
                notificationsEnabled = value;
              });
              _speak(notificationsEnabled
                  ? "Notifications enabled"
                  : "Notifications disabled");
            },
            secondary: const Icon(Icons.notifications, color: Colors.teal),
          ),
          
          // --- START OF PERMISSION FIX ---
          const Divider(),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              "Fix Alarm & Battery",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
          ),
          const Text(
            "If alarms are not working, tap the button below and manually enable permissions.",
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 10),

          // FIXED: This button opens the "App Info" page, which is reliable.
          ListTile(
            leading: const Icon(Icons.settings, color: Colors.redAccent),
            title: const Text("Open App Settings"),
            subtitle: const Text("Tap to fix alarms and battery permissions"),
            onTap: () async {
              // Give clear instructions
              _speak(
                  "Opening App Info. First, tap Battery Usage, and enable Allow Background Activity and Auto Launch. Then, go back, tap Permissions, and enable Alarms and Reminders.");
              
              // This call is reliable and will open your app's settings page.
              await AppSettings.openAppSettings(type: AppSettingsType.settings);
            },
          ),
          // --- END OF PERMISSION FIX ---

          const Divider(),

          // ☎️ SOS Number Field
          const SizedBox(height: 10),
          const Text(
            "Emergency SOS Number",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.teal,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: sosController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              hintText: "Enter emergency contact number",
              prefixIcon: const Icon(Icons.phone, color: Colors.teal),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: const Color(0xFFF6F2FA),
            ),
            onTap: () => _speak("Enter emergency S.O.S. contact number"),
          ),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            onPressed: _saveSOSNumber,
            icon: const Icon(Icons.save, color: Colors.white),
            label: const Text("Save SOS Number"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Divider(),

          // ℹ️ About Section
          ListTile(
            leading: const Icon(Icons.info, color: Colors.teal),
            title: const Text("About App"),
            subtitle: const Text("Personal Healthcare Assistant v1.0"),
            onTap: () => _speak("About App. Personal Healthcare Assistant version 1.0"),
          ),
        ],
      ),
    );
  }
}