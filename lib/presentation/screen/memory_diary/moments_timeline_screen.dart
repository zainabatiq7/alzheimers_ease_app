import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:alzhimers_ease/l10n/app_localizations.dart';
import 'package:alzhimers_ease/data/models/memory_diary_model.dart';
import 'package:alzhimers_ease/data/services/memory_diary_service.dart';
import 'package:alzhimers_ease/data/services/notification_service.dart';
import 'package:alzhimers_ease/presentation/widgets/voice_input_button.dart';

class MomentsTimelineScreen extends StatefulWidget {
  final String patientId;
  final String? caregiverId;

  const MomentsTimelineScreen({
    super.key,
    required this.patientId,
    this.caregiverId,
  });

  @override
  State<MomentsTimelineScreen> createState() => _MomentsTimelineScreenState();
}

class _MomentsTimelineScreenState extends State<MomentsTimelineScreen> {
  final MemoryDiaryService _diaryService = MemoryDiaryService();
  final ImagePicker _picker = ImagePicker();

  /// Picks an image from the gallery and launches the cropping interface using image_cropper v5+ API
  Future<File?> _pickAndCropImage(ThemeData theme) async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
    );

    if (image == null) return null;

    final CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: image.path,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Memory Photo',
          toolbarColor: theme.colorScheme.primary,
          toolbarWidgetColor: theme.colorScheme.onPrimary,
          activeControlsWidgetColor: theme.colorScheme.primary,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
          aspectRatioPresets: [
            CropAspectRatioPreset.square,
            CropAspectRatioPreset.ratio4x3,
            CropAspectRatioPreset.ratio16x9,
            CropAspectRatioPreset.original,
          ],
        ),
        IOSUiSettings(
          title: 'Crop Memory Photo',
          aspectRatioLockEnabled: false,
          aspectRatioPresets: [
            CropAspectRatioPreset.square,
            CropAspectRatioPreset.ratio4x3,
            CropAspectRatioPreset.ratio16x9,
            CropAspectRatioPreset.original,
          ],
        ),
      ],
    );

    if (croppedFile != null) {
      return File(croppedFile.path);
    }
    return null;
  }

  void _showAddMomentDialog() {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final captionController = TextEditingController();
    File? selectedImage;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
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
                  loc.addABeautifulMoment,
                  style: textTheme.titleLarge?.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 16),

                // Image Selection Container with Integrated Cropping
                GestureDetector(
                  onTap: () async {
                    final File? croppedImage = await _pickAndCropImage(theme);
                    if (croppedImage != null) {
                      setModalState(() => selectedImage = croppedImage);
                    }
                  },
                  child: Container(
                    height: 180,
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                      ),
                      image: selectedImage != null
                          ? DecorationImage(
                        image: FileImage(selectedImage!),
                        fit: BoxFit.cover,
                      )
                          : null,
                    ),
                    child: selectedImage == null
                        ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: colorScheme.primary
                                .withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.add_a_photo_rounded,
                            size: 28,
                            color: colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          loc.tapToAddPhoto,
                          style: TextStyle(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    )
                        : Stack(
                      children: [
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            decoration: BoxDecoration(
                              color: colorScheme.scrim.withValues(alpha: 0.65),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: Icon(
                                Icons.crop_rotate_rounded,
                                color: colorScheme.onPrimary,
                                size: 20,
                              ),
                              onPressed: () async {
                                final File? croppedImage =
                                await _pickAndCropImage(theme);
                                if (croppedImage != null) {
                                  setModalState(
                                          () => selectedImage = croppedImage);
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Caption Input Field with Voice Integration
                TextField(
                  controller: captionController,
                  maxLines: 3,
                  style: textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                  decoration: InputDecoration(
                    hintText: loc.whatMadeThisMomentSpecial,
                    hintStyle: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    filled: true,
                    fillColor: colorScheme.surfaceContainerHighest,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: colorScheme.primary,
                        width: 1.5,
                      ),
                    ),
                    suffixIcon: VoiceInputButton(controller: captionController),
                  ),
                ),

                const SizedBox(height: 20),

                // Save Action Button
                SizedBox(
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final text = captionController.text.trim();
                      if (text.isEmpty && selectedImage == null) return;

                      Navigator.of(ctx).pop();

                      final newMoment = DiaryEntry(
                        id: '',
                        type: DiaryEntryType.moment,
                        timestamp: DateTime.now(),
                        textCaption: text.isNotEmpty ? text : null,
                        photoUrls:
                        selectedImage != null ? [selectedImage!.path] : [],
                        authorRole: 'patient',
                      );

                      // 1. Save entry to Firestore
                      await _diaryService.addDiaryEntry(
                          widget.patientId, newMoment);

                      // 2. Trigger Push Notification to Caregiver if ID is present
                      if (widget.caregiverId != null &&
                          widget.caregiverId!.isNotEmpty) {
                        final notificationBody = text.isNotEmpty
                            ? loc.patientCapturedMoment(text)
                            : loc.patientUploadedPhoto;

                        await NotificationService().sendNotificationToUser(
                          recipientId: widget.caregiverId!,
                          recipientType: 'caregivers',
                          title: loc.newMemoryTitle,
                          body: notificationBody,
                        );
                      }
                    },
                    icon: const Icon(Icons.check_rounded),
                    label: Text(
                      loc.saveMoment,
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
      ),
    );
  }

  void _confirmDeleteMoment(DiaryEntry moment) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: theme.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          "Delete Moment",
          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          "Are you sure you want to delete this moment?",
          style: TextStyle(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              "Cancel",
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.error,
              foregroundColor: colorScheme.onError,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () async {
              Navigator.of(ctx).pop();
              if (moment.id.isNotEmpty) {
                await _diaryService.deleteDiaryEntry(
                    widget.patientId, moment.id);
              }
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  Widget _buildImageWidget(String photoPath, ThemeData theme) {
    Widget imageWidget;

    if (photoPath.startsWith('http')) {
      imageWidget = Image.network(
        photoPath,
        height: 220,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            _buildImageErrorPlaceholder(theme),
      );
    } else {
      final file = File(photoPath);
      if (file.existsSync()) {
        imageWidget = Image.file(
          file,
          height: 220,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              _buildImageErrorPlaceholder(theme),
        );
      } else {
        return _buildImageErrorPlaceholder(theme);
      }
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: imageWidget,
    );
  }

  Widget _buildImageErrorPlaceholder(ThemeData theme) {
    final colorScheme = theme.colorScheme;

    return Container(
      height: 120,
      width: double.infinity,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.broken_image_rounded,
            color: colorScheme.error,
            size: 32,
          ),
          const SizedBox(height: 6),
          Text(
            "Image unavailable",
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: 12,
            ),
          ),
        ],
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
          loc.beautifulMoments,
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: theme.appBarTheme.foregroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        iconTheme: theme.appBarTheme.iconTheme ??
            IconThemeData(color: colorScheme.onSurface),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: colorScheme.outlineVariant.withValues(alpha: 0.3),
            height: 1.0,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddMomentDialog,
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 2,
        icon: const Icon(Icons.add_a_photo_rounded),
        label: Text(
          loc.addMoment,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: StreamBuilder<List<DiaryEntry>>(
        stream: _diaryService.getDiaryEntries(widget.patientId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: colorScheme.primary),
            );
          }

          final moments = snapshot.data
              ?.where((e) => e.type == DiaryEntryType.moment)
              .toList() ??
              [];

          if (moments.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  loc.noMomentsRecordedYet,
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            itemCount: moments.length,
            itemBuilder: (context, index) {
              final moment = moments[index];
              final hasPhotos = moment.photoUrls.isNotEmpty;
              final firstPhoto = hasPhotos ? moment.photoUrls.first : null;

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                    width: 1.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.shadow.withValues(alpha: 0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // AUTHOR ROLE & DATE HEADER
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              moment.authorRole == 'patient'
                                  ? loc.patientNote
                                  : loc.caregiverNote,
                              style: textTheme.labelSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.primary,
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                "${moment.timestamp.day}/${moment.timestamp.month}/${moment.timestamp.year}",
                                style: textTheme.bodySmall?.copyWith(
                                  fontSize: 12,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: Icon(
                                  Icons.delete_outline_rounded,
                                  color: colorScheme.error,
                                  size: 20,
                                ),
                                constraints: const BoxConstraints(),
                                padding: EdgeInsets.zero,
                                onPressed: () => _confirmDeleteMoment(moment),
                              ),
                            ],
                          ),
                        ],
                      ),

                      // ATTACHED IMAGE
                      if (firstPhoto != null) ...[
                        const SizedBox(height: 12),
                        _buildImageWidget(firstPhoto, theme),
                      ],

                      // TEXT CAPTION
                      if (moment.textCaption != null &&
                          moment.textCaption!.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(
                          moment.textCaption!,
                          style: textTheme.bodyLarge?.copyWith(
                            fontSize: 15,
                            height: 1.35,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ],
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