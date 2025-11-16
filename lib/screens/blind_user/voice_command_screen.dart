import 'package:flutter/material.dart';

class VoiceCommandScreen extends StatelessWidget {
  const VoiceCommandScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Voice Commands")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.mic, size: 100, color: Colors.teal),
            const SizedBox(height: 20),
            const Text(
              "Tap the mic and speak your command",
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              icon: const Icon(Icons.mic),
              label: const Text("Start Listening"),
              style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 16)),
              onPressed: () {
                // TODO: Implement STT (speech-to-text)
              },
            )
          ],
        ),
      ),
    );
  }
}
