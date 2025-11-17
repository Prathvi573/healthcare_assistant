import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:healthcare_assistant/models/medicine.dart';
import 'package:healthcare_assistant/core/services/alarm_service.dart';
// FIXED: Removed the direct import that caused the "instant pop-up"
// import 'package:healthcare_assistant/screens/normal_user/reminder_confirmation_screen.dart';

class AddMedicineScreen extends StatefulWidget {
  const AddMedicineScreen({super.key});

  @override
  State<AddMedicineScreen> createState() => _AddMedicineScreenState();
}

class _AddMedicineScreenState extends State<AddMedicineScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtl = TextEditingController();
  final _dosageCtl = TextEditingController();
  final _notesCtl = TextEditingController();
  TimeOfDay _time = const TimeOfDay(hour: 8, minute: 0);
  bool _reminder = true;
  String _frequency = 'Daily';
  final List<int> _weekdays = [];

  @override
  void dispose() {
    _nameCtl.dispose();
    _dosageCtl.dispose();
    _notesCtl.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(context: context, initialTime: _time);
    if (t != null && mounted) setState(() => _time = t);
  }

  Widget _weekdayChip(int day, String label) {
    final selected = _weekdays.contains(day);
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (v) {
        setState(() {
          if (v) _weekdays.add(day);
          else _weekdays.remove(day);
        });
      },
    );
  }

  // FIXED: Reads 'activeUserId'
  Future<String> _getActiveUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString("activeUserId");
    if (id == null) {
      final generated = "normal_${DateTime.now().millisecondsSinceEpoch}";
      await prefs.setString("activeUserId", generated);
      return generated;
    }
    return id;
  }

  int _makeNotificationBaseId(String docId) => docId.hashCode & 0x7fffffff;

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final userId = await _getActiveUserId();
    
    // 1. Create the docRef first to get an ID
    final docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('medicines')
        .doc(); // Create document reference
        
    final medicineId = docRef.id; // Get the ID

    // 2. FIXED: Pass the required 'id' to the Medicine constructor
    final med = Medicine(
      id: medicineId, 
      name: _nameCtl.text.trim(),
      dosage: _dosageCtl.text.trim(),
      hour: _time.hour,
      minute: _time.minute,
      reminder: _reminder,
      frequency: _frequency,
      weekdays: _frequency == 'Weekly' ? _weekdays : null,
      notes: _notesCtl.text.trim(),
      createdAt: Timestamp.now(),
      notificationIds: [], // Initialize empty
    );

    // 3. Now set the data on the docRef
    await docRef.set(med.toMap());

    final baseId = _makeNotificationBaseId(docRef.id);
    final List<int> notifIds = [];

    if (med.reminder) {
      final payload = jsonEncode({
        "type": "reminder",
        "medicineId": medicineId,
        "medicineName": med.name,
        "dosage": med.dosage,
        "userMode": "normal"
      });

      final title = 'Time to take ${med.name}';
      final body = '${med.dosage} — ${med.notes}';

      if (med.frequency == 'Daily') {
        final id = baseId;
        notifIds.add(id);
        await AlarmService().scheduleDailyReminder(
          id: id,
          title: title,
          body: body,
          hour: med.hour,
          minute: med.minute,
          payload: payload,
          medicineId: medicineId, // FIXED: Pass required medicineId
        );
      } else {
        for (final wd in (med.weekdays ?? []).cast<int>()) {
          final int id = baseId + wd;
          notifIds.add(id);
        }

        await AlarmService().scheduleWeeklyReminder(
          idBase: baseId,
          title: title,
          body: body,
          hour: med.hour,
          minute: med.minute,
          weekdays: med.weekdays ?? [],
          payload: payload,
          medicineId: medicineId, // FIXED: Pass required medicineId
        );
      }

      await docRef.update({'notificationIds': notifIds});
    }

    if (!mounted) return;
    // FIXED: This is the fix for the "instant pop-up".
    // We just go back to the previous screen (the Home Screen).
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final timeLabel =
        DateFormat.jm().format(DateTime(0, 0, 0, _time.hour, _time.minute));
    return Scaffold(
      appBar: AppBar(title: const Text('Add Medicine')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameCtl,
                decoration: const InputDecoration(labelText: 'Medicine name'),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Enter medicine name' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _dosageCtl,
                decoration:
                    const InputDecoration(labelText: 'Dosage (e.g., 650 mg)'),
              ),
              const SizedBox(height: 12),
              ListTile(
                title: const Text('Time'),
                subtitle: Text(timeLabel),
                trailing: IconButton(
                    icon: const Icon(Icons.access_time), onPressed: _pickTime),
              ),
              SwitchListTile(
                title: const Text('Enable Reminder'),
                value: _reminder,
                onChanged: (v) => setState(() => _reminder = v),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                initialValue: _frequency,
                items: const [
                  DropdownMenuItem(value: 'Daily', child: Text('Daily')),
                  DropdownMenuItem(value: 'Weekly', child: Text('Weekly')),
                ],
                onChanged: (v) => setState(() => _frequency = v!),
                decoration: const InputDecoration(labelText: 'Frequency'),
              ),
              if (_frequency == 'Weekly') ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    _weekdayChip(1, 'Mon'),
                    _weekdayChip(2, 'Tue'),
                    _weekdayChip(3, 'Wed'),
                    _weekdayChip(4, 'Thu'),
                    _weekdayChip(5, 'Fri'),
                    _weekdayChip(6, 'Sat'),
                    _weekdayChip(7, 'Sun'),
                  ],
                ),
              ],
              const SizedBox(height: 12),
              TextFormField(
                controller: _notesCtl,
                decoration: const InputDecoration(labelText: 'Notes'),
                maxLines: 2,
              ),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: _save, child: const Text('Save & Schedule')),
            ],
          ),
        ),
      ),
    );
  }
}