import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/theme_provider.dart';

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

  @override
  void initState() {
    super.initState();
    _loadSOSNumber();
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
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("✅ SOS number saved successfully")),
    );
  }

  Future<void> _speak(String text) async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.speak(text);
  }

  @override
  void dispose() {
    sosController.dispose();
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
          const ListTile(
            leading: Icon(Icons.info, color: Colors.teal),
            title: Text("About App"),
            subtitle: Text("Personal Healthcare Assistant v1.0"),
          ),
        ],
      ),
    );
  }
}
