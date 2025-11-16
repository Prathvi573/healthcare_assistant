// lib/screens/settings/settings_screen.dart
import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 10),

          /// Profile
          ListTile(
            leading: const Icon(Icons.person, color: Colors.teal),
            title: const Text("Profile"),
            subtitle: const Text("Update your personal details"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // TODO: Navigate to Profile Screen
            },
          ),
          const Divider(),

          /// Language
          ListTile(
            leading: const Icon(Icons.language, color: Colors.teal),
            title: const Text("Language"),
            subtitle: const Text("Choose app language"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // TODO: Show language selection
            },
          ),
          const Divider(),

          /// Notifications
          SwitchListTile(
            secondary: const Icon(Icons.notifications, color: Colors.teal),
            title: const Text("Notifications"),
            subtitle: const Text("Enable or disable reminders"),
            value: true,
            onChanged: (val) {
              // TODO: Save setting
            },
          ),
          const Divider(),

          /// Theme
          ListTile(
            leading: const Icon(Icons.brightness_6, color: Colors.teal),
            title: const Text("Theme"),
            subtitle: const Text("Light / Dark mode"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // TODO: Implement theme switching
            },
          ),
          const Divider(),

          /// Logout
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Logout"),
            subtitle: const Text("Sign out of your account"),
            onTap: () {
              // TODO: Implement Firebase logout
            },
          ),
        ],
      ),
    );
  }
}
