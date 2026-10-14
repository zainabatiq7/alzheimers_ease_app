import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageType { text, voice }

class ChatMessageModel {
  final String id;
  final String senderId;
  final String text;
  final String? audioUrl;
  final MessageType type;
  final DateTime timestamp;

  ChatMessageModel({
    required this.id,
    required this.senderId,
    required this.text,
    this.audioUrl,
    required this.type,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'text': text,
      'audioUrl': audioUrl,
      'type': type == MessageType.voice ? 'voice' : 'text',
      'timestamp': FieldValue.serverTimestamp(),
    };
  }

  factory ChatMessageModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatMessageModel(
      id: doc.id,
      senderId: data['senderId'] ?? '',
      text: data['text'] ?? '',
      audioUrl: data['audioUrl'],
      type: data['type'] == 'voice' ? MessageType.voice : MessageType.text,
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}