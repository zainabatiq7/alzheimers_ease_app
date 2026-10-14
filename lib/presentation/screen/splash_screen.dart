import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:alzhimers_ease/main.dart';
import 'package:alzhimers_ease/l10n/app_localizations.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _logoFade;
  late Animation<double> _logoScale;
  late Animation<double> _textFade;
  late Animation<Offset> _textSlide;

  final AudioPlayer _audioPlayer = AudioPlayer();
  StreamSubscription? _playerCompleteSubscription;
  bool _isNavigating = false;

  static const Color _indigoPrimary = Color(0xFF1E1B4B);

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    // Smooth logo fade-in & delicate scale
    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.45, curve: Curves.easeIn),
      ),
    );

    _logoScale = Tween<double>(begin: 0.88, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.50, curve: Curves.easeOutCubic),
      ),
    );

    // Slogan text & loader slide up cleanly
    _textFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.40, 0.80, curve: Curves.easeIn),
      ),
    );

    _textSlide = Tween<Offset>(
      begin: const Offset(0.0, 0.25),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.40, 0.80, curve: Curves.easeOutCubic),
      ),
    );

    _startSplashSequence();
  }

  Future<void> _startSplashSequence() async {
    _animationController.forward();

    // Navigate to WelcomeScreen as soon as splash.mp3 finishes playing
    _playerCompleteSubscription = _audioPlayer.onPlayerComplete.listen((_) {
      _navigateToNextScreen();
    });

    try {
      await _audioPlayer.play(AssetSource('audio/splash.mp3'));
    } catch (e) {
      debugPrint("Splash audio playback error: $e");
    }

    // Fallback timer if audio fails or is delayed
    Future.delayed(const Duration(seconds: 5), () {
      if (!_isNavigating && mounted) {
        _navigateToNextScreen();
      }
    });
  }

  void _navigateToNextScreen() {
    if (_isNavigating || !mounted) return;
    _isNavigating = true;

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 700),
        pageBuilder: (context, animation, secondaryAnimation) =>
        const WelcomeScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _playerCompleteSubscription?.cancel();
    _audioPlayer.stop();
    _audioPlayer.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 3),

            // Perfectly centered logo on transparent canvas
            Center(
              child: FadeTransition(
                opacity: _logoFade,
                child: ScaleTransition(
                  scale: _logoScale,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: screenSize.width * 0.68,
                      maxHeight: screenSize.height * 0.38,
                    ),
                    child: Image.asset(
                      'assets/icons/logo.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),

            const Spacer(flex: 2),

            // Animated Tagline & Loading indicator
            SlideTransition(
              position: _textSlide,
              child: FadeTransition(
                opacity: _textFade,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l10n.splashTagline,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.1,
                        color: _indigoPrimary.withValues(alpha: 0.85),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        color: _indigoPrimary,
                        strokeWidth: 2.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 36),
          ],
        ),
      ),
    );
  }
}