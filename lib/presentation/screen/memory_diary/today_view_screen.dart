import 'package:flutter/material.dart';
import 'package:alzhimers_ease/l10n/app_localizations.dart';
import 'package:alzhimers_ease/data/models/memory_diary_model.dart';
import 'package:alzhimers_ease/data/services/memory_diary_service.dart';
import 'package:alzhimers_ease/data/services/notification_service.dart';
import 'package:alzhimers_ease/presentation/widgets/voice_input_button.dart';

class TodayViewScreen extends StatefulWidget {
  final String patientId;
  final String? caregiverId;

  const TodayViewScreen({
    super.key,
    required this.patientId,
    this.caregiverId,
  });

  @override
  State<TodayViewScreen> createState() => _TodayViewScreenState();
}

class _TodayViewScreenState extends State<TodayViewScreen> {
  final MemoryDiaryService _diaryService = MemoryDiaryService();

  String? _selectedMood;
  final TextEditingController _outfitController = TextEditingController();
  final TextEditingController _mealsController = TextEditingController();

  bool _isSaving = false;

  List<Map<String, String>> _getMoods(AppLocalizations loc) {
    return [
      {'label': 'Happy', 'translated': loc.happy, 'emoji': '😊'},
      {'label': 'Calm', 'translated': loc.calm, 'emoji': '😌'},
      {'label': 'Tired', 'translated': loc.tired, 'emoji': '🥱'},
      {'label': 'Confused', 'translated': loc.confused, 'emoji': '😕'},
      {'label': 'Sad', 'translated': loc.sad, 'emoji': '😢'},
    ];
  }

  Future<void> _saveTodayLog() async {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    setState(() => _isSaving = true);

    try {
      final outfitText = _outfitController.text.trim();
      final mealsText = _mealsController.text.trim();

      final newEntry = DiaryEntry(
        id: '',
        type: DiaryEntryType.dailyCheckin,
        timestamp: DateTime.now(),
        authorRole: 'patient',
        mood: _selectedMood,
        outfit: outfitText.isEmpty ? null : outfitText,
        meals: mealsText.isEmpty ? null : mealsText,
      );

      // 1. Save entry to Firestore
      await _diaryService.addDiaryEntry(widget.patientId, newEntry);

      // 2. Trigger Push Notification to Caregiver
      if (widget.caregiverId != null && widget.caregiverId!.isNotEmpty) {
        String notificationDetail = "";
        if (_selectedMood != null) {
          notificationDetail = loc.feeling(_selectedMood!);
        } else if (mealsText.isNotEmpty) {
          notificationDetail = loc.ate(mealsText);
        } else if (outfitText.isNotEmpty) {
          notificationDetail = loc.wearing(outfitText);
        } else {
          notificationDetail = loc.completedCheckIn;
        }

        await NotificationService().sendNotificationToUser(
          recipientId: widget.caregiverId!,
          recipientType: 'caregivers',
          title: loc.dailyCheckInTitle,
          body: loc.patientLoggedStory(notificationDetail),
        );
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.savedNotesSuccess),
          backgroundColor: colorScheme.primary,
        ),
      );

      // Clear inputs after successful save
      _outfitController.clear();
      _mealsController.clear();
      setState(() {
        _selectedMood = null;
      });

      // Show history right after saving
      _showHistoryModal(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.failedToSaveNotes),
          backgroundColor: colorScheme.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showHistoryModal(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          minChildSize: 0.4,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: colorScheme.outlineVariant,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(
                        Icons.history_rounded,
                        color: colorScheme.primary,
                        size: 26,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        loc.checkInHistory,
                        style: textTheme.titleLarge?.copyWith(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  Divider(
                    height: 24,
                    color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                  ),
                  Expanded(
                    child: StreamBuilder<List<DiaryEntry>>(
                      stream: _diaryService.getDiaryEntries(widget.patientId),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                            child: CircularProgressIndicator(
                              color: colorScheme.primary,
                            ),
                          );
                        }

                        if (snapshot.hasError) {
                          return Center(
                            child: Text(
                              loc.errorLoadingHistory,
                              style: textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurface,
                              ),
                            ),
                          );
                        }

                        final entries = snapshot.data
                            ?.where((e) =>
                        e.type == DiaryEntryType.dailyCheckin)
                            .toList() ??
                            [];

                        if (entries.isEmpty) {
                          return Center(
                            child: Text(
                              loc.noHistoryFound,
                              style: textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                                fontSize: 16,
                              ),
                            ),
                          );
                        }

                        return ListView.builder(
                          controller: scrollController,
                          itemCount: entries.length,
                          itemBuilder: (context, index) {
                            final entry = entries[index];
                            final dateStr =
                                "${entry.timestamp.day}/${entry.timestamp.month}/${entry.timestamp.year} at ${entry.timestamp.hour}:${entry.timestamp.minute.toString().padLeft(2, '0')}";

                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: colorScheme.outlineVariant
                                      .withValues(alpha: 0.5),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        dateStr,
                                        style: textTheme.bodySmall?.copyWith(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                      if (entry.mood != null)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: colorScheme.primaryContainer,
                                            borderRadius:
                                            BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            loc.moodLabel(entry.mood!),
                                            style: TextStyle(
                                              color:
                                              colorScheme.onPrimaryContainer,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  if (entry.outfit != null &&
                                      entry.outfit!.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 6),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.checkroom_rounded,
                                            size: 16,
                                            color: colorScheme.primary,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              loc.wearingLabel(entry.outfit!),
                                              style: textTheme.bodyMedium
                                                  ?.copyWith(
                                                fontSize: 14,
                                                color: colorScheme.onSurface,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  if (entry.meals != null &&
                                      entry.meals!.isNotEmpty)
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.restaurant_rounded,
                                          size: 16,
                                          color: colorScheme.primary,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            loc.ateLabel(entry.meals!),
                                            style:
                                            textTheme.bodyMedium?.copyWith(
                                              fontSize: 14,
                                              color: colorScheme.onSurface,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _outfitController.dispose();
    _mealsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final moods = _getMoods(loc);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          loc.myDayToday,
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
        actions: [
          IconButton(
            icon: Icon(Icons.history_rounded, color: colorScheme.primary),
            tooltip: loc.checkInHistory,
            onPressed: () => _showHistoryModal(context),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // INTRO INFO BANNER
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: colorScheme.onPrimaryContainer,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        loc.optionalInfoHint,
                        style: textTheme.bodyMedium?.copyWith(
                          fontSize: 14,
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // QUESTION 1: MOOD
              Text(
                loc.howAreYouFeeling,
                style: textTheme.titleMedium?.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: moods.map((m) {
                    final isSelected = _selectedMood == m['label'];
                    return Padding(
                      padding: const EdgeInsets.only(right: 10.0),
                      child: ChoiceChip(
                        label: Text(
                          "${m['emoji']} ${m['translated']}",
                          style: TextStyle(
                            fontSize: 15,
                            color: isSelected
                                ? colorScheme.onPrimary
                                : colorScheme.onSurface,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        selected: isSelected,
                        selectedColor: colorScheme.primary,
                        backgroundColor: colorScheme.surfaceContainerHighest,
                        side: BorderSide(
                          color: isSelected
                              ? colorScheme.primary
                              : colorScheme.outlineVariant,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        onSelected: (selected) {
                          setState(() {
                            _selectedMood = selected ? m['label'] : null;
                          });
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 24),

              // QUESTION 2: OUTFIT
              Text(
                loc.whatAreYouWearing,
                style: textTheme.titleMedium?.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _outfitController,
                maxLines: 2,
                style: textTheme.bodyLarge?.copyWith(
                  fontSize: 15,
                  color: colorScheme.onSurface,
                ),
                decoration: InputDecoration(
                  hintText: loc.outfitHint,
                  hintStyle: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  fillColor: colorScheme.surfaceContainerHighest,
                  filled: true,
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
                    Icons.checkroom_rounded,
                    color: colorScheme.primary,
                  ),
                  suffixIcon: VoiceInputButton(controller: _outfitController),
                ),
              ),

              const SizedBox(height: 24),

              // QUESTION 3: MEALS
              Text(
                loc.whatDidYouEat,
                style: textTheme.titleMedium?.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _mealsController,
                maxLines: 2,
                style: textTheme.bodyLarge?.copyWith(
                  fontSize: 15,
                  color: colorScheme.onSurface,
                ),
                decoration: InputDecoration(
                  hintText: loc.mealsHint,
                  hintStyle: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  fillColor: colorScheme.surfaceContainerHighest,
                  filled: true,
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
                    Icons.restaurant_rounded,
                    color: colorScheme.primary,
                  ),
                  suffixIcon: VoiceInputButton(controller: _mealsController),
                ),
              ),

              const SizedBox(height: 32),

              // SAVE ACTION BUTTON
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveTodayLog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _isSaving
                      ? SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      color: colorScheme.onPrimary,
                      strokeWidth: 2,
                    ),
                  )
                      : Text(
                    loc.saveTodaysStory,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
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
}