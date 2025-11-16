import 'package:flutter/material.dart';

class DietRecommendationScreen extends StatelessWidget {
  const DietRecommendationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> tips = [
      "Drink at least 8 glasses of water daily.",
      "Eat more fresh fruits and vegetables.",
      "Reduce oily and fried foods.",
      "Avoid excess sugar and salt.",
      "Include protein-rich foods like eggs, beans, and nuts.",
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Diet Recommendations")),
      body: ListView.builder(
        padding: const EdgeInsets.all(20.0),
        itemCount: tips.length,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: const Icon(Icons.check_circle, color: Colors.teal),
              title: Text(tips[index]),
            ),
          );
        },
      ),
    );
  }
}
