import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  @override
  void initState() {
    super.initState();
    _loadHealthData();
  }

  // Get the active user's ID from SharedPreferences
  Future<String?> _getActiveUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('activeUserId');
  }

  // Load existing data from Firebase
  Future<void> _loadHealthData() async {
    setState(() => _isLoading = true);
    _userId = await _getActiveUserId();
    if (_userId == null) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error: Not logged in.")),
        );
      }
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
    } else {
      _isEditing = true; // No data, start in edit mode
    }
    setState(() => _isLoading = false);
  }

  // Save data to Firebase
  Future<void> _saveHealthData() async {
    if (!_formKey.currentState!.validate()) {
      return; // Form is invalid
    }
    if (_userId == null) return;

    setState(() => _isLoading = true);

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

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Health data saved!")),
      );
    }
  }

  @override
  void dispose() {
    _bpController.dispose();
    _sugarController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Enter Health Data"),
        actions: [
          // Show "Edit" button only if data is saved and not editing
          if (!_isEditing && !_isLoading)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() => _isEditing = true);
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
                    ),
                    _buildTextFormField(
                      controller: _sugarController,
                      label: "Sugar Level (e.g., 90 mg/dL)",
                      keyboardType: TextInputType.number,
                    ),
                    _buildTextFormField(
                      controller: _heightController,
                      label: "Height (e.g., 175 cm)",
                      keyboardType: TextInputType.number,
                    ),
                    _buildTextFormField(
                      controller: _weightController,
                      label: "Weight (e.g., 70 kg)",
                      keyboardType: TextInputType.number,
                    ),
                    _buildTextFormField(
                      controller: _ageController,
                      label: "Age",
                      keyboardType: TextInputType.number,
                    ),
                    _buildDropdown(
                      value: _gender,
                      label: "Gender",
                      items: ['Male', 'Female', 'Other'],
                      onChanged: (val) => setState(() => _gender = val),
                    ),
                    _buildDropdown(
                      value: _dietType,
                      label: "Diet Type",
                      items: ['Vegetarian', 'Non-Vegetarian', 'Vegan'],
                      onChanged: (val) => setState(() => _dietType = val),
                    ),
                    const SizedBox(height: 30),
                    // Show "Save" button only if in edit mode
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