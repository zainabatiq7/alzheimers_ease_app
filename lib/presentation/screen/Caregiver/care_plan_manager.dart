import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:alzhimers_ease/l10n/app_localizations.dart';
import 'package:alzhimers_ease/presentation/widgets/dynamic_translated_text.dart';
import 'package:alzhimers_ease/core/theme/app_theme.dart';

class CarePlanManagerScreen extends StatefulWidget {
  final String patientId;

  const CarePlanManagerScreen({super.key, required this.patientId});

  @override
  State<CarePlanManagerScreen> createState() => _CarePlanManagerScreenState();
}

class _CarePlanManagerScreenState extends State<CarePlanManagerScreen> {
  final TextEditingController _taskController = TextEditingController();
  TimeOfDay _selectedTime = TimeOfDay.now();
  bool _isAdding = false;

  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      if (!mounted) return;
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _updateCarePlanSummary() async {
    if (widget.patientId.isEmpty) return;

    try {
      final scheduleSnapshot = await FirebaseFirestore.instance
          .collection('patients')
          .doc(widget.patientId)
          .collection('schedule')
          .get();

      final totalCount = scheduleSnapshot.docs.length;
      final completedCount = scheduleSnapshot.docs.where((doc) {
        final data = doc.data();
        return (data['isCompleted'] ?? false) == true;
      }).length;

      if (!mounted) return;
      await FirebaseFirestore.instance
          .collection('patients')
          .doc(widget.patientId)
          .set({
        'totalTasks': totalCount,
        'completedTasks': completedCount,
        'pendingTasks': totalCount - completedCount,
        'lastActionTime': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint("Error syncing care plan stats: $e");
    }
  }

  Future<void> _addTask() async {
    final String title = _taskController.text.trim();
    if (title.isEmpty || widget.patientId.isEmpty) return;

    setState(() => _isAdding = true);

    try {
      final now = DateTime.now();
      final scheduledDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      final String timeFormatted =
      DateFormat('hh:mm a').format(scheduledDateTime);

      await FirebaseFirestore.instance
          .collection('patients')
          .doc(widget.patientId)
          .collection('schedule')
          .add({
        'task': title,
        'title': title,
        'time': timeFormatted,
        'isCompleted': false,
        'timestamp': Timestamp.fromDate(scheduledDateTime),
        'createdAt': FieldValue.serverTimestamp(),
      });

      await _updateCarePlanSummary();

      _taskController.clear();
      if (mounted) {
        FocusScope.of(context).unfocus();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to add task: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _isAdding = false);
    }
  }

  Future<void> _toggleTaskStatus(String docId, bool currentStatus) async {
    if (widget.patientId.isEmpty) return;

    try {
      await FirebaseFirestore.instance
          .collection('patients')
          .doc(widget.patientId)
          .collection('schedule')
          .doc(docId)
          .update({'isCompleted': !currentStatus});

      await _updateCarePlanSummary();
    } catch (e) {
      debugPrint("Error toggling task status: $e");
    }
  }

  Future<void> _deleteTask(String docId) async {
    if (widget.patientId.isEmpty) return;

    try {
      await FirebaseFirestore.instance
          .collection('patients')
          .doc(widget.patientId)
          .collection('schedule')
          .doc(docId)
          .delete();

      await _updateCarePlanSummary();
    } catch (e) {
      debugPrint("Error deleting task: $e");
    }
  }

  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bool isDark = theme.brightness == Brightness.dark;
    final Locale? currentLocale = Localizations.maybeLocaleOf(context);
    final String currentLang = currentLocale?.languageCode ?? 'en';

    if (widget.patientId.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Care Plan Manager"),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: const Center(
          child: Text("Error: No Patient ID provided."),
        ),
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          loc?.dailyCarePlan ?? "Daily Care Plan",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SizedBox.expand(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // INPUT AREA WRAPPED IN CONSTRAINED CONTAINER
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: theme.dividerColor, width: 1.0),
                  ),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // TEXT FIELD WITH EXPLICIT WIDTH
                      SizedBox(
                        width: double.infinity,
                        child: TextField(
                          controller: _taskController,
                          style: TextStyle(color: colorScheme.onSurface),
                          decoration: InputDecoration(
                            hintText: loc?.updateMedsAndTasks ??
                                "Add a task or medication...",
                            hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                            prefixIcon: Icon(Icons.edit_calendar_rounded, color: colorScheme.primary),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // ACTION BUTTONS ROW
                      SizedBox(
                        width: double.infinity,
                        child: Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _pickTime,
                                icon: Icon(Icons.access_time_rounded, color: colorScheme.primary),
                                label: Text(
                                  _selectedTime.format(context),
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  minimumSize: const Size(0, 48),
                                  side: BorderSide(color: theme.dividerColor),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              width: 110,
                              height: 48,
                              decoration: BoxDecoration(
                                gradient: AppTheme.getPrimaryGradient(context),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ElevatedButton.icon(
                                onPressed: _isAdding ? null : _addTask,
                                icon: _isAdding
                                    ? SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: isDark ? AppTheme.darkBackgroundColor : Colors.white,
                                  ),
                                )
                                    : Icon(
                                  Icons.add_rounded,
                                  color: isDark ? AppTheme.darkBackgroundColor : Colors.white,
                                ),
                                label: Text(
                                  "Add",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? AppTheme.darkBackgroundColor : Colors.white,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  minimumSize: const Size(0, 48),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // SCHEDULE TASK LIST
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('patients')
                      .doc(widget.patientId)
                      .collection('schedule')
                      .orderBy('timestamp', descending: false)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(color: colorScheme.primary),
                      );
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            "Error: ${snapshot.error}",
                            style: TextStyle(color: colorScheme.error),
                          ),
                        ),
                      );
                    }

                    final docs = snapshot.data?.docs ?? [];

                    if (docs.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.event_available_rounded, size: 56, color: theme.disabledColor),
                            const SizedBox(height: 12),
                            Text(
                              loc?.noTasksAssignedToday ??
                                  "No tasks assigned for today.",
                              style: TextStyle(
                                color: colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final doc = docs[index];
                        final data =
                            (doc.data() as Map<String, dynamic>?) ?? {};

                        final String title =
                        (data['task'] ?? data['title'] ?? '').toString();
                        final String time = (data['time'] ?? '').toString();
                        final bool isCompleted = data['isCompleted'] == true;

                        return Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          elevation: 0,
                          color: isCompleted
                              ? theme.cardColor.withValues(alpha: 0.6)
                              : theme.cardColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                            side: BorderSide(
                              color: isCompleted
                                  ? theme.dividerColor
                                  : colorScheme.primary.withValues(alpha: 0.3),
                              width: 1.0,
                            ),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            leading: Checkbox(
                              value: isCompleted,
                              onChanged: (_) =>
                                  _toggleTaskStatus(doc.id, isCompleted),
                              activeColor: colorScheme.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            title: title.isNotEmpty
                                ? DynamicTranslatedText(
                              text: title,
                              targetLanguageCode: currentLang,
                              style: TextStyle(
                                decoration: isCompleted
                                    ? TextDecoration.lineThrough
                                    : null,
                                color: isCompleted
                                    ? colorScheme.onSurfaceVariant
                                    : colorScheme.onSurface,
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            )
                                : const SizedBox.shrink(),
                            subtitle: time.isNotEmpty
                                ? Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.access_time_rounded,
                                    size: 14,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    time,
                                    style: TextStyle(
                                      color: colorScheme.onSurfaceVariant,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            )
                                : null,
                            trailing: IconButton(
                              icon: Icon(
                                Icons.delete_outline_rounded,
                                color: colorScheme.error,
                              ),
                              onPressed: () => _deleteTask(doc.id),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}