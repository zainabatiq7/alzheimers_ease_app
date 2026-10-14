import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PersistentDateHeader extends StatefulWidget {
  const PersistentDateHeader({super.key});

  @override
  State<PersistentDateHeader> createState() => _PersistentDateHeaderState();
}

class _PersistentDateHeaderState extends State<PersistentDateHeader>
    with WidgetsBindingObserver {
  late Timer _timer;
  late DateTime _now;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _now = DateTime.now();

    // Refresh date header every minute to stay accurate
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) {
        setState(() {
          _now = DateTime.now();
        });
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Refresh instantly when app wakes up from background
      setState(() {
        _now = DateTime.now();
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Obtain the active language code (e.g., 'ur', 'en', 'ar', 'es')
    final String currentLocale = Localizations.localeOf(context).languageCode;

    // Format day of the week (e.g., "TUESDAY" or "منگل")
    final String dayName = DateFormat.EEEE(currentLocale).format(_now);

    // Format localized date string (e.g., "August 18, 2026" or "18 اگست 2026")
    final String fullDate = DateFormat.yMMMMd(currentLocale).format(_now);

    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF008080).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF008080).withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            dayName.toUpperCase(),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF008080),
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            fullDate,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : const Color(0xFF2C3E50),
            ),
          ),
        ],
      ),
    );
  }
}