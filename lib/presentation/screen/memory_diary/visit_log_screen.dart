import 'package:flutter/material.dart';
import 'package:alzhimers_ease/l10n/app_localizations.dart';
import 'package:alzhimers_ease/data/models/memory_diary_model.dart';
import 'package:alzhimers_ease/data/services/memory_diary_service.dart';
import 'package:alzhimers_ease/data/services/notification_service.dart';

class VisitLogScreen extends StatefulWidget {
  final String patientId;
  final String? caregiverId; // Target recipient for push notifications

  const VisitLogScreen({
    super.key,
    required this.patientId,
    this.caregiverId,
  });

  @override
  State<VisitLogScreen> createState() => _VisitLogScreenState();
}

class _VisitLogScreenState extends State<VisitLogScreen> {
  final MemoryDiaryService _diaryService = MemoryDiaryService();

  String _formatRelativeTime(DateTime timestamp, AppLocalizations loc) {
    final diff = DateTime.now().difference(timestamp);
    if (diff.inMinutes < 60) {
      return loc.minsAgo(diff.inMinutes);
    } else if (diff.inHours < 24) {
      return loc.hrsAgo(diff.inHours);
    } else {
      return loc.daysAgo(diff.inDays);
    }
  }

  void _showAddVisitDialog() {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final nameController = TextEditingController();
    final relationController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          top: 12,
          left: 20,
          right: 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top drag indicator
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                loc.logAVisitor,
                style: textTheme.titleLarge?.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),

              // Visitor Name Input
              TextField(
                controller: nameController,
                style: textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurface,
                ),
                decoration: InputDecoration(
                  labelText: loc.visitorName,
                  labelStyle: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  hintText: loc.visitorNameHint,
                  hintStyle: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHighest,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: colorScheme.primary,
                      width: 1.5,
                    ),
                  ),
                  prefixIcon: Icon(
                    Icons.person_rounded,
                    color: colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Relationship Input
              TextField(
                controller: relationController,
                style: textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurface,
                ),
                decoration: InputDecoration(
                  labelText: loc.relationship,
                  labelStyle: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  hintText: loc.relationshipHint,
                  hintStyle: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHighest,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: colorScheme.primary,
                      width: 1.5,
                    ),
                  ),
                  prefixIcon: Icon(
                    Icons.people_alt_rounded,
                    color: colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Save Action Button
              SizedBox(
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final name = nameController.text.trim();
                    final relation = relationController.text.trim();

                    if (name.isEmpty) return;

                    Navigator.of(ctx).pop();

                    final newVisit = VisitLog(
                      id: '',
                      personId: '',
                      personName: name,
                      relationship: relation.isNotEmpty
                          ? relation
                          : loc.defaultVisitorRole,
                      timestamp: DateTime.now(),
                    );

                    // 1. Save visit log to Firestore
                    await _diaryService.addVisitLog(widget.patientId, newVisit);

                    // 2. Send Push Notification to Caregiver
                    if (widget.caregiverId != null &&
                        widget.caregiverId!.isNotEmpty) {
                      final relationString =
                      relation.isNotEmpty ? " ($relation)" : "";

                      await NotificationService().sendNotificationToUser(
                        recipientId: widget.caregiverId!,
                        recipientType: 'caregivers',
                        title: loc.newVisitorLoggedTitle,
                        body: loc.visitorVisitedToday(name, relationString),
                      );
                    }
                  },
                  icon: const Icon(Icons.check_rounded),
                  label: Text(
                    loc.saveVisit,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          loc.whoVisitedMe,
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: theme.appBarTheme.foregroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddVisitDialog,
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 2,
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: Text(
          loc.logVisit,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: StreamBuilder<List<VisitLog>>(
        stream: _diaryService.getVisitLogs(widget.patientId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: colorScheme.primary),
            );
          }

          final visits = snapshot.data ?? [];

          if (visits.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  loc.noVisitLogsRecordedYet,
                  textAlign: TextAlign.center,
                  style: textTheme.bodyMedium?.copyWith(
                    fontSize: 16,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            );
          }

          return ListView.builder(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            itemCount: visits.length,
            itemBuilder: (context, index) {
              final visit = visits[index];
              final initial = visit.personName.isNotEmpty
                  ? visit.personName[0].toUpperCase()
                  : '?';

              return Card(
                elevation: 0,
                color: theme.cardColor,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                  side: BorderSide(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // Visitor Avatar Circle
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            initial,
                            style: TextStyle(
                              color: colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),

                      // Visitor Information
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              visit.personName,
                              style: textTheme.titleMedium?.copyWith(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: colorScheme.outlineVariant
                                      .withValues(alpha: 0.5),
                                ),
                              ),
                              child: Text(
                                visit.relationship,
                                style: textTheme.bodySmall?.copyWith(
                                  fontSize: 12,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Relative Timestamp Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          _formatRelativeTime(visit.timestamp, loc),
                          style: TextStyle(
                            color: colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
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
    );
  }
}