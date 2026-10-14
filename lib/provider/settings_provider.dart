import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../core/theme/app_theme.dart';
import '../core/theme/theme_controller.dart';

enum AppColorPalette { teal, blue, amber }

class EmergencyContact {
  final String id;
  final String name;
  final String phone;
  final String relation;

  EmergencyContact({
    required this.id,
    required this.name,
    required this.phone,
    required this.relation,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'phone': phone,
    'relation': relation,
  };

  factory EmergencyContact.fromMap(Map<String, dynamic> map) => EmergencyContact(
    id: map['id'] ?? '',
    name: map['name'] ?? '',
    phone: map['phone'] ?? '',
    relation: map['relation'] ?? '',
  );
}

class MemoryMoment {
  final String id;
  final String title;
  final String note;
  final String date;

  MemoryMoment({
    required this.id,
    required this.title,
    required this.note,
    required this.date,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'note': note,
    'date': date,
  };

  factory MemoryMoment.fromMap(Map<String, dynamic> map) => MemoryMoment(
    id: map['id'] ?? '',
    title: map['title'] ?? map['name'] ?? '',
    note: map['note'] ?? map['phone'] ?? '',
    date: map['date'] ?? '',
  );
}

class SettingsProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  String _languageCode = 'en'; // 'en' or 'ur'
  double _fontSizeScale = 1.0;
  bool _notificationsEnabled = true;
  bool _bypassDnd = false;
  String _alertTone = 'Default Emergency Chime';
  AppColorPalette _selectedPalette = AppColorPalette.teal;

  List<EmergencyContact> _emergencyContacts = [];
  List<MemoryMoment> _savedMoments = [];

  // Active Firestore Patient Subscription
  StreamSubscription<DocumentSnapshot>? _patientFirestoreSubscription;
  String? _activePatientId;

  // Getters
  bool get isDarkMode => _isDarkMode;
  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;
  String get languageCode => _languageCode;
  Locale get locale => Locale(_languageCode);
  double get fontSizeScale => _fontSizeScale;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get bypassDnd => _bypassDnd;
  String get alertTone => _alertTone;
  AppColorPalette get selectedPalette => _selectedPalette;

  Color get primaryColor {
    switch (_selectedPalette) {
      case AppColorPalette.blue:
        return AppTheme.availablePresets[1].primaryColor; // Vibrant Royal Blue (#1E3A8A)
      case AppColorPalette.amber:
        return const Color(0xFFD97706); // Warm Care Amber
      case AppColorPalette.teal:
        return _isDarkMode ? AppTheme.darkPrimaryAccent : AppTheme.lightPrimaryAccent;
    }
  }

  List<EmergencyContact> get emergencyContacts => _emergencyContacts;
  List<MemoryMoment> get savedMoments => _savedMoments;

  EmergencyContact? get primaryEmergencyContact =>
      _emergencyContacts.isNotEmpty ? _emergencyContacts.first : null;

  SettingsProvider() {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    _languageCode = prefs.getString('languageCode') ?? 'en';
    _fontSizeScale = prefs.getDouble('fontSizeScale') ?? 1.0;
    _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
    _bypassDnd = prefs.getBool('bypassDnd') ?? false;
    _alertTone = prefs.getString('alertTone') ?? 'Default Emergency Chime';

    final paletteIndex = prefs.getInt('selectedPalette') ?? 0;
    if (paletteIndex >= 0 && paletteIndex < AppColorPalette.values.length) {
      _selectedPalette = AppColorPalette.values[paletteIndex];
    }

    final contactsJson = prefs.getStringList('emergency_contacts') ?? [];
    _emergencyContacts = contactsJson
        .map((e) => EmergencyContact.fromMap(json.decode(e)))
        .toList();

    final momentsJson = prefs.getStringList('saved_moments') ?? [];
    _savedMoments = momentsJson
        .map((m) => MemoryMoment.fromMap(json.decode(m)))
        .toList();

    // Ensure initial theme sync across the entire app
    ThemeController.instance.toggleDarkModeLocally(_isDarkMode);

    notifyListeners();
  }

  /// REAL-TIME FIRESTORE SYNC FOR CROSS-DEVICE SETTINGS
  void initializeFirestoreSync(String patientId) {
    if (_activePatientId == patientId && _patientFirestoreSubscription != null) {
      return; // Already listening to this patient ID
    }

    _activePatientId = patientId;
    _patientFirestoreSubscription?.cancel();

    _patientFirestoreSubscription = FirebaseFirestore.instance
        .collection('patients')
        .doc(patientId)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        final data = snapshot.data()!;

        // Sync Language
        if (data.containsKey('languageCode')) {
          final remoteLang = data['languageCode'] as String?;
          if (remoteLang != null && remoteLang != _languageCode) {
            setLanguage(remoteLang, syncToFirestore: false);
          }
        }

        // Sync Dark Mode across both SettingsProvider and ThemeController
        if (data.containsKey('isDarkMode')) {
          final remoteDarkMode = data['isDarkMode'] as bool?;
          if (remoteDarkMode != null && remoteDarkMode != _isDarkMode) {
            toggleTheme(remoteDarkMode, syncToFirestore: false);
          }
        }

        // Sync Notification Preference
        if (data.containsKey('notificationsEnabled')) {
          final remoteNotifs = data['notificationsEnabled'] as bool?;
          if (remoteNotifs != null && remoteNotifs != _notificationsEnabled) {
            toggleNotifications(remoteNotifs, syncToFirestore: false);
          }
        }
      }
    });
  }

  Future<void> toggleTheme(bool isDark, {bool syncToFirestore = true}) async {
    _isDarkMode = isDark;

    // Globally sync with ThemeController so all active screens re-render
    ThemeController.instance.toggleDarkModeLocally(isDark);

    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDark);

    if (syncToFirestore && _activePatientId != null) {
      await FirebaseFirestore.instance
          .collection('patients')
          .doc(_activePatientId)
          .set({'isDarkMode': isDark}, SetOptions(merge: true));
    }
  }

  Future<void> setLanguage(String code, {bool syncToFirestore = true}) async {
    _languageCode = code;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('languageCode', code);

    if (syncToFirestore && _activePatientId != null) {
      await FirebaseFirestore.instance
          .collection('patients')
          .doc(_activePatientId)
          .set({'languageCode': code}, SetOptions(merge: true));
    }
  }

  Future<void> toggleNotifications(bool val, {bool syncToFirestore = true}) async {
    _notificationsEnabled = val;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notificationsEnabled', val);

    // Update FCM system configuration
    try {
      if (!val) {
        await FirebaseMessaging.instance.deleteToken();
      } else {
        await FirebaseMessaging.instance.getToken();
      }
    } catch (e) {
      debugPrint("Error toggling FCM status: $e");
    }

    if (syncToFirestore && _activePatientId != null) {
      await FirebaseFirestore.instance
          .collection('patients')
          .doc(_activePatientId)
          .set({'notificationsEnabled': val}, SetOptions(merge: true));
    }
  }

  Future<void> setFontSizeScale(double scale) async {
    _fontSizeScale = scale;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('fontSizeScale', scale);
  }

  Future<void> toggleBypassDnd(bool val) async {
    _bypassDnd = val;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('bypassDnd', val);
  }

  Future<void> setAlertTone(String tone) async {
    _alertTone = tone;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('alertTone', tone);
  }

  Future<void> setPalette(AppColorPalette palette) async {
    _selectedPalette = palette;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('selectedPalette', palette.index);
  }

  Future<void> addEmergencyContact(String name, String phone, String relation) async {
    final newContact = EmergencyContact(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      phone: phone,
      relation: relation,
    );
    _emergencyContacts.add(newContact);
    notifyListeners();
    _saveContactsToPrefs();
  }

  Future<void> removeEmergencyContact(String id) async {
    _emergencyContacts.removeWhere((c) => c.id == id);
    notifyListeners();
    _saveContactsToPrefs();
  }

  Future<void> _saveContactsToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = _emergencyContacts.map((c) => json.encode(c.toMap())).toList();
    await prefs.setStringList('emergency_contacts', encoded);
  }

  Future<void> addMemoryMoment(String title, String note) async {
    final moment = MemoryMoment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      note: note,
      date: DateTime.now().toString().split(' ')[0],
    );
    _savedMoments.insert(0, moment);
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final encoded = _savedMoments.map((m) => json.encode(m.toMap())).toList();
    await prefs.setStringList('saved_moments', encoded);
  }

  @override
  void dispose() {
    _patientFirestoreSubscription?.cancel();
    super.dispose();
  }
}