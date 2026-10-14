import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:alzhimers_ease/l10n/app_localizations.dart';
import 'package:alzhimers_ease/data/services/notification_service.dart';
import 'package:alzhimers_ease/presentation/widgets/dynamic_translated_text.dart';
import 'package:alzhimers_ease/presentation/widgets/voice_message/voice_recorder_input.dart';
import 'package:alzhimers_ease/presentation/widgets/voice_message/voice_message_bubble.dart';

class ChatScreen extends StatefulWidget {
  final String patientId;
  final String currentUserRole; // 'caregiver' or 'patient'
  final String title;

  const ChatScreen({
    super.key,
    required this.patientId,
    required this.currentUserRole,
    required this.title,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();

  CollectionReference get _chatCollection => FirebaseFirestore.instance
      .collection('patients')
      .doc(widget.patientId)
      .collection('chats');

  @override
  void initState() {
    super.initState();
    _messageController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  // --- 1. TEXT MESSAGE SENDING ---
  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _messageController.clear();

    await _chatCollection.add({
      'text': text,
      'type': 'text',
      'mediaUrl': null,
      'senderRole': widget.currentUserRole,
      'senderId': widget.currentUserRole,
      'timestamp': FieldValue.serverTimestamp(),
    });

    _sendChatNotification(text);
  }

  // --- 2. PUSH NOTIFICATION DISPATCH ---
  Future<void> _sendChatNotification(String messageText) async {
    try {
      final isSenderCaregiver = widget.currentUserRole == 'caregiver';

      final patientDoc = await FirebaseFirestore.instance
          .collection('patients')
          .doc(widget.patientId)
          .get();

      if (!patientDoc.exists || patientDoc.data() == null) return;

      final data = patientDoc.data()!;

      if (isSenderCaregiver) {
        final String recipientId = widget.patientId;
        const String recipientType = 'patients';
        const String notificationTitle = "New message from Caregiver";

        await NotificationService().sendNotificationToUser(
          recipientId: recipientId,
          recipientType: recipientType,
          title: notificationTitle,
          body: messageText,
          extraData: {
            'type': 'chat',
            'patientId': widget.patientId,
            'senderRole': widget.currentUserRole,
          },
        );
      } else {
        List<String> caregiverIds = [];

        if (data['caregiverIds'] != null && data['caregiverIds'] is List) {
          caregiverIds = List<String>.from(data['caregiverIds']);
        }

        final singleCaregiverId = data['caregiverUid'] ?? data['caregiverId'];
        if (singleCaregiverId != null &&
            singleCaregiverId.toString().isNotEmpty &&
            !caregiverIds.contains(singleCaregiverId.toString())) {
          caregiverIds.add(singleCaregiverId.toString());
        }

        final String notificationTitle = "New message from ${widget.title}";

        for (final String caregiverId in caregiverIds) {
          await NotificationService().sendNotificationToUser(
            recipientId: caregiverId,
            recipientType: 'caregivers',
            title: notificationTitle,
            body: messageText,
            extraData: {
              'type': 'chat',
              'patientId': widget.patientId,
              'senderRole': widget.currentUserRole,
            },
          );
        }
      }
    } catch (e) {
      debugPrint("Failed to send chat push notification: $e");
    }
  }

  void _confirmDeleteSingleMessage(String docId) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteMessageTitle),
        content: Text(l10n.deleteMessageConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _chatCollection.doc(docId).delete();
            },
            child: Text(
              l10n.delete,
              style: TextStyle(color: colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmClearChat() {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.clearChatTitle),
        content: Text(l10n.clearChatConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final snapshot = await _chatCollection.get();
              final batch = FirebaseFirestore.instance.batch();
              for (var doc in snapshot.docs) {
                batch.delete(doc.reference);
              }
              await batch.commit();
            },
            child: Text(
              l10n.clearAll,
              style: TextStyle(color: colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final double screenWidth = MediaQuery.of(context).size.width;
    final String currentLang = Localizations.localeOf(context).languageCode;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: DynamicTranslatedText(
          text: widget.title,
          targetLanguageCode: currentLang,
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        centerTitle: false,
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: theme.appBarTheme.foregroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        actions: [
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert,
              color: colorScheme.onSurface,
            ),
            tooltip: l10n.clearChatTitle,
            onSelected: (value) {
              if (value == 'clear_chat') {
                _confirmClearChat();
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<String>(
                value: 'clear_chat',
                child: Row(
                  children: [
                    Icon(
                      Icons.delete_outline,
                      size: 20,
                      color: colorScheme.error,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      l10n.clearChatTitle,
                      style: TextStyle(
                        color: colorScheme.error,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        bottom: true,
        child: Column(
          children: [
            // Chat Stream List
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _chatCollection
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(color: colorScheme.primary),
                    );
                  }

                  final docs = snapshot.data?.docs ?? [];
                  if (docs.isEmpty) {
                    return Center(
                      child: Text(
                        l10n.noMessagesYet,
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 15,
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    reverse: true,
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.04,
                      vertical: 12,
                    ),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final doc = docs[index];
                      final data = doc.data() as Map<String, dynamic>;
                      final String senderRole = data['senderRole'] ?? '';
                      final String text = data['text'] ?? '';
                      final String type = data['type'] ?? 'text';

                      final String? mediaUrl = data['mediaUrl'] ?? data['audioUrl'];
                      final int duration = data['duration'] ?? 0;

                      final bool isMe = senderRole == widget.currentUserRole;

                      return Align(
                        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: GestureDetector(
                          onLongPress: () => _confirmDeleteSingleMessage(doc.id),
                          child: (type == 'voice' || type == 'audio') && mediaUrl != null
                              ? VoiceMessageBubble(
                            audioUrl: mediaUrl,
                            isMe: isMe,
                            duration: duration,
                          )
                              : Container(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            constraints: BoxConstraints(
                              maxWidth: screenWidth * 0.75,
                            ),
                            decoration: BoxDecoration(
                              color: isMe
                                  ? colorScheme.primary
                                  : colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(16),
                                topRight: const Radius.circular(16),
                                bottomLeft: isMe
                                    ? const Radius.circular(16)
                                    : const Radius.circular(4),
                                bottomRight: isMe
                                    ? const Radius.circular(4)
                                    : const Radius.circular(16),
                              ),
                            ),
                            child: DynamicTranslatedText(
                              text: text,
                              targetLanguageCode: currentLang,
                              style: TextStyle(
                                color: isMe
                                    ? colorScheme.onPrimary
                                    : colorScheme.onSurface,
                                fontSize: 15,
                                height: 1.3,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            // Single Row Bottom Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: theme.cardColor,
                border: Border(
                  top: BorderSide(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                  ),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Text Field
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 14),
                          Expanded(
                            child: TextField(
                              controller: _messageController,
                              textCapitalization: TextCapitalization.sentences,
                              maxLines: 4,
                              minLines: 1,
                              keyboardType: TextInputType.multiline,
                              style: TextStyle(
                                color: colorScheme.onSurface,
                                fontSize: 14,
                              ),
                              decoration: InputDecoration(
                                hintText: l10n.typeAMessage,
                                hintStyle: TextStyle(
                                  color: colorScheme.onSurfaceVariant,
                                  fontSize: 14,
                                ),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Dynamic Action Button: Send button if typing, Voice Recorder if empty
                  _messageController.text.trim().isNotEmpty
                      ? SizedBox(
                    width: 42,
                    height: 42,
                    child: IconButton.filled(
                      onPressed: _sendMessage,
                      style: IconButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        padding: EdgeInsets.zero,
                      ),
                      icon: const Icon(Icons.send_rounded, size: 18),
                    ),
                  )
                      : VoiceRecorderInput(
                    chatId: widget.patientId,
                    currentUserId: widget.currentUserRole,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}