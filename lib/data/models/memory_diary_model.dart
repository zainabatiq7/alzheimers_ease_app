import 'package:cloud_firestore/cloud_firestore.dart';

enum DiaryEntryType { moment, dailyCheckin }

class DiaryEntry {
  final String id;
  final DiaryEntryType type;
  final DateTime timestamp;
  final String? textCaption;
  final List<String> photoUrls;
  final String? voiceAudioUrl;
  final List<String> taggedPeopleIds;
  final String authorRole; // 'patient' or 'caregiver'

  // Today View specific optional fields
  final String? mood;
  final String? outfit;
  final String? meals;

  DiaryEntry({
    required this.id,
    required this.type,
    required this.timestamp,
    this.textCaption,
    this.photoUrls = const [],
    this.voiceAudioUrl,
    this.taggedPeopleIds = const [],
    required this.authorRole,
    this.mood,
    this.outfit,
    this.meals,
  });

  Map<String, dynamic> toMap() {
    return {
      'type': type.name,
      'timestamp': Timestamp.fromDate(timestamp),
      'textCaption': textCaption,
      'photoUrls': photoUrls,
      'voiceAudioUrl': voiceAudioUrl,
      'taggedPeopleIds': taggedPeopleIds,
      'authorRole': authorRole,
      'mood': mood,
      'outfit': outfit,
      'meals': meals,
    };
  }

  factory DiaryEntry.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DiaryEntry(
      id: doc.id,
      type: DiaryEntryType.values.firstWhere(
            (e) => e.name == data['type'],
        orElse: () => DiaryEntryType.moment,
      ),
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      textCaption: data['textCaption'],
      photoUrls: List<String>.from(data['photoUrls'] ?? []),
      voiceAudioUrl: data['voiceAudioUrl'],
      taggedPeopleIds: List<String>.from(data['taggedPeopleIds'] ?? []),
      authorRole: data['authorRole'] ?? 'patient',
      mood: data['mood'],
      outfit: data['outfit'],
      meals: data['meals'],
    );
  }
}

class VisitLog {
  final String id;
  final String personId;
  final String personName;
  final String relationship;
  final DateTime timestamp;
  final String? togetherPhotoUrl;

  VisitLog({
    required this.id,
    required this.personId,
    required this.personName,
    required this.relationship,
    required this.timestamp,
    this.togetherPhotoUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'personId': personId,
      'personName': personName,
      'relationship': relationship,
      'timestamp': Timestamp.fromDate(timestamp),
      'togetherPhotoUrl': togetherPhotoUrl,
    };
  }

  factory VisitLog.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return VisitLog(
      id: doc.id,
      personId: data['personId'] ?? '',
      personName: data['personName'] ?? '',
      relationship: data['relationship'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      togetherPhotoUrl: data['togetherPhotoUrl'],
    );
  }
}