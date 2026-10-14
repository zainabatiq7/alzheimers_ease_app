import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:alzhimers_ease/l10n/app_localizations.dart';

import 'care_plan_manager.dart';
import '../enrolled_people_screen.dart';
import '../caregiver_map_screen.dart';
import 'package:alzhimers_ease/presentation/screen/chat_screen.dart';
import 'package:alzhimers_ease/presentation/screen/call_screen.dart';
import 'package:alzhimers_ease/data/services/call_service.dart';

class PatientControlDeckScreen extends StatefulWidget {
  final Map<String, dynamic> patientData;

  const PatientControlDeckScreen({super.key, required this.patientData});

  @override
  State<PatientControlDeckScreen> createState() =>
      _PatientControlDeckScreenState();
}

class _PatientControlDeckScreenState extends State<PatientControlDeckScreen> {
  final CallService _callService = CallService();
  StreamSubscription? _callSubscription;
  bool _isDialogShowing = false;

  @override
  void initState() {
    super.initState();
    _listenForIncomingCalls();
  }

  /// Listen for real-time call events from Firestore
  void _listenForIncomingCalls() {
    final String patientId = widget.patientData['patientId'] ?? '';
    final String patientName = widget.patientData['name'] ?? 'Patient';

    if (patientId.isEmpty) return;

    _callSubscription =
        _callService.listenToCall(patientId).listen((snapshot) {
          if (!snapshot.exists) return;

          final data = snapshot.data();
          if (data == null) return;

          final String status = data['status'] ?? '';
          final String channelName = data['channelName'] ?? '';
          final String callerName = data['callerName'] ?? patientName;
          final bool isVideoCall = data['isVideoCall'] ?? true;

          // If patient is calling the caregiver
          if (status == 'calling' &&
              callerName != 'Caregiver' &&
              mounted &&
              !_isDialogShowing) {
            _isDialogShowing = true;
            _callService.playRingtone();
            _showIncomingCallDialog(
                patientId, channelName, callerName, isVideoCall);
          } else if (status == 'ended' && _isDialogShowing) {
            _callService.stopRingtone();
            if (mounted && Navigator.canPop(context)) {
              Navigator.pop(context);
            }
            _isDialogShowing = false;
          }
        });
  }

  /// Show popup dialog when the patient calls the caregiver
  void _showIncomingCallDialog(
      String patientId,
      String channelName,
      String callerName,
      bool isVideoCall,
      ) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: theme.cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: theme.dividerColor, width: 1),
        ),
        title: Text(
          isVideoCall ? loc.incomingVideoCall : loc.incomingAudioCall,
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
              backgroundColor: colorScheme.primary.withValues(alpha: 0.15),
              child: Icon(Icons.person, size: 40, color: colorScheme.primary),
            ),
            const SizedBox(height: 12),
            Text(
              loc.isCalling(callerName),
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
            heroTag: "decline_cg_deck_call",
            backgroundColor: Colors.redAccent,
            elevation: 0,
            onPressed: () async {
              _isDialogShowing = false;
              final dialogNav = Navigator.of(dialogContext);
              await _callService.endCall(patientId);
              dialogNav.pop();
            },
            child: const Icon(Icons.call_end, color: Colors.white),
          ),
          FloatingActionButton(
            heroTag: "accept_cg_deck_call",
            backgroundColor: Colors.green,
            elevation: 0,
            onPressed: () async {
              _isDialogShowing = false;
              final rootNav = Navigator.of(context);
              final dialogNav = Navigator.of(dialogContext);

              await _callService.acceptCall(patientId);
              dialogNav.pop();

              rootNav.push(
                MaterialPageRoute(
                  builder: (context) => CallScreen(
                    channelName: channelName,
                    patientId: patientId,
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

  /// Helper method to initiate an outgoing call to the patient
  void _startCall(String patientId, bool isVideoCall) async {
    final channelId =
        "call_${patientId}_${DateTime.now().millisecondsSinceEpoch}";

    await _callService.makeCall(
      patientId: patientId,
      callerName: "Caregiver",
      isVideoCall: isVideoCall,
      channelName: channelId,
    );

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CallScreen(
          channelName: channelId,
          patientId: patientId,
          isVideoCall: isVideoCall,
          isOutgoing: true,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _callSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final String patientId = widget.patientData['patientId'] ?? '';
    final String patientName =
        widget.patientData['name'] ?? loc.defaultPatientRole;

    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          loc.controlDeckTitle(patientName),
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
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
              // SECTION TITLE
              Padding(
                padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
                child: Text(
                  loc.todaysProgressTracker.toUpperCase(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                    color: colorScheme.primary,
                  ),
                ),
              ),

              // PROGRESS TRACKER CARD
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('patients')
                    .doc(patientId)
                    .collection('schedule')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Card(
                      elevation: 0,
                      color: theme.cardColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: theme.dividerColor, width: 1.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: colorScheme.primary,
                          ),
                        ),
                      ),
                    );
                  }

                  final docs = snapshot.data?.docs ?? [];
                  final int totalTasks = docs.length;
                  final int completedTasks = docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return data['isCompleted'] == true;
                  }).length;

                  final double progressPercent =
                  totalTasks > 0 ? (completedTasks / totalTasks) : 0.0;

                  return Card(
                    elevation: 0,
                    color: theme.cardColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: colorScheme.primary.withValues(alpha: 0.25),
                        width: 1.0,
                      ),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.03),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                width: 58,
                                height: 58,
                                child: CircularProgressIndicator(
                                  value: progressPercent,
                                  strokeWidth: 6,
                                  backgroundColor:
                                  colorScheme.primary.withValues(alpha: 0.12),
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    colorScheme.primary,
                                  ),
                                ),
                              ),
                              Text(
                                "${(progressPercent * 100).toInt()}%",
                                style: textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  totalTasks == 0
                                      ? loc.noTasksAssignedToday
                                      : completedTasks == totalTasks
                                      ? loc.allTasksFinished
                                      : loc.patientTaskTracking,
                                  style: textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  totalTasks == 0
                                      ? loc.tapCarePlanToAddTasks
                                      : loc.completedTasksSummary(
                                      completedTasks, totalTasks),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),

              // SECTION TITLE
              Padding(
                padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
                child: Text(
                  loc.managementModules.toUpperCase(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                    color: colorScheme.primary,
                  ),
                ),
              ),

              // GRID MANAGEMENT MODULES
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.9,
                children: [
                  _buildMenuCard(
                    context,
                    Icons.calendar_today_rounded,
                    Colors.purple,
                    loc.dailyCarePlan,
                    loc.updateMedsAndTasks,
                        () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              CarePlanManagerScreen(patientId: patientId),
                        ),
                      );
                    },
                  ),
                  _buildMenuCard(
                    context,
                    Icons.face_retouching_natural_rounded,
                    Colors.indigo,
                    loc.enrolledPeople,
                    loc.manageFaceDatabase,
                        () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              EnrolledPeopleScreen(patientId: patientId),
                        ),
                      );
                    },
                  ),
                  _buildMenuCard(
                    context,
                    Icons.chat_bubble_outline_rounded,
                    Colors.orange,
                    loc.oneToOneChat,
                    loc.textAndVoiceSupport,
                        () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(
                            patientId: patientId,
                            currentUserRole: 'caregiver',
                            title: loc.chatWithPatientTitle(patientName),
                          ),
                        ),
                      );
                    },
                  ),
                  _buildMenuCard(
                    context,
                    Icons.videocam_rounded,
                    Colors.teal,
                    loc.videoCall,
                    loc.connectViaAgora,
                        () => _startCall(patientId, true),
                  ),
                  _buildMenuCard(
                    context,
                    Icons.phone_rounded,
                    Colors.blue,
                    loc.audioCall,
                    loc.directVoiceLink,
                        () => _startCall(patientId, false),
                  ),
                  _buildMenuCard(
                    context,
                    Icons.my_location_rounded,
                    Colors.green,
                    loc.liveGpsSafety,
                    loc.geofencingAndAlerts,
                        () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CaregiverMapScreen(
                            patientId: patientId,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard(
      BuildContext context,
      IconData icon,
      Color color,
      String title,
      String subtitle,
      VoidCallback onTap,
      ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDarkMode = theme.brightness == Brightness.dark;

    return Card(
      elevation: 0,
      color: theme.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: colorScheme.primary.withValues(alpha: 0.15),
          width: 1.0,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: isDarkMode ? 0.2 : 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 28, color: color),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}