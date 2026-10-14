import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:alzhimers_ease/l10n/app_localizations.dart';

import '../../data/models/person_model.dart';
import '../../data/services/face_recognizer_service.dart';
import '../../data/services/notification_service.dart';

class EnrolledPeopleScreen extends StatefulWidget {
  final String patientId;

  const EnrolledPeopleScreen({super.key, required this.patientId});

  @override
  State<EnrolledPeopleScreen> createState() => _EnrolledPeopleScreenState();
}

class _EnrolledPeopleScreenState extends State<EnrolledPeopleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _relationController = TextEditingController();

  File? _selectedImage;
  bool _isProcessing = false;

  final FaceRecognizerService _mlService = FaceRecognizerService();
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _nameController.dispose();
    _relationController.dispose();
    _mlService.dispose();
    super.dispose();
  }

  /// Pick and crop face photo with square constraints
  Future<void> _pickAndCropImage(ImageSource source) async {
    final colorScheme = Theme.of(context).colorScheme;

    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 90,
      );

      if (pickedFile == null) return;

      final CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        compressQuality: 85,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Face Photo',
            toolbarColor: colorScheme.primary,
            toolbarWidgetColor: colorScheme.onPrimary,
            activeControlsWidgetColor: colorScheme.primary,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true,
          ),
          IOSUiSettings(
            title: 'Crop Face Photo',
            aspectRatioLockEnabled: true,
            resetAspectRatioEnabled: false,
          ),
        ],
      );

      if (croppedFile != null && mounted) {
        setState(() {
          _selectedImage = File(croppedFile.path);
        });
      }
    } catch (e) {
      debugPrint("Error picking or cropping image: $e");
    }
  }

  void _showImagePickerModal() {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: Icon(Icons.photo_library_outlined, color: colorScheme.primary),
              title: Text(l10n.pickFromGallery, style: TextStyle(color: colorScheme.onSurface)),
              onTap: () {
                Navigator.of(ctx).pop();
                _pickAndCropImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: Icon(Icons.camera_alt_outlined, color: colorScheme.primary),
              title: Text(l10n.takeAPhoto, style: TextStyle(color: colorScheme.onSurface)),
              onTap: () {
                Navigator.of(ctx).pop();
                _pickAndCropImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Sends push notifications to linked caregivers and the patient account
  Future<void> _sendEnrollmentNotification(String name, String relation) async {
    try {
      final l10n = AppLocalizations.of(context)!;
      final currentUser = FirebaseAuth.instance.currentUser;

      final patientDoc = await FirebaseFirestore.instance
          .collection('patients')
          .doc(widget.patientId)
          .get();

      if (!patientDoc.exists || patientDoc.data() == null) return;

      final patientData = patientDoc.data()!;
      final String? caregiverUid = patientData['caregiverUid'];

      if (caregiverUid != null &&
          caregiverUid.isNotEmpty &&
          caregiverUid != currentUser?.uid) {
        await NotificationService().sendNotificationToUser(
          recipientId: caregiverUid,
          recipientType: 'caregivers',
          title: l10n.newTrustedFaceEnrolledTitle,
          body: l10n.trustedFaceAddedBody(
            name,
            relation,
            patientData['name'] ?? l10n.defaultPatientRole,
          ),
          extraData: {
            'type': 'face_enrolled',
            'patientId': widget.patientId,
          },
        );
      }

      await NotificationService().sendNotificationToUser(
        recipientId: widget.patientId,
        recipientType: 'patients',
        title: l10n.securityUpdateTitle,
        body: l10n.patientDeviceRecognizeBody(name, relation),
        extraData: {
          'type': 'face_enrolled',
          'patientId': widget.patientId,
        },
      );
    } catch (e) {
      debugPrint("Failed to send face enrollment notification: $e");
    }
  }

  Future<void> _enrollPerson() async {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    if (!_formKey.currentState!.validate() || _selectedImage == null) {
      _showSnackBar(l10n.fillAllFieldsAndSelectPhoto, colorScheme.error);
      return;
    }

    setState(() => _isProcessing = true);

    try {
      List<double>? embedding =
      await _mlService.generateEmbedding(_selectedImage!);

      if (embedding == null) {
        throw Exception(l10n.noClearFaceDetectedError);
      }

      final docRef = FirebaseFirestore.instance
          .collection('patients')
          .doc(widget.patientId)
          .collection('trusted_faces')
          .doc();

      final String name = _nameController.text.trim();
      final String relationship = _relationController.text.trim();

      final newPerson = PersonModel(
        id: docRef.id,
        name: name,
        relationship: relationship,
        faceEmbedding: embedding,
      );

      await docRef.set(newPerson.toMap());

      await _sendEnrollmentNotification(name, relationship);

      if (!mounted) return;

      _showSnackBar(l10n.faceRegisteredSuccess, colorScheme.primary);

      _nameController.clear();
      _relationController.clear();
      setState(() => _selectedImage = null);
    } catch (e) {
      if (!mounted) return;
      _showSnackBar(
        e.toString().replaceAll("Exception: ", ""),
        colorScheme.error,
      );
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  void _showSnackBar(String message, Color backgroundColor) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          l10n.enrollTrustedFacesTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
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
            horizontal: screenWidth * 0.05,
            vertical: 16.0,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.enrollTrustedFacesSubtitle,
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: screenHeight * 0.025),

                // Material Photo Container
                GestureDetector(
                  onTap: _showImagePickerModal,
                  child: Container(
                    height: screenHeight * 0.24,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: colorScheme.primary.withValues(alpha: 0.2),
                        width: 1.5,
                      ),
                    ),
                    child: _selectedImage != null
                        ? ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: Image.file(_selectedImage!, fit: BoxFit.cover),
                          ),
                          Positioned(
                            bottom: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: colorScheme.surface,
                                shape: BoxShape.circle,
                                border: Border.all(color: colorScheme.primary, width: 1.5),
                              ),
                              child: Icon(Icons.crop_rotate_rounded, size: 16, color: colorScheme.primary),
                            ),
                          ),
                        ],
                      ),
                    )
                        : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_a_photo_rounded,
                          size: 40,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            l10n.tapToCaptureOrPickPhoto,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.025),

                // Form Container Card
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: colorScheme.primary.withValues(alpha: 0.15),
                      width: 1.0,
                    ),
                  ),
                  color: theme.cardColor,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _nameController,
                          style: TextStyle(color: colorScheme.onSurface),
                          decoration: InputDecoration(
                            labelText: l10n.fullNameLabel,
                            prefixIcon: Icon(Icons.person_outline, color: colorScheme.primary),
                          ),
                          validator: (value) =>
                          (value == null || value.trim().isEmpty) ? l10n.enterValidNameError : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _relationController,
                          style: TextStyle(color: colorScheme.onSurface),
                          decoration: InputDecoration(
                            labelText: l10n.relationshipHint,
                            prefixIcon: Icon(Icons.people_outline, color: colorScheme.primary),
                          ),
                          validator: (value) =>
                          (value == null || value.trim().isEmpty) ? l10n.enterRelationshipError : null,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.035),

                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isProcessing ? null : _enrollPerson,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isProcessing
                        ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: colorScheme.onPrimary,
                        strokeWidth: 2,
                      ),
                    )
                        : Text(
                      l10n.processAndSaveFaceMatrix,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
}