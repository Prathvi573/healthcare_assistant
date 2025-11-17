import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_tts/flutter_tts.dart';

class HealthInputScreen extends StatefulWidget {
  const HealthInputScreen({super.key});

  @override
  State<HealthInputScreen> createState() => _HealthInputScreenState();
}

class _HealthInputScreenState extends State<HealthInputScreen> {
  final _formKey = GlobalKey<FormState>();
  final _bpController = TextEditingController();
  final _sugarController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _ageController = TextEditingController();

  String? _gender;
  String? _dietType;

  bool _isEditing = true;
  bool _isLoading = false;
  String? _userId;

  final FlutterTts _tts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _initTts();
    _loadHealthData();
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

  Future<void> _loadHealthData() async {
    setState(() => _isLoading = true);
    _userId = await _getActiveUserId();
    if (_userId == null) {
      setState(() => _isLoading = false);
      _speak("Error, not logged in.");
      return;
    }

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(_userId)
        .collection('health_data')
        .doc('profile')
        .get();

    if (doc.exists && doc.data() != null) {
      final data = doc.data()!;
      _bpController.text = data['bloodPressure'] ?? '';
      _sugarController.text = data['sugarLevel'] ?? '';
      _heightController.text = data['height'] ?? '';
      _weightController.text = data['weight'] ?? '';
      _ageController.text = data['age'] ?? '';
      _gender = data['gender'];
      _dietType = data['dietType'];
      _isEditing = false;
      _speak("Health data loaded. Tap the edit button to make changes.");
    } else {
      _isEditing = true; // No data, start in edit mode
      _speak("Enter your health data.");
    }
    setState(() => _isLoading = false);
  }

  Future<void> _saveHealthData() async {
    if (!_formKey.currentState!.validate()) {
      _speak("Please fill all required fields.");
      return;
    }
    if (_userId == null) return;

    setState(() => _isLoading = true);
    _speak("Saving data.");

    final healthData = {
      'bloodPressure': _bpController.text,
      'sugarLevel': _sugarController.text,
      'height': _heightController.text,
      'weight': _weightController.text,
      'age': _ageController.text,
      'gender': _gender,
      'dietType': _dietType,
      'lastUpdated': FieldValue.serverTimestamp(),
    };

    await FirebaseFirestore.instance
        .collection('users')
        .doc(_userId)
        .collection('health_data')
        .doc('profile')
        .set(healthData, SetOptions(merge: true));

    setState(() {
      _isLoading = false;
      _isEditing = false;
    });

    _speak("Health data saved!");
  }

  @override
  void dispose() {
    _bpController.dispose();
    _sugarController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _ageController.dispose();
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Enter Health Data"),
        actions: [
          if (!_isEditing && !_isLoading)
            IconButton(
              icon: const Icon(Icons.edit),
              tooltip: "Edit Data",
              onPressed: () {
                setState(() => _isEditing = true);
                _speak("Editing enabled.");
              },
            )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildTextFormField(
                      controller: _bpController,
                      label: "Blood Pressure (e.g., 120/80)",
                      speakLabel: "Blood Pressure. Example: 120 slash 80",
                    ),
                    _buildTextFormField(
                      controller: _sugarController,
                      label: "Sugar Level (e.g., 90 mg/dL)",
                      speakLabel: "Sugar Level. Example: 90",
                      keyboardType: TextInputType.number,
                    ),
                    _buildTextFormField(
                      controller: _heightController,
                      label: "Height (e.g., 175 cm)",
                      speakLabel: "Height in centimeters",
                      keyboardType: TextInputType.number,
                    ),
                    _buildTextFormField(
                      controller: _weightController,
                      label: "Weight (e.g., 70 kg)",
                      speakLabel: "Weight in kilograms",
                      keyboardType: TextInputType.number,
                    ),
                    _buildTextFormField(
                      controller: _ageController,
                      label: "Age",
                      speakLabel: "Age",
                      keyboardType: TextInputType.number,
                    ),
                    _buildDropdown(
                      value: _gender,
                      label: "Gender",
                      speakLabel: "Select Gender",
                      items: ['Male', 'Female', 'Other'],
                      onChanged: (val) {
                        setState(() => _gender = val);
                        _speak("Selected $val");
                      },
                    ),
                    _buildDropdown(
                      value: _dietType,
                      label: "Diet Type",
                      speakLabel: "Select Diet Type",
                      items: ['Vegetarian', 'Non-Vegetarian', 'Vegan'],
                      onChanged: (val) {
                        setState(() => _dietType = val);
                        _speak("Selected $val");
                      },
                    ),
                    const SizedBox(height: 30),
                    if (_isEditing)
                      ElevatedButton(
                        onPressed: _saveHealthData,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        child: const Text("Save"),
                      ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required String speakLabel,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: TextFormField(
        controller: controller,
        enabled: _isEditing,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        onTap: () => _speak(speakLabel),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $label';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDropdown({
    required String? value,
    required String label,
    required String speakLabel,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: DropdownButtonFormField<String>(
        value: value,
        items: items.map((item) {
          return DropdownMenuItem(value: item, child: Text(item));
        }).toList(),
        onChanged: _isEditing ? onChanged : null,
        onTap: () => _speak(speakLabel),
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please select $label';
          }
          return null;
        },
      ),
    );
  }
}