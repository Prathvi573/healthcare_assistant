import 'package:cloud_firestore/cloud_firestore.dart';

class Medicine {
  final String id; // This is the Firestore document ID
  final String name;
  final String dosage;
  final int hour;
  final int minute;
  final bool reminder;
  final String frequency;
  final List<int>? weekdays;
  final String notes;
  final Timestamp? createdAt;
  final List<int>? notificationIds;
  final int missedCount;
  final Timestamp? lastTaken;

  Medicine({
    required this.id, // FIXED: 'id' is now required
    required this.name,
    required this.dosage,
    required this.hour,
    required this.minute,
    required this.reminder,
    required this.frequency,
    this.weekdays, // Nullable for 'Daily'
    this.notes = '', // Default value
    this.notificationIds,
    this.createdAt,
    this.lastTaken,
    this.missedCount = 0, // Default value
  });

  Map<String, dynamic> toMap() {
    return {
      // 'id' is not saved in the map, it's the document's ID
      'name': name,
      'dosage': dosage,
      'hour': hour,
      'minute': minute,
      'reminder': reminder,
      'frequency': frequency,
      'weekdays': weekdays,
      'notes': notes,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
      'notificationIds': notificationIds,
      'missedCount': missedCount,
      'lastTaken': lastTaken,
    };
  }

  factory Medicine.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>? ?? {}; // Safe access
    return Medicine(
      id: doc.id, // Get the ID from the document itself
      name: d['name'] ?? '',
      dosage: d['dosage'] ?? '',
      hour: (d['hour'] ?? 0) as int,
      minute: (d['minute'] ?? 0) as int,
      reminder: d['reminder'] ?? false,
      frequency: d['frequency'] ?? 'Daily',
      weekdays: d['weekdays'] != null ? List<int>.from(d['weekdays']) : null,
      notes: d['notes'] ?? '',
      createdAt: d['createdAt'],
      notificationIds:
          d['notificationIds'] != null ? List<int>.from(d['notificationIds']) : null,
      missedCount: (d['missedCount'] ?? 0) as int,
      lastTaken: d['lastTaken'],
    );
  }
}