import 'package:flutter/material.dart';

class HealthInputScreen extends StatelessWidget {
  const HealthInputScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController bpController = TextEditingController();
    final TextEditingController sugarController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text("Enter Health Data")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: bpController,
              decoration: const InputDecoration(
                labelText: "Blood Pressure",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: sugarController,
              decoration: const InputDecoration(
                labelText: "Sugar Level",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                // Later: save health data
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Health data submitted!")),
                );
                Navigator.pop(context);
              },
              child: const Text("Submit"),
            ),
          ],
        ),
      ),
    );
  }
}
