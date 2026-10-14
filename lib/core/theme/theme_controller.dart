import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'app_theme.dart';

class ThemeController extends ChangeNotifier {
  static final ThemeController instance = ThemeController._internal();
  ThemeController._internal();

  bool _isDarkMode = false;
  AppThemePreset _selectedPreset = AppTheme.availablePresets[0];
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _subscription;

  bool get isDarkMode => _isDarkMode;
  AppThemePreset get selectedPreset => _selectedPreset;

  /// Returns active light or dark theme based on accessible Deep Blue & Ocean palette rules
  ThemeData get currentThemeData {
    // If the default preset is active in dark mode, pass null so buildDarkTheme
    // automatically selects the Vibrant Ocean Cyan (#38BDF8) soft glow CTA color.
    final Color? activePrimary = (_isDarkMode && _selectedPreset.id == AppTheme.availablePresets[0].id)
        ? null
        : _selectedPreset.primaryColor;

    return _isDarkMode
        ? AppTheme.buildDarkTheme(primaryColor: activePrimary)
        : AppTheme.buildLightTheme(primaryColor: _selectedPreset.primaryColor);
  }

  /// Safely schedule notifyListeners to prevent rebuilding during active frame builds
  void _safeNotifyListeners() {
    if (WidgetsBinding.instance.schedulerPhase == SchedulerPhase.persistentCallbacks) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    } else {
      notifyListeners();
    }
  }

  /// Listens to patient Firestore document for real-time caregiver/patient theme sync
  void listenToPatientTheme(String patientId) {
    if (patientId.isEmpty) return;

    _subscription?.cancel();
    _subscription = FirebaseFirestore.instance
        .collection('patients')
        .doc(patientId)
        .snapshots()
        .listen(
          (snapshot) {
        if (snapshot.exists && snapshot.data() != null) {
          final data = snapshot.data()!;
          _isDarkMode = data['isDarkMode'] ?? false;

          final String themeId = data['themePreset'] ?? AppTheme.availablePresets[0].id;
          _selectedPreset = AppTheme.getPresetById(themeId);

          _safeNotifyListeners();
        }
      },
      onError: (error) {
        debugPrint("Error listening to patient theme: $error");
      },
    );
  }

  /// Caregiver updates settings -> Saves directly to Firestore
  Future<void> updateThemeSettings({
    required String patientId,
    required bool isDark,
    required String themePresetId,
  }) async {
    // Optimistically update local state for immediate UI responsiveness
    _isDarkMode = isDark;
    _selectedPreset = AppTheme.getPresetById(themePresetId);
    _safeNotifyListeners();

    if (patientId.isEmpty) return;

    try {
      await FirebaseFirestore.instance
          .collection('patients')
          .doc(patientId)
          .set({
        'isDarkMode': isDark,
        'themePreset': themePresetId,
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint("Failed to update theme in Firestore: $e");
    }
  }

  /// Local toggle fallback for standalone UI previews without a patient document
  void toggleDarkModeLocally(bool isDark) {
    _isDarkMode = isDark;
    _safeNotifyListeners();
  }

  /// Stop listening when switching patient contexts or navigating away
  void stopListening() {
    _subscription?.cancel();
    _subscription = null;
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}