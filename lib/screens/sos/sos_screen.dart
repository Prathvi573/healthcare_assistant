import 'package:flutter/material.dart';

class SosScreen extends StatelessWidget {
  const SosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("SOS Alert")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.emergency, size: 100, color: Colors.red),
            const SizedBox(height: 20),
            const Text(
              "Press the button to send an SOS alert",
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              icon: const Icon(Icons.send),
              label: const Text("Send SOS"),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 16)),
              onPressed: () {
                // TODO: Implement SOS functionality
              },
            )
          ],
        ),
      ),
    );
  }
}
