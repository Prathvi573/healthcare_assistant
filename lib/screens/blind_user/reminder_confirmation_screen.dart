// lib/screens/blind_user/reminder_confirmation_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:healthcare_assistant/core/services/alarm_service.dart';
import 'package:healthcare_assistant/screens/blind_user/blind_home_screen.dart';

class ReminderConfirmationScreen extends StatefulWidget {
  final String medicineName;
  final String dosage;
  final String? medicineId;

  const ReminderConfirmationScreen({
    super.key,
    required this.medicineName,
    required this.dosage,
    this.medicineId,
  });

  @override
  State<ReminderConfirmationScreen> createState() =>
      _ReminderConfirmationScreenState();
}

class _ReminderConfirmationScreenState extends State<ReminderConfirmationScreen> {
  final FlutterTts _tts = FlutterTts();
  final AlarmService _alarm = AlarmService();

  @override
  void initState() {
    super.initState();
    _speak("Reminder: It's time to take ${widget.medicineName}");
  }

  Future<void> _speak(String t) async {
    await _tts.setLanguage("en-US");
    await _tts.setSpeechRate(0.5);
    await _tts.speak(t);
  }

  Future<String> _getLocalUserId() async {
    final prefs = await SharedPreferences.getInstance();
    var id = prefs.getString('localUserId');
    if (id == null) {
      id = 'local_${DateTime.now().millisecondsSinceEpoch}';
      await prefs.setString('localUserId', id);
    }
    return id;
  }

  Future<void> _markTaken() async {
    _speak("Marked as taken. Good job.");
    if (widget.medicineId != null) {
      final userId = await _getLocalUserId();
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('medicines')
          .doc(widget.medicineId)
          .update({'lastTaken': FieldValue.serverTimestamp()});
    }

    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const BlindUserHome()),
      (route) => false,
    );
  }

  Future<void> _snooze() async {
    final id = DateTime.now().millisecondsSinceEpoch.remainder(100000);
    await _alarm.snoozeMinutes(
      id: id,
      title: "Snoozed: Take ${widget.medicineName}",
      body: widget.dosage,
      minutes: 10,
      payload: widget.medicineId,
    );
    _speak("Snoozed for 10 minutes.");
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const BlindUserHome()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reminder')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text("Time to take ${widget.medicineName}",
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text(widget.dosage, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              icon: const Icon(Icons.check),
              label: const Text('Mark as Taken'),
              onPressed: _markTaken,
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.snooze),
              label: const Text('Snooze 10 minutes'),
              onPressed: _snooze,
            ),
          ],
        ),
      ),
    );
  }
}
