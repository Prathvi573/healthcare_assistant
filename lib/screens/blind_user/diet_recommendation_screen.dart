import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:healthcare_assistant/core/api_key.dart'; // Import your secret API key

class DietRecommendationScreen extends StatefulWidget {
  const DietRecommendationScreen({super.key});

  @override
  State<DietRecommendationScreen> createState() =>
      _DietRecommendationScreenState();
}

class _DietRecommendationScreenState extends State<DietRecommendationScreen> {
  bool _isLoading = true;
  List<String> _tipsList = []; // Store tips as a list
  
  final FlutterTts _tts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _initTts();
    _fetchDataAndGenerateTips();
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  Future<void> _initTts() async {
    await _tts.setLanguage("en-US");
    await _tts.setSpeechRate(0.5);
  }

  Future<void> _speak(String text) async {
    await _tts.speak(text);
  }

  Future<String?> _getActiveUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('activeUserId');
  }

  // --- AI Functions (Same as Normal User) ---

  String _buildPrompt(Map<String, dynamic> data) {
    return '''
    Act as a friendly, expert nutritionist. 
    Here is my health profile:
    - Age: ${data['age']}
    - Gender: ${data['gender']}
    - Height: ${data['height']} cm
    - Weight: ${data['weight']} kg
    - Blood Pressure: ${data['bloodPressure']}
    - Sugar Level: ${data['sugarLevel']}
    - My usual diet: ${data['dietType']}

    Based on this profile, please give me 5 specific, "real-life" diet recommendations.
    Make them actionable, like specific food swaps or meal ideas, not just "eat better".
    
    Start each of the 5 tips with a '•' (bullet point) and a space ,
    give as much minimal you can give because peoples does not have that much time to read that all
     can you make it look beautiful, give short and sweet small bullet points.
    ''';
  }

  Future<String> _getGeminiRecommendations(String prompt) async {
    try {
      // FIXED: Switched to the Flash model (less likely to be overloaded)
      final model = GenerativeModel(
        model: 'gemini-2.5-flash',
        apiKey: geminiApiKey,
      );
      
      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);
      return response.text ?? "No recommendations generated. Please try again.";

    } on GenerativeAIException catch (e) {
      // FIXED: Handle the 503 error specifically
      if (e.message.contains("503") || e.message.contains("overloaded")) {
        return "The AI nutritionist is very busy right now. Please try again in a moment.";
      }
      return "An error occurred with the AI service: ${e.message}";
    } catch (e) {
      return "Error. Please check your internet connection and try again.";
    }
  }

  // --- End of AI Functions ---

  Future<void> _fetchDataAndGenerateTips() async {
    setState(() => _isLoading = true);
    final userId = await _getActiveUserId();
    if (userId == null) {
      setState(() => _isLoading = false);
      _tipsList = ["Error: Not logged in."];
      _speak(_tipsList[0]);
      return;
    }

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('health_data')
        .doc('profile')
        .get();

    if (!doc.exists || doc.data() == null) {
      setState(() => _isLoading = false);
      _tipsList = [
        "No health data found. Please save your data in the 'Enter Health Data' screen first."
      ];
      _speak(_tipsList[0]);
      return;
    }

    final healthData = doc.data()!;
    final prompt = _buildPrompt(healthData);
    final aiResponse = await _getGeminiRecommendations(prompt);

    // Split the AI response into a list of tips
    // This will work for both success and friendly error messages
    final tips = aiResponse.split('•').where((s) => s.trim().isNotEmpty).toList();

    // If there were no bullet points (e.g., an error message), add the whole response as one "tip"
    if (tips.isEmpty) {
      _tipsList = [aiResponse];
    } else {
       _tipsList = tips.map((t) => t.trim()).toList();
    }

    setState(() {
      _isLoading = false;
    });

    // Speak all recommendations
    _speak("Here are your personalized diet recommendations. ${aiResponse.replaceAll('•', 'Tip:')}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Your Diet Recommendations")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(20.0),
              itemCount: _tipsList.length,
              itemBuilder: (context, index) {
                final tip = _tipsList[index].trim();
                // Use a default icon
                String icon = "✅";
                if (tip.contains("busy")) icon = "⏳";
                if (tip.contains("Error")) icon = "❌";

                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: Text(
                      icon,
                      style: const TextStyle(fontSize: 24),
                    ),
                    title: Text(
                      tip,
                      style: const TextStyle(fontSize: 16, height: 1.4),
                    ),
                    onTap: () => _speak(tip), // Speak individual tip on tap
                  ),
                );
              },
            ),
    );
  }
}