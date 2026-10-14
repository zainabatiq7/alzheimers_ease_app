import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:alzhimers_ease/l10n/app_localizations.dart';

import '../../data/models/person_model.dart';
import '../../data/models/memory_diary_model.dart';
import '../../data/services/face_recognizer_service.dart';
import '../../data/services/memory_diary_service.dart';

class WhoIsThisScreen extends StatefulWidget {
  final String patientId;

  const WhoIsThisScreen({super.key, required this.patientId});

  @override
  State<WhoIsThisScreen> createState() => _WhoIsThisScreenState();
}

class _WhoIsThisScreenState extends State<WhoIsThisScreen> {
  CameraController? _cameraController;
  final FaceRecognizerService _mlService = FaceRecognizerService();
  final MemoryDiaryService _diaryService = MemoryDiaryService();

  bool _isInitializing = true;
  bool _isAnalyzing = false;

  // Custom status key used to select localized text dynamically
  String _statusKey = 'pointCameraInstruction';
  String _dynamicErrorDetails = '';

  PersonModel? _matchedPerson;
  double _confidenceScore = 0.0;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  /// Sets up the device camera stream
  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        if (!mounted) return;
        setState(() {
          _statusKey = 'noCameraHardwareFound';
          _isInitializing = false;
        });
        return;
      }

      final frontCamera = cameras.firstWhere(
            (cam) => cam.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      _cameraController = CameraController(
        frontCamera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await _cameraController!.initialize();

      if (!mounted) return;
      setState(() => _isInitializing = false);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _statusKey = 'cameraError';
        _dynamicErrorDetails = e.toString();
        _isInitializing = false;
      });
    }
  }

  /// Captures a frame and evaluates it against Firestore records
  Future<void> _scanFace() async {
    if (_cameraController == null ||
        !_cameraController!.value.isInitialized ||
        _isAnalyzing) {
      return;
    }

    setState(() {
      _isAnalyzing = true;
      _statusKey = 'analyzingFaceStructure';
      _dynamicErrorDetails = '';
      _matchedPerson = null;
    });

    try {
      final XFile photo = await _cameraController!.takePicture();
      final File imageFile = File(photo.path);

      List<double>? currentEmbedding =
      await _mlService.generateEmbedding(imageFile);

      if (await imageFile.exists()) {
        await imageFile.delete();
      }

      if (currentEmbedding == null) {
        if (!mounted) return;
        setState(() {
          _statusKey = 'noFaceDetected';
          _isAnalyzing = false;
        });
        return;
      }

      final snapshot = await FirebaseFirestore.instance
          .collection('patients')
          .doc(widget.patientId)
          .collection('trusted_faces')
          .get();

      if (snapshot.docs.isEmpty) {
        if (!mounted) return;
        setState(() {
          _statusKey = 'noTrustedFacesEnrolled';
          _isAnalyzing = false;
        });
        return;
      }

      PersonModel? bestMatch;
      double highestSimilarity = -1.0;
      String? matchedPhotoUrl;

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final person = PersonModel.fromMap(data, doc.id);

        final photoUrl =
            data['imageUrl'] ?? data['photoUrl'] ?? data['faceImageUrl'];

        double similarity = _mlService.compareEmbeddings(
            currentEmbedding, person.faceEmbedding);

        if (similarity > highestSimilarity) {
          highestSimilarity = similarity;
          bestMatch = person;
          matchedPhotoUrl = photoUrl as String?;
        }
      }

      if (!mounted) return;

      if (highestSimilarity >= 0.78 && bestMatch != null) {
        setState(() {
          _matchedPerson = bestMatch;
          _confidenceScore = highestSimilarity * 100;
          _statusKey = 'matchFound';
        });

        _logVisitInDiary(bestMatch, matchedPhotoUrl);
      } else {
        setState(() {
          _statusKey = 'unknownPerson';
        });
      }
    } catch (e) {
      if (!mounted) return;
      debugPrint("Scan face error details: $e");
      setState(() {
        _statusKey = 'analysisError';
        _dynamicErrorDetails = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() => _isAnalyzing = false);
      }
    }
  }

  /// Resolves the raw translation string based on state
  String _getLocalizedStatus(AppLocalizations l10n) {
    switch (_statusKey) {
      case 'pointCameraInstruction':
        return l10n.pointCameraInstruction;
      case 'noCameraHardwareFound':
        return l10n.noCameraHardwareFound;
      case 'cameraError':
        return l10n.cameraError(_dynamicErrorDetails);
      case 'analyzingFaceStructure':
        return l10n.analyzingFaceStructure;
      case 'noFaceDetected':
        return l10n.noFaceDetected;
      case 'noTrustedFacesEnrolled':
        return l10n.noTrustedFacesEnrolled;
      case 'matchFound':
        return l10n.matchFound;
      case 'unknownPerson':
        return l10n.unknownPerson;
      case 'analysisError':
        return l10n.analysisError(_dynamicErrorDetails);
      default:
        return l10n.pointCameraInstruction;
    }
  }

  /// Helper to record the visit into Memory Diary
  Future<void> _logVisitInDiary(PersonModel person, String? photoUrl) async {
    try {
      final visitLog = VisitLog(
        id: '',
        personId: person.id,
        personName: person.name,
        relationship: person.relationship,
        timestamp: DateTime.now(),
        togetherPhotoUrl: photoUrl,
      );

      await _diaryService.addVisitLog(widget.patientId, visitLog);
    } catch (e) {
      debugPrint("Visit logging background warning: $e");
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _mlService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          l10n.whoIsThisTitle,
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: SafeArea(
        child: _isInitializing ||
            _cameraController == null ||
            !_cameraController!.value.isInitialized
            ? Center(
          child: CircularProgressIndicator(color: colorScheme.primary),
        )
            : Column(
          children: [
            // CAMERA VIEWPORT CONTAINER
            Expanded(
              flex: 3,
              child: Container(
                margin: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.04,
                  vertical: 12,
                ),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                    width: 1.0,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final cameraAspectRatio =
                          _cameraController!.value.aspectRatio;

                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedOverflowBox(
                            size: Size(
                              constraints.maxWidth,
                              constraints.maxHeight,
                            ),
                            child: SizedBox(
                              width: constraints.maxWidth,
                              height: constraints.maxWidth *
                                  cameraAspectRatio,
                              child: CameraPreview(_cameraController!),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),

            // RESULTS & SCAN ACTION PANEL
            Expanded(
              flex: 2,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(28),
                    topRight: Radius.circular(28),
                  ),
                  border: Border.all(
                    color: colorScheme.primary.withValues(alpha: 0.15),
                  ),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.06,
                  vertical: 20,
                ),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _getLocalizedStatus(l10n),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          color: _matchedPerson != null
                              ? colorScheme.primary
                              : colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (_matchedPerson != null) ...[
                        Column(
                          children: [
                            Text(
                              _matchedPerson!.name,
                              style: textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              l10n.yourRelationship(
                                  _matchedPerson!.relationship),
                              style: TextStyle(
                                fontSize: 16,
                                color: colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              l10n.confidenceScore(
                                  _confidenceScore.toStringAsFixed(1)),
                              style: TextStyle(
                                fontSize: 12,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: _isAnalyzing ? null : _scanFace,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.primary,
                            foregroundColor: colorScheme.onPrimary,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          icon: _isAnalyzing
                              ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: colorScheme.onPrimary,
                              strokeWidth: 2,
                            ),
                          )
                              : const Icon(
                            Icons.face_unlock_outlined,
                            size: 22,
                          ),
                          label: Text(
                            _isAnalyzing
                                ? l10n.processingButton
                                : l10n.scanFaceButton,
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
            ),
          ],
        ),
      ),
    );
  }
}