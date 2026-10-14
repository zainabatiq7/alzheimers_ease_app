import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Top-level background message handler
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint("Handling background notification: ${message.messageId}");
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'alzheimers_ease_channel',
    'Caregiver Alerts',
    description: 'Important alerts for patient and caregiver safety',
    importance: Importance.max,
  );

  /// Initialize notification channels, settings, and foreground options
  Future<void> initialize({Function(String?)? onNotificationClick}) async {
    // Request system permissions
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    // Ensure foreground notifications display heads-up alerts on iOS
    await _firebaseMessaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // Create Android Notification Channel
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
    _notificationsPlugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      await androidImplementation.createNotificationChannel(_channel);
    }

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (onNotificationClick != null) {
          onNotificationClick(response.payload);
        }
      },
    );

    // Auto-refresh token if updated by FCM
    _firebaseMessaging.onTokenRefresh.listen((newToken) {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        saveDeviceToken(userId: currentUser.uid);
      }
    });
  }

  /// Save FCM device token to both `users` and specific role collections (`patients`/`caregivers`)
  Future<void> saveDeviceToken({String? userId, String? userType}) async {
    try {
      String? token = await _firebaseMessaging.getToken();
      String? targetUserId = userId ?? FirebaseAuth.instance.currentUser?.uid;

      if (token != null && targetUserId != null && targetUserId.isNotEmpty) {
        Map<String, dynamic> updateData = {
          'fcmToken': token,
          'lastTokenUpdate': FieldValue.serverTimestamp(),
        };

        if (userType != null) {
          updateData['userType'] = userType;
        }

        // 1. Update general users collection
        await FirebaseFirestore.instance
            .collection('users')
            .doc(targetUserId)
            .set(updateData, SetOptions(merge: true));

        // 2. Dual-write to specific role collection if specified
        if (userType != null && userType.isNotEmpty) {
          await FirebaseFirestore.instance
              .collection(userType)
              .doc(targetUserId)
              .set({'fcmToken': token, 'lastTokenUpdate': FieldValue.serverTimestamp()}, SetOptions(merge: true));
        }
      }
    } catch (e) {
      debugPrint("Error saving FCM token: $e");
    }
  }

  /// Start foreground notification listener
  void initNotificationListeners([dynamic contextOrHandler]) {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;

      if (notification != null) {
        showNotification(
          id: notification.hashCode,
          title: notification.title ?? '',
          body: notification.body ?? '',
          payload: jsonEncode(message.data),
        );
      }
    });
  }

  /// Send push notification to a recipient user by writing a dispatch record to Firestore.
  /// (This triggers Firebase Cloud Functions or alerts the receiver's listener)
  Future<void> sendNotificationToUser({
    String? recipientId,
    String? recipientType,
    required String title,
    required String body,
    Map<String, dynamic>? extraData,
  }) async {
    try {
      if (recipientId == null || recipientId.isEmpty) return;

      String targetCollection = recipientType ?? 'users';

      // Look up recipient token
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection(targetCollection)
          .doc(recipientId)
          .get();

      if (!userDoc.exists) {
        // Fallback to 'users' collection search
        userDoc = await FirebaseFirestore.instance.collection('users').doc(recipientId).get();
      }

      if (!userDoc.exists) return;

      String? recipientToken = userDoc.get('fcmToken');
      if (recipientToken == null || recipientToken.isEmpty) return;

      // Queue push notification document in Firestore for backend worker/Cloud Function processing
      await FirebaseFirestore.instance.collection('notifications_queue').add({
        'recipientId': recipientId,
        'fcmToken': recipientToken,
        'title': title,
        'body': body,
        'data': extraData ?? {},
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'pending',
      });

      debugPrint("Notification queued successfully for user: $recipientId");
    } catch (e) {
      debugPrint("Error dispatching notification: $e");
    }
  }

  /// Display a local banner notification
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      _channel.id,
      _channel.name,
      channelDescription: _channel.description,
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.show(
      id,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }
}