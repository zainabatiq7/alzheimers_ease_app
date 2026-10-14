import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:alzhimers_ease/l10n/app_localizations.dart';
import 'package:alzhimers_ease/data/services/notification_service.dart';
import '../caregiver_dashboard.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isLogin = true;
  bool _isLoading = false;
  bool _isGoogleLoading = false;
  bool _obscurePassword = true;

  // Helper method to setup post-login caregiver session
  Future<void> _handlePostAuthSetup(User user) async {
    final String uid = user.uid;

    // 1. Write Caregiver record into Firestore (if not existing)
    await FirebaseFirestore.instance
        .collection('caregivers')
        .doc(uid)
        .set({
      'email': user.email ?? '',
      'displayName': user.displayName ?? '',
      'userType': 'caregivers',
      'lastLogin': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    // 2. Save local preferences for FCM & session management
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_role', 'caregivers');
    await prefs.setString('caregiver_id', uid);

    // 3. Register FCM Token for notifications
    await NotificationService().saveDeviceToken(
      userId: uid,
      userType: 'caregivers',
    );

    if (!mounted) return;

    // 4. Route to Caregiver Dashboard
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const CaregiverDashboard()),
    );
  }

  // Google Sign-In Handler
  Future<void> _signInWithGoogle() async {
    final loc = AppLocalizations.of(context)!;
    setState(() => _isGoogleLoading = true);

    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        // User cancelled the Google sign-in prompt
        setState(() => _isGoogleLoading = false);
        return;
      }

      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
      await _auth.signInWithCredential(credential);

      if (userCredential.user != null) {
        _showSnackBar(loc.loggedInSuccess, isError: false);
        await _handlePostAuthSetup(userCredential.user!);
      }
    } on FirebaseAuthException catch (e) {
      _showSnackBar(e.message ?? loc.authErrorOccurred, isError: true);
    } catch (e) {
      _showSnackBar(loc.unexpectedErrorOccurred, isError: true);
    } finally {
      if (mounted) {
        setState(() => _isGoogleLoading = false);
      }
    }
  }

  // Standard Email/Password Handler
  Future<void> _submitForm() async {
    final loc = AppLocalizations.of(context)!;
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showSnackBar(loc.pleaseFillAllFields, isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      UserCredential userCredential;

      if (_isLogin) {
        userCredential = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        _showSnackBar(loc.loggedInSuccess, isError: false);
      } else {
        userCredential = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        _showSnackBar(loc.accountCreatedSuccess, isError: false);
      }

      if (userCredential.user != null) {
        await _handlePostAuthSetup(userCredential.user!);
      }
    } on FirebaseAuthException catch (e) {
      _showSnackBar(e.message ?? loc.authErrorOccurred, isError: true);
    } catch (e) {
      _showSnackBar(loc.unexpectedErrorOccurred, isError: true);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSnackBar(String message, {required bool isError}) {
    final theme = Theme.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
        isError ? theme.colorScheme.error : theme.colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          _isLogin ? loc.welcomeBack : loc.createAccount,
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: theme.appBarTheme.foregroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: theme.dividerColor.withValues(alpha: 0.3),
            height: 1.0,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),

              // Email Field
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
                decoration: InputDecoration(
                  labelText: loc.emailAddress,
                  labelStyle: textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                  filled: true,
                  fillColor: theme.cardColor,
                  prefixIcon: Icon(
                    Icons.email_outlined,
                    color: theme.colorScheme.primary,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: theme.dividerColor.withValues(alpha: 0.4),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: theme.dividerColor.withValues(alpha: 0.4),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: theme.colorScheme.primary,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Password Field
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                style: textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
                decoration: InputDecoration(
                  labelText: loc.password,
                  labelStyle: textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                  filled: true,
                  fillColor: theme.cardColor,
                  prefixIcon: Icon(
                    Icons.lock_outline_rounded,
                    color: theme.colorScheme.primary,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: theme.dividerColor.withValues(alpha: 0.4),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: theme.dividerColor.withValues(alpha: 0.4),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: theme.colorScheme.primary,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Submit Action Button
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: (_isLoading || _isGoogleLoading) ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _isLoading
                      ? SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      color: theme.colorScheme.onPrimary,
                      strokeWidth: 2,
                    ),
                  )
                      : Text(
                    _isLogin ? loc.logIn : loc.signUp,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Divider Row ("OR")
              Row(
                children: [
                  Expanded(
                    child: Divider(
                      color: theme.dividerColor.withValues(alpha: 0.5),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Text(
                      "OR",
                      style: textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Divider(
                      color: theme.dividerColor.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Google Sign In Outlined Button
              SizedBox(
                height: 52,
                child: OutlinedButton(
                  onPressed: (_isLoading || _isGoogleLoading)
                      ? null
                      : _signInWithGoogle,
                  style: OutlinedButton.styleFrom(
                    backgroundColor: theme.cardColor,
                    side: BorderSide(
                      color: theme.dividerColor.withValues(alpha: 0.5),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _isGoogleLoading
                      ? SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      color: theme.colorScheme.primary,
                      strokeWidth: 2,
                    ),
                  )
                      : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.g_mobiledata_rounded,
                        size: 32,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Continue with Google",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Toggle Login / Sign Up
              TextButton(
                onPressed: () {
                  setState(() {
                    _isLogin = !_isLogin;
                  });
                },
                child: Text(
                  _isLogin ? loc.dontHaveAccount : loc.alreadyHaveAccount,
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
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