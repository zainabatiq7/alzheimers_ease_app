import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';

import 'package:alzhimers_ease/l10n/app_localizations.dart';
import 'package:alzhimers_ease/presentation/widgets/dynamic_translated_text.dart';
import 'package:alzhimers_ease/presentation/screen/who_is_this_screen.dart';
import 'package:alzhimers_ease/presentation/screen/patient_return_route_screen.dart';
import 'package:alzhimers_ease/presentation/screen/chat_screen.dart';
import 'package:alzhimers_ease/presentation/screen/call_screen.dart';
import 'package:alzhimers_ease/presentation/screen/memory_diary/memory_diary_home_screen.dart';

import 'package:alzhimers_ease/data/services/location_service.dart';
import 'package:alzhimers_ease/data/services/call_service.dart';
import 'package:alzhimers_ease/data/services/notification_service.dart';
import 'package:alzhimers_ease/provider/settings_provider.dart';

class PatientDashboard extends StatefulWidget {
  final String patientId;

  const PatientDashboard({super.key, required this.patientId});

  @override
  State<PatientDashboard> createState() => _PatientDashboardState();
}

class _PatientDashboardState extends State<PatientDashboard> {
  final LocationService _locationService = LocationService();
  final CallService _callService = CallService();
  StreamSubscription? _callSubscription;
  bool _isDialogShowing = false;
  String _caregiverPhone = '';

  @override
  void initState() {
    super.initState();
    _ensureFirebaseAuthSession();
  }

  Future<void> _ensureFirebaseAuthSession() async {
    try {
      if (FirebaseAuth.instance.currentUser == null) {
        await FirebaseAuth.instance.signInAnonymously();
      }
    } catch (e) {
      debugPrint("Silent Firebase Auth error: $e");
    } finally {
      if (mounted) {
        Provider.of<SettingsProvider>(context, listen: false)
            .initializeFirestoreSync(widget.patientId);

        _savePatientDeviceToken();
        NotificationService().initNotificationListeners(context);
        _startBackgroundLocationService();
        _listenForIncomingCalls();
        _fetchCaregiverPhone();
      }
    }
  }

  void _savePatientDeviceToken() {
    NotificationService().saveDeviceToken(
      userId: widget.patientId,
      userType: 'patients',
    );
  }

  Future<void> _fetchCaregiverPhone() async {
    if (widget.patientId.isEmpty) return;
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('patients')
          .doc(widget.patientId)
          .get();

      if (doc.exists && doc.data() != null && mounted) {
        var data = doc.data() as Map<String, dynamic>;
        setState(() {
          _caregiverPhone =
              data['caregiverPhone'] ?? data['emergencyPhone'] ?? '';
        });
      }
    } catch (e) {
      debugPrint("Error fetching caregiver phone: $e");
    }
  }

  void _listenForIncomingCalls() {
    if (widget.patientId.isEmpty) return;
    _callSubscription =
        _callService.listenToCall(widget.patientId).listen((snapshot) {
          if (!snapshot.exists) return;

          final data = snapshot.data();
          if (data == null) return;

          final String status = data['status'] ?? '';
          final String channelName = data['channelName'] ?? '';
          final String callerName = data['callerName'] ?? 'Caregiver';
          final bool isVideoCall = data['isVideoCall'] ?? true;

          if (status == 'calling' && mounted && !_isDialogShowing) {
            _isDialogShowing = true;
            _callService.playRingtone();
            _showIncomingCallDialog(channelName, callerName, isVideoCall);
          } else if (status == 'ended' && _isDialogShowing) {
            _callService.stopRingtone();
            if (mounted && Navigator.canPop(context)) {
              Navigator.pop(context);
            }
            _isDialogShowing = false;
          }
        });
  }

  void _showIncomingCallDialog(
      String channelName, String callerName, bool isVideoCall) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: theme.cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: colorScheme.primary.withValues(alpha: 0.2),
          ),
        ),
        title: Text(
          isVideoCall ? l10n.incomingVideoCall : l10n.incomingAudioCall,
          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 36,
              backgroundColor: colorScheme.primaryContainer,
              child: Icon(
                Icons.person,
                size: 40,
                color: colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.callerIsCalling(callerName),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          FloatingActionButton(
            heroTag: "decline_call",
            backgroundColor: colorScheme.error,
            elevation: 0,
            onPressed: () async {
              _isDialogShowing = false;
              final dialogNavigator = Navigator.of(dialogContext);
              await _callService.endCall(widget.patientId);
              dialogNavigator.pop();
            },
            child: Icon(Icons.call_end, color: colorScheme.onError),
          ),
          FloatingActionButton(
            heroTag: "accept_call",
            backgroundColor: Colors.green,
            elevation: 0,
            onPressed: () async {
              _isDialogShowing = false;
              final rootNavigator = Navigator.of(context);
              final dialogNavigator = Navigator.of(dialogContext);

              await _callService.acceptCall(widget.patientId);
              dialogNavigator.pop();

              rootNavigator.push(
                MaterialPageRoute(
                  builder: (context) => CallScreen(
                    channelName: channelName,
                    patientId: widget.patientId,
                    isVideoCall: isVideoCall,
                    isOutgoing: false,
                  ),
                ),
              );
            },
            child: const Icon(Icons.call, color: Colors.white),
          ),
        ],
      ),
    );
  }

  void _startBackgroundLocationService() async {
    if (widget.patientId.isEmpty) return;
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('patients')
          .doc(widget.patientId)
          .get();

      if (doc.exists && doc.data() != null) {
        var data = doc.data() as Map<String, dynamic>;
        var safeZone = data['safeZone'] ?? {};

        double homeLat = (safeZone['latitude'] as num?)?.toDouble() ?? 31.5204;
        double homeLng = (safeZone['longitude'] as num?)?.toDouble() ?? 74.3587;
        double radius = (safeZone['radiusMeters'] as num?)?.toDouble() ?? 200.0;

        _locationService.startPatientLocationStream(
          patientId: widget.patientId,
          safeZoneLat: homeLat,
          safeZoneLng: homeLng,
          safeZoneRadiusMeters: radius,
        );
      }
    } catch (e) {
      debugPrint("Error initializing location stream: $e");
    }
  }

  @override
  void dispose() {
    _callSubscription?.cancel();
    _locationService.stopLocationStream();
    super.dispose();
  }

  Future<void> _toggleTaskStatus(
      String docId, bool currentStatus, List<QueryDocumentSnapshot> allTasks) async {
    if (widget.patientId.isEmpty) return;
    final batch = FirebaseFirestore.instance.batch();

    final taskRef = FirebaseFirestore.instance
        .collection('patients')
        .doc(widget.patientId)
        .collection('schedule')
        .doc(docId);

    final bool nextStatus = !currentStatus;
    batch.update(taskRef, {'isCompleted': nextStatus});

    String taskTitle = "Completed a task";
    final targetDoc = allTasks.cast<QueryDocumentSnapshot?>().firstWhere(
          (doc) => doc?.id == docId,
      orElse: () => null,
    );
    if (targetDoc != null) {
      final targetData = targetDoc.data() as Map<String, dynamic>;
      taskTitle = targetData['task'] ?? taskTitle;
    }

    int pendingCount = allTasks.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      if (doc.id == docId) return nextStatus == false;
      return (data['isCompleted'] ?? false) == false;
    }).length;

    final patientRef =
    FirebaseFirestore.instance.collection('patients').doc(widget.patientId);

    batch.set(
      patientRef,
      {
        'lastActionTime': FieldValue.serverTimestamp(),
        'pendingTasks': pendingCount,
        'lastCompletedTask': nextStatus ? taskTitle : "Unchecked a task",
      },
      SetOptions(merge: true),
    );

    await batch.commit();
  }

  Future<void> _exitToRoleSelection(BuildContext context) async {
    _locationService.stopLocationStream();
    await FirebaseAuth.instance.signOut();

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_role');

    if (context.mounted) {
      Navigator.of(context)
          .pushNamedAndRemoveUntil('/welcome', (route) => false);
    }
  }

  void _navigateToReturnRoute() async {
    final l10n = AppLocalizations.of(context)!;
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('patients')
          .doc(widget.patientId)
          .get();

      if (!mounted) return;

      if (doc.exists) {
        var data = doc.data() as Map<String, dynamic>;
        var liveLocation = data['liveLocation'] ?? {};
        var safeZone = data['safeZone'] ?? {};

        double currentLat =
            (liveLocation['latitude'] as num?)?.toDouble() ?? 31.5204;
        double currentLng =
            (liveLocation['longitude'] as num?)?.toDouble() ?? 74.3587;
        double homeLat = (safeZone['latitude'] as num?)?.toDouble() ?? 31.5204;
        double homeLng = (safeZone['longitude'] as num?)?.toDouble() ?? 74.3587;

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PatientReturnRouteScreen(
              currentLat: currentLat,
              currentLng: currentLng,
              homeLat: homeLat,
              homeLng: homeLng,
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${l10n.errorLaunchingDirections}: $e")),
      );
    }
  }

  void _startCall(bool isVideoCall) async {
    final channelId =
        "call_${widget.patientId}_${DateTime.now().millisecondsSinceEpoch}";

    await _callService.makeCall(
      patientId: widget.patientId,
      callerName: "Patient",
      isVideoCall: isVideoCall,
      channelName: channelId,
    );

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CallScreen(
          channelName: channelId,
          patientId: widget.patientId,
          isVideoCall: isVideoCall,
          isOutgoing: true,
        ),
      ),
    );
  }

  Future<void> _triggerSOS() async {
    try {
      await FirebaseFirestore.instance
          .collection('patients')
          .doc(widget.patientId)
          .collection('alerts')
          .add({
        'type': 'EMERGENCY_SOS',
        'message': 'Patient triggered an emergency SOS alert!',
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
      });

      if (!mounted) return;

      String targetPhone = '';

      final contactsSnapshot = await FirebaseFirestore.instance
          .collection('patients')
          .doc(widget.patientId)
          .collection('emergency_contacts')
          .limit(1)
          .get();

      if (!mounted) return;

      if (contactsSnapshot.docs.isNotEmpty) {
        final data = contactsSnapshot.docs.first.data();
        targetPhone = data['phoneNumber'] ?? data['phone'] ?? '';
      }

      if (targetPhone.isEmpty) {
        final settings = Provider.of<SettingsProvider>(context, listen: false);
        if (settings.emergencyContacts.isNotEmpty) {
          targetPhone = settings.emergencyContacts.first.phone;
        } else {
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          targetPhone =
              prefs.getString('emergency_contact_phone') ?? _caregiverPhone;
        }
      }

      if (targetPhone.trim().isNotEmpty) {
        final Uri telUri = Uri(scheme: 'tel', path: targetPhone.trim());
        if (await canLaunchUrl(telUri)) {
          await launchUrl(telUri);
          return;
        }
      }

      _startCall(false);
    } catch (e) {
      debugPrint("Error sending SOS alert: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final String currentLang = Localizations.localeOf(context).languageCode;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          l10n.myDailyHub,
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(Icons.logout_rounded, color: colorScheme.onSurface),
            tooltip: l10n.exitApp,
            onPressed: () => _exitToRoleSelection(context),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.04,
            vertical: 16.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.myTasksToday.toUpperCase(),
                      style: textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                        color: colorScheme.primary,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.calendar_today_rounded,
                        color: colorScheme.onPrimaryContainer,
                        size: 16,
                      ),
                    ),
                  ],
                ),
              ),

              // SCHEDULE TASK STREAM
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('patients')
                    .doc(widget.patientId)
                    .collection('schedule')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Card(
                      elevation: 0,
                      color: theme.cardColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: colorScheme.primary.withValues(alpha: 0.15),
                        ),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(24.0),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    );
                  }

                  final docs = snapshot.data?.docs ?? [];
                  if (docs.isEmpty) {
                    return Card(
                      elevation: 0,
                      color: theme.cardColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: colorScheme.primary.withValues(alpha: 0.15),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.check_circle_outline_rounded,
                              size: 44,
                              color: Colors.green,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              l10n.allTasksDoneToday,
                              style: textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final item = docs[index].data() as Map<String, dynamic>;
                      final bool isDone = item['isCompleted'] ?? false;

                      return Card(
                        elevation: 0,
                        color: isDone
                            ? Colors.green.withValues(alpha: 0.12)
                            : theme.cardColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: isDone
                                ? Colors.green
                                : colorScheme.primary.withValues(alpha: 0.15),
                          ),
                        ),
                        margin: const EdgeInsets.only(bottom: 10),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: colorScheme.primaryContainer,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  item['time'] ?? '',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onPrimaryContainer,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: DynamicTranslatedText(
                                  text: item['task'] ?? '',
                                  targetLanguageCode: currentLang,
                                  style: textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: isDone
                                        ? colorScheme.onSurfaceVariant
                                        : colorScheme.onSurface,
                                    decoration: isDone
                                        ? TextDecoration.lineThrough
                                        : TextDecoration.none,
                                    decorationThickness: 2,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                ),
                              ),
                              Transform.scale(
                                scale: 1.1,
                                child: Checkbox(
                                  value: isDone,
                                  activeColor: Colors.green,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4)),
                                  onChanged: (_) => _toggleTaskStatus(
                                      docs[index].id, isDone, docs),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),

              const SizedBox(height: 24),

              Padding(
                padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
                child: Text(
                  l10n.quickActions.toUpperCase(),
                  style: textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                    color: colorScheme.primary,
                  ),
                ),
              ),

              _buildSosButton(l10n),
              const SizedBox(height: 12),

              _buildRefinedActionButton(
                icon: Icons.navigation_rounded,
                label: l10n.guideMeHome,
                subtitle: l10n.findDirectionsBackHome,
                accentColor: const Color(0xFF059669),
                onTap: _navigateToReturnRoute,
              ),
              const SizedBox(height: 10),

              _buildRefinedActionButton(
                icon: Icons.face_rounded,
                label: l10n.whoIsThis,
                subtitle: l10n.identifyFamilyAndPhotos,
                accentColor: const Color(0xFF4F46E5),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          WhoIsThisScreen(patientId: widget.patientId),
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),

              _buildRefinedActionButton(
                icon: Icons.chat_bubble_outline_rounded,
                label: l10n.talkToMeChat,
                subtitle: l10n.messageYourCaregiver,
                accentColor: Colors.orange,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(
                        patientId: widget.patientId,
                        currentUserRole: 'patient',
                        title: l10n.caregiverChat,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),

              _buildRefinedActionButton(
                icon: Icons.videocam_rounded,
                label: l10n.videoCallCaregiver,
                subtitle: l10n.startFaceToFaceCall,
                accentColor: Colors.teal,
                onTap: () => _startCall(true),
              ),
              const SizedBox(height: 10),

              _buildRefinedActionButton(
                icon: Icons.phone_rounded,
                label: l10n.audioCallCaregiver,
                subtitle: l10n.startVoiceCall,
                accentColor: Colors.blue,
                onTap: () => _startCall(false),
              ),
              const SizedBox(height: 10),

              _buildRefinedActionButton(
                icon: Icons.menu_book_rounded,
                label: l10n.memoryDiary,
                subtitle: l10n.viewJournalEntries,
                accentColor: Colors.purple,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MemoryDiaryHomeScreen(
                        patientId: widget.patientId,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSosButton(AppLocalizations l10n) {
    const sosColor = Color(0xFFDC2626);

    return Container(
      width: double.infinity,
      height: 70,
      decoration: BoxDecoration(
        color: sosColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: sosColor.withValues(alpha: 0.35),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _triggerSOS,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Row(
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  size: 32,
                  color: Colors.white,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.emergencySos,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        l10n.tapToCallPrimaryEmergencyContact,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.phone_forwarded_rounded,
                  color: Colors.white,
                  size: 26,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRefinedActionButton({
    required IconData icon,
    required String label,
    required String subtitle,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Card(
      elevation: 0,
      color: theme.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: colorScheme.primary.withValues(alpha: 0.15),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 24, color: accentColor),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(
                Directionality.of(context) == TextDirection.rtl
                    ? Icons.arrow_back_ios_new_rounded
                    : Icons.arrow_forward_ios_rounded,
                size: 16,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}