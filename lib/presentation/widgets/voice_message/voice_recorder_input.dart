import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VoiceRecorderInput extends StatefulWidget {
  final String chatId;
  final String currentUserId;

  const VoiceRecorderInput({
    super.key,
    required this.chatId,
    required this.currentUserId,
  });

  @override
  State<VoiceRecorderInput> createState() => _VoiceRecorderInputState();
}

class _VoiceRecorderInputState extends State<VoiceRecorderInput> {
  late final AudioRecorder _audioRecorder;
  bool _isRecording = false;
  bool _isUploading = false;

  Timer? _timer;
  int _recordDuration = 0;

  @override
  void initState() {
    super.initState();
    _audioRecorder = AudioRecorder();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioRecorder.dispose();
    super.dispose();
  }

  void _startTimer() {
    _recordDuration = 0;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      if (mounted) {
        setState(() {
          _recordDuration++;
        });
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
  }

  String _formatDuration(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final remainingSeconds = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$remainingSeconds';
  }

  Future<void> _startRecording() async {
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Microphone permission is required to record audio.'),
          ),
        );
      }
      return;
    }

    if (await _audioRecorder.hasPermission()) {
      final Directory tempDir = await getTemporaryDirectory();
      final String filePath =
          '${tempDir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';

      await _audioRecorder.start(
        const RecordConfig(encoder: AudioEncoder.aacLc),
        path: filePath,
      );

      setState(() {
        _isRecording = true;
      });
      _startTimer();
    }
  }

  Future<void> _stopAndSendRecording() async {
    if (!_isRecording) return;

    _stopTimer();
    final String? path = await _audioRecorder.stop();

    setState(() {
      _isRecording = false;
    });

    if (path != null && File(path).existsSync()) {
      if (_recordDuration < 1) {
        await File(path).delete();
        return;
      }
      await _uploadAndSendMessage(File(path), _recordDuration);
    }
  }

  Future<void> _uploadAndSendMessage(File audioFile, int durationInSeconds) async {
    setState(() {
      _isUploading = true;
    });

    try {
      final String fileName =
          'voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
      final Reference storageRef = FirebaseStorage.instance
          .ref()
          .child('chat_voices')
          .child(widget.chatId)
          .child(fileName);

      final UploadTask uploadTask = storageRef.putFile(audioFile);
      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      await FirebaseFirestore.instance
          .collection('patients')
          .doc(widget.chatId)
          .collection('chats')
          .add({
        'senderRole': widget.currentUserId,
        'senderId': widget.currentUserId,
        'type': 'voice',
        'mediaUrl': downloadUrl,
        'audioUrl': downloadUrl,
        'duration': durationInSeconds,
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (await audioFile.exists()) {
        await audioFile.delete();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send voice message: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
          _recordDuration = 0;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (_isUploading) {
      return const SizedBox(
        width: 42,
        height: 42,
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: CircularProgressIndicator(strokeWidth: 2.5),
        ),
      );
    }

    return GestureDetector(
      onLongPressStart: (_) => _startRecording(),
      onLongPressEnd: (_) => _stopAndSendRecording(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: _isRecording ? 12 : 0,
        ),
        height: 42,
        width: _isRecording ? 100 : 42,
        decoration: BoxDecoration(
          color: _isRecording ? Colors.red.shade600 : colorScheme.primary,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _isRecording ? Icons.mic : Icons.mic_rounded,
              color: Colors.white,
              size: 20,
            ),
            if (_isRecording) ...[
              const SizedBox(width: 6),
              Text(
                _formatDuration(_recordDuration),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}