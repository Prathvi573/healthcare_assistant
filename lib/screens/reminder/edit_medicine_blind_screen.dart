import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:healthcare_assistant/models/medicine.dart';
import 'package:healthcare_assistant/core/services/firebase_service.dart';
import 'package:healthcare_assistant/core/services/alarm_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class EditMedicineBlindScreen extends StatefulWidget {
  final Medicine medicine;
  const EditMedicineBlindScreen({required this.medicine, super.key});

  @override
  State<EditMedicineBlindScreen> createState() => _EditMedicineBlindScreenState();
}

class _EditMedicineBlindScreenState extends State<EditMedicineBlindScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtl;
  late TextEditingController _dosageCtl;
  late TextEditingController _notesCtl;
  late TimeOfDay _time;
  late bool _reminder;
  late String _frequency;
  late List<int> _weekdays;
  final FlutterTts _tts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _nameCtl = TextEditingController(text: widget.medicine.name);
    _dosageCtl = TextEditingController(text: widget.medicine.dosage);
    _notesCtl = TextEditingController(text: widget.medicine.notes);
    _time = TimeOfDay(hour: widget.medicine.hour, minute: widget.medicine.minute);
    _reminder = widget.medicine.reminder;
    _frequency = widget.medicine.frequency;
    _weekdays = widget.medicine.weekdays ?? [];

    _speak("Edit medicine screen opened. Fields are prefilled.");
  }

  Future<void> _speak(String t) async {
    await _tts.setLanguage("en-US");
    await _tts.setSpeechRate(0.45);
    await _tts.speak(t);
  }

  @override
  void dispose() {
    _nameCtl.dispose();
    _dosageCtl.dispose();
    _notesCtl.dispose();
    super.dispose();
  }

  Future<String?> _getUserId() async {
    final p = await SharedPreferences.getInstance();
    return p.getString('activeUserId'); // Use activeUserId
  }

  int _makeBaseId(String docId) => docId.hashCode & 0x7fffffff;

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final userId = await _getUserId();
    if (userId == null) return;

    final med = Medicine(
      id: widget.medicine.id,
      name: _nameCtl.text.trim(),
      dosage: _dosageCtl.text.trim(),
      hour: _time.hour,
      minute: _time.minute,
      reminder: _reminder,
      frequency: _frequency,
      weekdays: _frequency == 'Weekly' ? _weekdays : null,
      notes: _notesCtl.text.trim(),
      notificationIds: widget.medicine.notificationIds,
      createdAt: widget.medicine.createdAt,
      lastTaken: widget.medicine.lastTaken,
      missedCount: widget.medicine.missedCount,
    );

    // cancel old notifications
    if (widget.medicine.notificationIds != null) {
      for (final id in widget.medicine.notificationIds!) {
        await AlarmService().cancel(id);
      }
    }

    final baseId = _makeBaseId(med.id);
    final List<int> notifIds = [];

    if (med.reminder) {
      final payload = jsonEncode({
        "type": "reminder",
        "medicineId": med.id,
        "medicineName": med.name,
        "dosage": med.dosage,
        "userMode": "blind",
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
          medicineId: med.id, // FIXED: Pass required medicineId
        );
      } else {
        for (final wd in (med.weekdays ?? []).cast<int>()) {
          final id = baseId + wd;
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
          medicineId: med.id, // FIXED: Pass required medicineId
        );
      }
    }

    await FirebaseService.instance.updateMedicine(userId, med.id, {
      'name': med.name,
      'dosage': med.dosage,
      'hour': med.hour,
      'minute': med.minute,
      'reminder': med.reminder,
      'frequency': med.frequency,
      'weekdays': med.weekdays ?? [],
      'notes': med.notes,
      'notificationIds': notifIds,
    });

    await _speak("Medicine updated.");
    if (!mounted) return;
    Navigator.pop(context);
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(context: context, initialTime: _time);
    if (t != null && mounted) {
      setState(() => _time = t);
      await _speak("Time updated to ${_time.format(context)}");
    }
  }

  Widget _weekdayChip(int day, String label) {
    final selected = _weekdays.contains(day);
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (v) {
        setState(() {
          if (v) _weekdays.add(day); else _weekdays.remove(day);
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final timeLabel = DateFormat.jm().format(DateTime(0, 0, 0, _time.hour, _time.minute));
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Medicine (Blind)')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(controller: _nameCtl, decoration: const InputDecoration(labelText: 'Medicine name'), validator: (v)=> v==null||v.isEmpty?'Enter name':null, onTap: ()=> _speak("Edit name")),
              const SizedBox(height:12),
              TextFormField(controller: _dosageCtl, decoration: const InputDecoration(labelText: 'Dosage'), onTap: ()=> _speak("Edit dosage")),
              const SizedBox(height:12),
              ListTile(title: const Text('Time'), subtitle: Text(timeLabel), trailing: IconButton(icon: const Icon(Icons.access_time), onPressed: _pickTime)),
              SwitchListTile(title: const Text('Enable Reminder'), value: _reminder, onChanged: (v) { setState(()=> _reminder = v); _speak(v? "Reminder enabled":"Reminder disabled");}),
              DropdownButtonFormField<String>(
                initialValue: _frequency, 
                items: const [DropdownMenuItem(value:'Daily', child: Text('Daily')), DropdownMenuItem(value:'Weekly', child: Text('Weekly'))], 
                onChanged: (v){ setState(()=> _frequency = v!); _speak("Frequency $v selected");}
              ),
              if (_frequency == 'Weekly') Wrap(spacing: 8, children: [ _weekdayChip(1,'Mon'), _weekdayChip(2,'Tue'), _weekdayChip(3,'Wed'), _weekdayChip(4,'Thu'), _weekdayChip(5,'Fri'), _weekdayChip(6,'Sat'), _weekdayChip(7,'Sun'),]),
              const SizedBox(height:12),
              TextFormField(controller: _notesCtl, decoration: const InputDecoration(labelText: 'Notes'), maxLines:2, onTap: ()=> _speak("Edit notes")),
              const SizedBox(height:20),
              ElevatedButton(onPressed: _save, child: const Text('Save Changes')),
            ],
          ),
        ),
      ),
    );
  }
}