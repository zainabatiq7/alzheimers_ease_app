import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:alzhimers_ease/data/services/notification_service.dart';

class CallService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AudioPlayer _audioPlayer = AudioPlayer();
  final NotificationService _notificationService = NotificationService();

  /// Play ringtone sound continuously for incoming calls (.mp3)
  Future<void> playRingtone() async {
    try {
      await _audioPlayer.stop();
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer.play(AssetSource('audio/ringtone.mp3'));
    } catch (e) {
      debugPrint("Error playing ringtone: $e");
    }
  }

  /// Play calling/dialing sound ("tuuun tuuun") for outgoing calls (.mp3)
  Future<void> playCallingTone() async {
    try {
      await _audioPlayer.stop();
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer.play(AssetSource('audio/calling.mp3'));
    } catch (e) {
      debugPrint("Error playing calling sound: $e");
    }
  }

  /// Stop any active audio (ringtone or calling sound)
  Future<void> stopRingtone() async {
    try {
      await _audioPlayer.stop();
    } catch (e) {
      debugPrint("Error stopping audio: $e");
    }
  }

  /// Caregiver or Patient initiates a call
  Future<void> makeCall({
    required String patientId,
    required String callerName,
    required bool isVideoCall,
    required String channelName,
    String? receiverId,
    String receiverType = 'caregivers',
  }) async {
    final String currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';

    await _firestore.collection('calls').doc(patientId).set({
      'channelName': channelName.trim(),
      'patientId': patientId,
      'callerName': callerName,
      'callerUid': currentUid, // <-- CRITICAL FIX: Track caller UID
      'isVideoCall': isVideoCall,
      'status': 'calling', // Statuses: calling, accepted, ended
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Send push notification for incoming call
    if (receiverId != null && receiverId.isNotEmpty) {
      final callType = isVideoCall ? "Video Call" : "Audio Call";
      await _notificationService.sendNotificationToUser(
        recipientId: receiverId,
        recipientType: receiverType,
        title: "Incoming $callType 📞",
        body: "$callerName is calling you. Tap to join!",
      );
    }
  }

  /// Trigger push notification when a call is not answered
  Future<void> sendMissedCallNotification({
    required String? receiverId,
    required String receiverType,
    required bool isVideoCall,
    required String callerName,
  }) async {
    if (receiverId == null || receiverId.isEmpty) return;

    final callType = isVideoCall ? "Video Call" : "Audio Call";
    await _notificationService.sendNotificationToUser(
      recipientId: receiverId,
      recipientType: receiverType,
      title: "Missed $callType 📞",
      body: "You missed a call from $callerName.",
    );
  }

  /// Accept call
  Future<void> acceptCall(String patientId) async {
    await stopRingtone();
    await _firestore.collection('calls').doc(patientId).update({
      'status': 'accepted',
    });
  }

  /// Decline or End call
  Future<void> endCall(String patientId) async {
    await stopRingtone();
    await _firestore.collection('calls').doc(patientId).update({
      'status': 'ended',
    });
  }

  /// Real-time stream to listen for calls for a specific patient ID
  Stream<DocumentSnapshot<Map<String, dynamic>>> listenToCall(String patientId) {
    return _firestore.collection('calls').doc(patientId).snapshots();
  }
}