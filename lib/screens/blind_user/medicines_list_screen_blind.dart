import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:healthcare_assistant/core/services/firebase_service.dart';
import 'package:healthcare_assistant/models/medicine.dart';
import 'package:healthcare_assistant/core/services/alarm_service.dart';
// FIXED: Import the blind edit screen from the correct new path
import 'package:healthcare_assistant/screens/reminder/edit_medicine_blind_screen.dart';

class MedicinesListScreenBlind extends StatefulWidget {
  const MedicinesListScreenBlind({super.key});
  @override
  State<MedicinesListScreenBlind> createState() => _MedicinesListScreenBlindState();
}

class _MedicinesListScreenBlindState extends State<MedicinesListScreenBlind> {
  String? _userId;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  // FIXED: Reads 'activeUserId'
  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getString('activeUserId');
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_userId == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(title: const Text('My Medicines (Blind)')),
      body: StreamBuilder<List<Medicine>>(
        stream: FirebaseService.instance.streamMedicines(_userId!),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final meds = snapshot.data!;
          if (meds.isEmpty) return const Center(child: Text("No medicines added."));
          
          return ListView.builder(
            itemCount: meds.length,
            itemBuilder: (context, i) {
              final m = meds[i];
              return ListTile(
                title: Text(m.name),
                subtitle: Text('${m.dosage} • ${m.frequency}'),
                trailing: PopupMenuButton<String>(
                  onSelected: (v) async {
                    
                    // FIXED: Only routes to blind edit screen
                    if (v == 'edit') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              EditMedicineBlindScreen(medicine: m),
                        ),
                      );
                    } else if (v == 'reschedule') {
                       Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              EditMedicineBlindScreen(medicine: m),
                        ),
                      );
                    } else if (v == 'delete') {
                      await FirebaseService.instance
                          .deleteMedicine(_userId!, m.id);

                      if (m.notificationIds != null) {
                        for (final nid in m.notificationIds!) {
                          await AlarmService().cancel(nid);
                        }
                      }
                    }
                  },
                  // FIXED: Only show relevant options
                  itemBuilder: (_) => [
                    const PopupMenuItem(
                        value: 'edit', child: Text('Edit')),
                    const PopupMenuItem(
                        value: 'reschedule', child: Text('Reschedule')),
                    const PopupMenuItem(
                        value: 'delete', child: Text('Delete')),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}