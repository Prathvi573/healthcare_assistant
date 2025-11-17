import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  String _recommendations = ""; // AI response will be stored here

  @override
  void initState() {
    super.initState();
    _fetchDataAndGenerateTips();
  }

  // Get the active user's ID
  Future<String?> _getActiveUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('activeUserId');
  }

  // Build the text "prompt" to send to the AI
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
    
    Start each of the 5 tips with a '•' (bullet point) and a
     space, give as much minimal you can give because peoples does not have that much time to read that all
     can you make it look beautiful give short and sweet small bullet points .
    ''';
  }

  // Call the Gemini API to get recommendations
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
      // Handle other AI errors (like API key)
      return "An error occurred with the AI service: ${e.message}";
    } catch (e) {
      // Handle general errors (like no internet)
      return "Error. Please check your internet connection and try again.";
    }
  }

  // Fetch data from Firebase, then call the AI
  Future<void> _fetchDataAndGenerateTips() async {
    setState(() => _isLoading = true); // Show loading spinner
    final userId = await _getActiveUserId();
    if (userId == null) {
      setState(() {
        _isLoading = false;
        _recommendations = "Error: Not logged in.";
      });
      return;
    }

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('health_data')
        .doc('profile')
        .get();

    if (!doc.exists || doc.data() == null) {
      setState(() {
        _isLoading = false;
        _recommendations =
            "No health data found. Please save your data in the 'Enter Health Data' screen first.";
      });
      return;
    }

    // 1. Build the prompt
    final healthData = doc.data()!;
    final prompt = _buildPrompt(healthData);

    // 2. Call the AI
    final aiResponse = await _getGeminiRecommendations(prompt);

    // 3. Display the result
    setState(() {
      _isLoading = false;
      _recommendations = aiResponse;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Your Diet Recommendations")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20.0),
              children: [
                // Display the raw text response from the AI
                Text(
                  _recommendations,
                  style: const TextStyle(fontSize: 16, height: 1.5),
                )
              ],
            ),
    );
  }
}