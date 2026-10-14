import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:alzhimers_ease/data/models/memory_diary_model.dart';

class MemoryDiaryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection reference helpers
  CollectionReference _diaryCollection(String patientId) {
    return _firestore
        .collection('patients')
        .doc(patientId)
        .collection('diary_entries');
  }

  CollectionReference _visitCollection(String patientId) {
    return _firestore
        .collection('patients')
        .doc(patientId)
        .collection('visit_logs');
  }

  // 1. Add Beautiful Moment or Today View entry
  Future<void> addDiaryEntry(String patientId, DiaryEntry entry) async {
    await _diaryCollection(patientId).add(entry.toMap());
  }

  // Delete Diary Entry
  Future<void> deleteDiaryEntry(String patientId, String entryId) async {
    await _diaryCollection(patientId).doc(entryId).delete();
  }

  // Stream of Diary Entries for Patient/Caregiver Timeline
  Stream<List<DiaryEntry>> getDiaryEntries(String patientId) {
    return _diaryCollection(patientId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => DiaryEntry.fromFirestore(doc)).toList());
  }

  // 2. Add or Update Visit Log (Deduplication Logic: Max 1 log per person per day)
  Future<void> recordVisit({
    required String patientId,
    required String personId,
    required String personName,
    required String relationship,
    String? togetherPhotoUrl,
  }) async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    // Query for existing visit today for this person
    final query = await _visitCollection(patientId)
        .where('personId', isEqualTo: personId)
        .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('timestamp', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
        .get();

    if (query.docs.isNotEmpty) {
      // Update timestamp of existing log for today
      final docId = query.docs.first.id;
      final updateData = <String, dynamic>{
        'timestamp': FieldValue.serverTimestamp(),
      };
      if (togetherPhotoUrl != null) {
        updateData['togetherPhotoUrl'] = togetherPhotoUrl;
      }
      await _visitCollection(patientId).doc(docId).update(updateData);
    } else {
      // Create new visit entry for today
      final newVisit = VisitLog(
        id: '',
        personId: personId,
        personName: personName,
        relationship: relationship,
        timestamp: now,
        togetherPhotoUrl: togetherPhotoUrl,
      );
      await _visitCollection(patientId).add(newVisit.toMap());
    }
  }

  /// Direct wrapper method for screens calling `addVisitLog`
  Future<void> addVisitLog(String patientId, VisitLog visitLog) async {
    await recordVisit(
      patientId: patientId,
      personId: visitLog.personId,
      personName: visitLog.personName,
      relationship: visitLog.relationship,
      togetherPhotoUrl: visitLog.togetherPhotoUrl,
    );
  }

  // Stream of Visit Logs
  Stream<List<VisitLog>> getVisitLogs(String patientId) {
    return _visitCollection(patientId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => VisitLog.fromFirestore(doc)).toList());
  }
}