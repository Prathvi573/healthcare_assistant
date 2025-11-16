// lib/models/medicine.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Medicine {
  String id;
  String name;
  String dosage;
  int hour;
  int minute;
  bool reminder;
  String frequency; // "Daily" or "Weekly"
  List<int>? weekdays; // 1=Mon ... 7=Sun
  String notes;
  List<int>? notificationIds;
  Timestamp? createdAt;
  Timestamp? lastTaken;

  Medicine({
    this.id = '',
    required this.name,
    required this.dosage,
    required this.hour,
    required this.minute,
    required this.reminder,
    required this.frequency,
    this.weekdays,
    this.notes = '',
    this.notificationIds,
    this.createdAt,
    this.lastTaken,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'dosage': dosage,
      'hour': hour,
      'minute': minute,
      'reminder': reminder,
      'frequency': frequency,
      'weekdays': weekdays ?? [],
      'notes': notes,
      'notificationIds': notificationIds ?? [],
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  static Medicine fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Medicine(
      id: doc.id,
      name: data['name'] ?? '',
      dosage: data['dosage'] ?? '',
      hour: (data['hour'] ?? 0) as int,
      minute: (data['minute'] ?? 0) as int,
      reminder: data['reminder'] ?? false,
      frequency: data['frequency'] ?? 'Daily',
      weekdays: List<int>.from(data['weekdays'] ?? []),
      notes: data['notes'] ?? '',
      notificationIds: List<int>.from(data['notificationIds'] ?? []),
      createdAt: data['createdAt'],
      lastTaken: data['lastTaken'],
    );
  }
}
