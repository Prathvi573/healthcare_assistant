import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:healthcare_assistant/models/medicine.dart';

// This is a private helper class, it is fine
class _OwnerInfo {
  final String userId;
  final int missedCount;
  _OwnerInfo(this.userId, this.missedCount);
}

class FirebaseService {
  FirebaseService._();
  static final instance = FirebaseService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // This function is correct. Renamed for clarity.
  CollectionReference medicinesRefForUser(String userId) =>
      _db.collection('users').doc(userId).collection('medicines');

  // This function is correct
  Future<DocumentReference> addMedicine(String userId, Medicine med) {
    return medicinesRefForUser(userId).add(med.toMap());
  }

  // This function is correct
  Future<void> updateMedicine(String userId, String medId, Map<String, dynamic> data) {
    return medicinesRefForUser(userId).doc(medId).update(data);
  }

  // This function is correct
  Future<void> deleteMedicine(String userId, String medId) {
    return medicinesRefForUser(userId).doc(medId).delete();
  }

  // This function is correct
  Stream<List<Medicine>> streamMedicines(String userId) {
    return medicinesRefForUser(userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => Medicine.fromDoc(d)).toList());
  }

  // This function is correct
  Future<Medicine?> getMedicineById(String userId, String medId) async {
    final doc = await medicinesRefForUser(userId).doc(medId).get();
    if (!doc.exists) return null;
    return Medicine.fromDoc(doc);
  }

  // FIXED: This function is now fast and efficient.
  // It uses a Collection Group Query to find the medicine in one step
  // instead of looping through all users.
  Future<void> incrementMissedCountForMedicineOwner(String medId) async {
    final query = await _db
        .collectionGroup('medicines')
        .where(FieldPath.documentId, isEqualTo: medId)
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      await query.docs.first.reference.update({'missedCount': FieldValue.increment(1)});
    }
  }

  // FIXED: This function is also now fast and efficient.
  Future<_OwnerInfo?> getMedicineOwnerAndMissed(String medId) async {
    final query = await _db
        .collectionGroup('medicines')
        .where(FieldPath.documentId, isEqualTo: medId)
        .limit(1)
        .get();

    if (query.docs.isEmpty) {
      return null; // Medicine not found
    }

    final doc = query.docs.first;
    final data = doc.data();
    
    // Use 'as int' for safety
    final missed = (data['missedCount'] ?? 0) as int;
    
    // Get the parent user ID
    final userId = doc.reference.parent.parent!.id;

    return _OwnerInfo(userId, missed);
  }

  // This function is correct
  Future<void> resetMissedCount(String userId, String medId) async {
    await medicinesRefForUser(userId).doc(medId).update({'missedCount': 0});
  }

  // This function is correct
  Future<void> setLastTaken(String userId, String medId) async {
    await medicinesRefForUser(userId)
        .doc(medId)
        .update({'lastTaken': FieldValue.serverTimestamp(), 'missedCount': 0});
  }
}