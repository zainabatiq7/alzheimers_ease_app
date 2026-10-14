import 'dart:async';
import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:alzhimers_ease/l10n/app_localizations.dart';
import 'package:alzhimers_ease/data/services/call_service.dart';
import 'package:alzhimers_ease/data/services/notification_service.dart';
import 'agora_helper.dart';

class CallScreen extends StatefulWidget {
  final String channelName;
  final String? patientId;
  final String? receiverId; // Recipient UID to send missed call notification
  final String receiverType; // 'caregivers' or 'patients'
  final bool isVideoCall;
  final bool isOutgoing;

  const CallScreen({
    super.key,
    required this.channelName,
    this.patientId,
    this.receiverId,
    this.receiverType = 'caregivers',
    this.isVideoCall = true,
    this.isOutgoing = false,
  });

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  int? _remoteUid;
  bool _localUserJoined = false;
  bool _isCallAnswered = false; // Tracks if the remote user picked up
  late RtcEngine _engine;
  bool _muted = false;
  final CallService _callService = CallService();
  final NotificationService _notificationService = NotificationService();
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _firestoreCallSub;

  @override
  void initState() {
    super.initState();
    _initAgora();
    _listenToFirestoreCallStatus();
  }

  /// Listens to Firestore call status. If the call is marked as 'ended'
  /// by the other phone (e.g. declined/hung up), this phone auto-closes safely.
  void _listenToFirestoreCallStatus() {
    if (widget.patientId != null) {
      _firestoreCallSub = _callService.listenToCall(widget.patientId!).listen((snapshot) {
        if (!snapshot.exists) return;
        final data = snapshot.data();
        if (data != null && data['status'] == 'ended') {
          _closeScreen();
        }
      });
    }
  }

  /// Sends Missed Call Push Notification if call was not answered
  Future<void> _sendMissedCallNotification() async {
    if (widget.isOutgoing && !_isCallAnswered && widget.receiverId != null && widget.receiverId!.isNotEmpty) {
      final loc = AppLocalizations.of(context)!;
      final callType = widget.isVideoCall ? loc.videoCall : loc.audioCall;
      await _notificationService.sendNotificationToUser(
        recipientId: widget.receiverId!,
        recipientType: widget.receiverType,
        title: loc.missedCallTitle(callType),
        body: loc.missedCallBody,
      );
    }
  }

  Future<void> _initAgora() async {
    // 1. Request microphone and camera permissions
    await [
      Permission.microphone,
      if (widget.isVideoCall) Permission.camera,
    ].request();

    // 2. Play dialing/calling tone if this is an outgoing call
    if (widget.isOutgoing) {
      await _callService.playCallingTone();
    }

    // 3. Initialize Agora Engine
    _engine = createAgoraRtcEngine();
    await _engine.initialize(const RtcEngineContext(
      appId: AgoraHelper.appId,
      channelProfile: ChannelProfileType.channelProfileCommunication,
    ));

    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          debugPrint("Local user joined channel: ${connection.channelId}");
          if (mounted) setState(() => _localUserJoined = true);
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          debugPrint("Remote user joined: $remoteUid");
          // Stop ringing/dialing tone as soon as receiver answers
          _callService.stopRingtone();
          if (mounted) {
            setState(() {
              _remoteUid = remoteUid;
              _isCallAnswered = true; // Mark call as answered
            });
          }
        },
        onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
          debugPrint("Remote user left channel");
          if (mounted) {
            setState(() => _remoteUid = null);
            _endCall();
          }
        },
        onError: (ErrorCodeType err, String msg) {
          debugPrint("Agora Error [$err]: $msg");
        },
      ),
    );

    // 4. Configure Audio/Video tracks
    await _engine.enableAudio();
    if (widget.isVideoCall) {
      await _engine.enableVideo();
      await _engine.startPreview();
    } else {
      await _engine.disableVideo();
    }

    // 5. Generate Dynamic Token using helper
    final String token = AgoraHelper.getToken(widget.channelName);

    // 6. Join Channel
    await _engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
    await _engine.joinChannel(
      token: token,
      channelId: widget.channelName.trim(),
      uid: 0,
      options: const ChannelMediaOptions(
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
        publishCameraTrack: true,
        publishMicrophoneTrack: true,
        autoSubscribeAudio: true,
        autoSubscribeVideo: true,
      ),
    );
  }

  /// Triggered when local user taps the red End Call button or call closes
  Future<void> _endCall() async {
    await _sendMissedCallNotification();
    await _callService.stopRingtone();
    if (widget.patientId != null) {
      await _callService.endCall(widget.patientId!);
    }
    _closeScreen();
  }

  /// Safely stops ringtones and pops the screen back to dashboard without !_debugLocked crash
  void _closeScreen() {
    _callService.stopRingtone();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    });
  }

  @override
  void dispose() {
    _firestoreCallSub?.cancel();
    _callService.stopRingtone();
    _engine.leaveChannel();
    _engine.release();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          widget.isVideoCall ? loc.videoCall : loc.audioCall,
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onPrimary,
          ),
        ),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(child: _remoteVideo(loc, colorScheme, textTheme)),
            if (widget.isVideoCall)
              Positioned(
                top: 16,
                left: 16,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: screenWidth * 0.28,
                    height: screenHeight * 0.20,
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      border: Border.all(
                        color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: _localUserJoined
                          ? AgoraVideoView(
                        controller: VideoViewController(
                          rtcEngine: _engine,
                          canvas: const VideoCanvas(uid: 0),
                        ),
                      )
                          : CircularProgressIndicator(color: colorScheme.primary),
                    ),
                  ),
                ),
              ),
            Positioned(
              left: 16,
              right: 16,
              bottom: screenHeight * 0.03,
              child: _toolbar(colorScheme),
            ),
          ],
        ),
      ),
    );
  }

  Widget _remoteVideo(
      AppLocalizations loc,
      ColorScheme colorScheme,
      TextTheme textTheme,
      ) {
    if (_remoteUid != null && widget.isVideoCall) {
      return AgoraVideoView(
        controller: VideoViewController.remote(
          rtcEngine: _engine,
          canvas: VideoCanvas(uid: _remoteUid),
          connection: RtcConnection(channelId: widget.channelName.trim()),
        ),
      );
    } else if (_remoteUid != null && !widget.isVideoCall) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: colorScheme.primaryContainer,
            child: Icon(
              Icons.person,
              size: 60,
              color: colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            loc.callConnected,
            style: textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      );
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: colorScheme.primary),
          const SizedBox(height: 16),
          Text(
            loc.ringingConnecting,
            style: textTheme.bodyLarge?.copyWith(
              color: Colors.white,
            ),
          ),
        ],
      );
    }
  }

  Widget _toolbar(ColorScheme colorScheme) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          RawMaterialButton(
            onPressed: () {
              setState(() => _muted = !_muted);
              _engine.muteLocalAudioStream(_muted);
            },
            shape: const CircleBorder(),
            elevation: 2.0,
            fillColor: _muted ? colorScheme.primary : colorScheme.surface,
            padding: const EdgeInsets.all(12.0),
            child: Icon(
              _muted ? Icons.mic_off : Icons.mic,
              color: _muted ? colorScheme.onPrimary : colorScheme.primary,
              size: 22.0,
            ),
          ),
          const SizedBox(width: 20),
          RawMaterialButton(
            onPressed: _endCall,
            shape: const CircleBorder(),
            elevation: 2.0,
            fillColor: colorScheme.error,
            padding: const EdgeInsets.all(16.0),
            child: Icon(
              Icons.call_end,
              color: colorScheme.onError,
              size: 32.0,
            ),
          ),
          const SizedBox(width: 20),
          if (widget.isVideoCall)
            RawMaterialButton(
              onPressed: () => _engine.switchCamera(),
              shape: const CircleBorder(),
              elevation: 2.0,
              fillColor: colorScheme.surface,
              padding: const EdgeInsets.all(12.0),
              child: Icon(
                Icons.switch_camera,
                color: colorScheme.primary,
                size: 22.0,
              ),
            ),
        ],
      ),
    );
  }
}