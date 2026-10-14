import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'l10n/app_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'core/theme/theme_controller.dart';
import 'core/theme/app_theme.dart';
import 'presentation/widgets/gradient_wrapper.dart';
import 'data/services/notification_service.dart';
import 'provider/settings_provider.dart';
import 'presentation/screen/splash_screen.dart';
import 'presentation/screen/auth/login_screen.dart';
import 'presentation/screen/patient_dashboard.dart';
import 'presentation/screen/register_patient_screen.dart';
import 'presentation/screen/caregiver_dashboard.dart';
import 'presentation/screen/caregiver_settings_screen.dart';

/// Top-level background message handler for FCM
/// REQUIRED: @pragma('vm:entry-point') prevents Flutter tree-shaking in release builds
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  debugPrint("Handling background notification: ${message.messageId}");
}

/// Request runtime notification permissions for Android 13+ (API 33+) & iOS
Future<void> _checkNotificationPermission() async {
  // 1. System level permission
  final PermissionStatus status = await Permission.notification.status;
  if (status.isDenied || status.isPermanentlyDenied) {
    await Permission.notification.request();
  }

  // 2. Firebase Cloud Messaging explicit permission request
  final NotificationSettings settings =
  await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
    provisional: false,
  );
  debugPrint(
      'User notification permission status: ${settings.authorizationStatus}');
}

/// Ensure Firebase Auth has an active session to prevent permission-denied errors
Future<void> _ensureFirebaseAuth() async {
  try {
    if (FirebaseAuth.instance.currentUser == null) {
      await FirebaseAuth.instance.signInAnonymously();
    }
  } catch (e) {
    debugPrint("Firebase Auth auto-login warning: $e");
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize date formatting symbols for localized date headers (Urdu/English)
  await initializeDateFormatting();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Register FCM Background Message Handler BEFORE running app
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Ensure an active auth session exists before accessing Firestore
  await _ensureFirebaseAuth();

  // Request Android 13+ & iOS Notification Prompt
  await _checkNotificationPermission();

  // Initialize Push & Local Notifications for Care Plan Reminders
  await NotificationService().initialize(
    onNotificationClick: (data) {
      debugPrint("Care Plan notification clicked with payload: $data");
    },
  );

  // Retrieve saved Patient ID or fallback from current Auth / Storage
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  String? savedPatientId = prefs.getString('registered_patient_id');

  // Fallback check if user is logged in on this device
  final currentUser = FirebaseAuth.instance.currentUser;
  if (savedPatientId == null || savedPatientId.isEmpty) {
    if (currentUser != null && !currentUser.isAnonymous) {
      savedPatientId = currentUser.uid;
    }
  }

  // Refresh FCM token if an active session exists
  if (currentUser != null) {
    final String userType = prefs.getString('user_role') ?? 'caregivers';
    NotificationService().saveDeviceToken(
      userId: savedPatientId ?? currentUser.uid,
      userType: userType,
    );
  }

  final settingsProvider = SettingsProvider();
  if (savedPatientId != null && savedPatientId.isNotEmpty) {
    ThemeController.instance.listenToPatientTheme(savedPatientId);
    settingsProvider.initializeFirestoreSync(savedPatientId);
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: settingsProvider),
      ],
      child: const AlzheimersEaseApp(),
    ),
  );
}

class AlzheimersEaseApp extends StatelessWidget {
  const AlzheimersEaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        return ListenableBuilder(
          listenable: ThemeController.instance,
          builder: (context, child) {
            final bool isDark =
                settings.isDarkMode || ThemeController.instance.isDarkMode;

            return MaterialApp(
              title: "Alzheimer's Ease",
              debugShowCheckedModeBanner: false,
              locale: settings.locale,
              supportedLocales: AppLocalizations.supportedLocales,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              theme: AppTheme.buildLightTheme(
                primaryColor: ThemeController.instance.selectedPreset.primaryColor,
              ),
              darkTheme: AppTheme.buildDarkTheme(
                primaryColor: isDark &&
                    ThemeController.instance.selectedPreset.id ==
                        AppTheme.availablePresets[0].id
                    ? AppTheme.darkPrimaryAccent
                    : ThemeController.instance.selectedPreset.primaryColor,
              ),
              themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
              builder: (context, child) {
                return MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    textScaler: TextScaler.linear(settings.fontSizeScale),
                  ),
                  child: Directionality(
                    textDirection: settings.languageCode == 'ur'
                        ? TextDirection.rtl
                        : TextDirection.ltr,
                    child: child!,
                  ),
                );
              },
              initialRoute: '/',
              routes: {
                '/': (context) => const SplashScreen(),
                '/welcome': (context) => const WelcomeScreen(),
                '/register_patient': (context) =>
                const RegisterPatientScreen(initialMode: true),
                '/caregiver_dashboard': (context) =>
                const CaregiverDashboard(),
                '/settings': (context) => const CaregiverSettingsScreen(),
              },
            );
          },
        );
      },
    );
  }
}

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _authenticatePatient() async {
    final LocalAuthentication auth = LocalAuthentication();
    final loc = AppLocalizations.of(context)!;

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      String? patientId = prefs.getString('registered_patient_id');

      // Attempt to look up patientId from Firestore if missing locally
      if (patientId == null || patientId.isEmpty) {
        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser != null && !currentUser.isAnonymous) {
          patientId = currentUser.uid;
          await prefs.setString('registered_patient_id', patientId);
        }
      }

      if (!mounted) return;

      if (patientId == null || patientId.isEmpty) {
        _showErrorSnackBar(loc.noPatientError);
        return;
      }

      // Fetch saved password locally or fallback to Firestore
      String? savedPassword =
          prefs.getString('patient_password_$patientId') ??
              prefs.getString('registered_patient_password');

      if (savedPassword == null || savedPassword.isEmpty) {
        try {
          if (FirebaseAuth.instance.currentUser == null) {
            await FirebaseAuth.instance.signInAnonymously();
          }
          final doc = await FirebaseFirestore.instance
              .collection('patients')
              .doc(patientId)
              .get();
          if (doc.exists && doc.data() != null) {
            savedPassword = doc.data()?['password'] as String?;
            if (savedPassword != null && savedPassword.isNotEmpty) {
              await prefs.setString(
                  'patient_password_$patientId', savedPassword);
              await prefs.setString(
                  'registered_patient_password', savedPassword);
            }
          }
        } catch (e) {
          debugPrint("Firestore fetch error for patient password: $e");
        }
      }

      final bool canCheckBiometrics = await auth.canCheckBiometrics;
      final bool isDeviceSupported = await auth.isDeviceSupported();

      if (!mounted) return;

      if (!canCheckBiometrics && !isDeviceSupported) {
        _showPasswordDialog(patientId, savedPassword);
        return;
      }

      final bool didAuthenticate = await auth.authenticate(
        localizedReason: loc.useFingerprint,
        biometricOnly: true,
        persistAcrossBackgrounding: true,
      );

      if (!mounted) return;

      if (didAuthenticate) {
        _navigateToPatientDashboard(patientId);
      } else {
        _showPasswordDialog(patientId, savedPassword);
      }
    } catch (e) {
      if (!mounted) return;

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? patientId = prefs.getString('registered_patient_id');
      final String? savedPassword =
          prefs.getString('patient_password_$patientId') ??
              prefs.getString('registered_patient_password');

      if (!mounted) return;

      if (patientId != null && patientId.isNotEmpty) {
        _showPasswordDialog(patientId, savedPassword);
      } else {
        _showErrorSnackBar(loc.authFailed);
      }
    }
  }

  void _showPasswordDialog(String patientId, String? correctPassword) {
    _passwordController.clear();
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: theme.cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: theme.colorScheme.outline, width: 1),
          ),
          title: Text(
            loc.enterPatientPass,
            style: TextStyle(color: theme.colorScheme.onSurface),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _passwordController,
                obscureText: true,
                style: TextStyle(color: theme.colorScheme.onSurface),
                decoration: InputDecoration(
                  hintText: loc.passwordHint,
                  hintStyle: TextStyle(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                loc.cancel,
                style: TextStyle(color: theme.colorScheme.primary),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final entered = _passwordController.text.trim();

                if (correctPassword != null &&
                    correctPassword.isNotEmpty &&
                    entered == correctPassword) {
                  Navigator.pop(dialogContext);
                  if (mounted) {
                    _navigateToPatientDashboard(patientId);
                  }
                } else {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    SnackBar(
                      content: Text(loc.invalidPassError),
                      backgroundColor: theme.colorScheme.error,
                    ),
                  );
                }
              },
              child: Text(loc.login),
            ),
          ],
        );
      },
    );
  }

  void _navigateToPatientDashboard(String patientId) async {
    if (!mounted) return;

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('registered_patient_id', patientId);
    await prefs.setString('user_role', 'patients');

    try {
      final String? savedPassword =
          prefs.getString('patient_password_$patientId') ??
              prefs.getString('registered_patient_password');

      final String patientEmail = "patient_$patientId@app.com";

      if (savedPassword != null && savedPassword.isNotEmpty) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: patientEmail,
          password: savedPassword,
        );
      } else if (FirebaseAuth.instance.currentUser == null) {
        await FirebaseAuth.instance.signInAnonymously();
      }
    } catch (e) {
      debugPrint("Auth login notice during patient navigation: $e");
      if (FirebaseAuth.instance.currentUser == null) {
        await FirebaseAuth.instance.signInAnonymously();
      }
    }

    if (!mounted) return;

    ThemeController.instance.listenToPatientTheme(patientId);
    Provider.of<SettingsProvider>(context, listen: false)
        .initializeFirestoreSync(patientId);

    NotificationService().saveDeviceToken(
      userId: patientId,
      userType: 'patients',
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => PatientDashboard(patientId: patientId),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return GradientWrapper(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                loc.appTitle,
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineLarge?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                loc.subtitle,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 60),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.surface,
                  foregroundColor: theme.colorScheme.primary,
                  minimumSize: const Size(double.infinity, 56.0),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: theme.colorScheme.outline, width: 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const LoginScreen()),
                  );
                },
                child: Text(
                  loc.iAmCaregiver,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                height: 56,
                decoration: BoxDecoration(
                  gradient: AppTheme.getPrimaryGradient(context),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ElevatedButton(
                  onPressed: _authenticatePatient,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 56.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    loc.iAmPatient,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
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