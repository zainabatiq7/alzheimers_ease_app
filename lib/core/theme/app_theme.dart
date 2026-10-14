import 'package:flutter/material.dart';

/// Represents a custom color theme preset designed for Alzheimer's accessibility.
class AppThemePreset {
  final String id;
  final String name;
  final Color primaryColor;
  final Color secondaryColor;
  final List<Color> gradientColors;

  const AppThemePreset({
    required this.id,
    required this.name,
    required this.primaryColor,
    required this.secondaryColor,
    required this.gradientColors,
  });
}

class AppTheme {
  // --- EXACT DEEP BLUE & OCEAN GRADIENT LIGHT MODE PALETTE ---
  static const Color lightBackgroundColor = Color(0xFFF3F7FA); // App Main Canvas (Soft Blue-Gray)
  static const Color lightSurfaceColor = Color(0xFFFFFFFF);     // Card Container
  static const Color lightPrimaryAccent = Color(0xFF0056B3);    // Rich Royal Blue
  static const Color lightSecondaryAccent = Color(0xFF1B8A5A);  // Deep Sage Green
  static const Color lightTextPrimary = Color(0xFF0E1726);      // Dark Navy-Black (15:1 AAA)
  static const Color lightTextSecondary = Color(0xFF4A5868);    // Slate Blue-Gray
  static const Color lightBorder = Color(0xFFE2E8F0);           // Soft Border
  static const Color lightError = Color(0xFFC62828);            // Warm Red

  // Light Mode Primary Gradient (Top-Left to Bottom-Right)
  static const Color lightGradientStart = Color(0xFF0B3C5D);   // Deep Midnight Blue
  static const Color lightGradientEnd = Color(0xFF0088B2);     // Ocean Cyan Blue

  // --- EXACT DEEP BLUE & OCEAN GRADIENT DARK MODE PALETTE ---
  static const Color darkBackgroundColor = Color(0xFF0B111E);   // Deep Navy Black Canvas
  static const Color darkSurfaceColor = Color(0xFF162032);      // Elevated Midnight Blue Card
  static const Color darkPrimaryAccent = Color(0xFF38BDF8);     // Vibrant Ocean Cyan (Soft Glow CTA)
  static const Color darkSecondaryAccent = Color(0xFF4ADE80);   // Soft Sage Green
  static const Color darkTextPrimary = Color(0xFFF1F5F9);       // Soft Off-White (14:1 AAA)
  static const Color darkTextSecondary = Color(0xFF94A3B8);     // Cool Slate Blue
  static const Color darkBorder = Color(0xFF26354A);            // Defined Card Outline
  static const Color darkError = Color(0xFFF87171);             // Soft Red

  // Dark Mode Primary Gradient (Top-Left to Bottom-Right)
  static const Color darkGradientStart = Color(0xFF1E3A8A);    // Deep Sapphire
  static const Color darkGradientEnd = Color(0xFF0284C7);      // Bright Ocean Blue

  /// Returns the required dynamic linear gradient for headers, main buttons, and hero cards
  static LinearGradient getPrimaryGradient(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: isDark
          ? const [darkGradientStart, darkGradientEnd]
          : const [lightGradientStart, lightGradientEnd],
    );
  }

  /// Presets aligned with the Deep Blue & Ocean palette
  static const List<AppThemePreset> availablePresets = [
    AppThemePreset(
      id: 'deep_ocean_default',
      name: 'Deep Ocean (Default)',
      primaryColor: lightPrimaryAccent,
      secondaryColor: lightSecondaryAccent,
      gradientColors: [lightGradientStart, lightGradientEnd],
    ),
    AppThemePreset(
      id: 'sapphire_glow',
      name: 'Sapphire Glow',
      primaryColor: Color(0xFF1E3A8A),
      secondaryColor: Color(0xFF1B8A5A),
      gradientColors: [Color(0xFF1E3A8A), Color(0xFF0284C7)],
    ),
  ];

  /// Helper to fetch a preset by ID safely
  static AppThemePreset getPresetById(String? id) {
    return availablePresets.firstWhere(
          (preset) => preset.id == id,
      orElse: () => availablePresets[0],
    );
  }

  /// Dynamic Light Theme Builder
  static ThemeData buildLightTheme({Color? primaryColor}) {
    final activePrimary = primaryColor ?? lightPrimaryAccent;

    final colorScheme = ColorScheme.light(
      primary: activePrimary,
      onPrimary: Colors.white,
      secondary: lightSecondaryAccent,
      onSecondary: Colors.white,
      surface: lightSurfaceColor,
      error: lightError,
      onError: Colors.white,
      onSurface: lightTextPrimary,
      onSurfaceVariant: lightTextSecondary,
      outline: lightBorder,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: activePrimary,
      scaffoldBackgroundColor: lightBackgroundColor,
      cardColor: lightSurfaceColor,
      dividerColor: lightBorder,
      colorScheme: colorScheme,

      // Global App Bar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: lightSurfaceColor,
        foregroundColor: lightTextPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: lightTextPrimary),
        titleTextStyle: TextStyle(
          fontSize: 20.0,
          fontWeight: FontWeight.bold,
          color: lightTextPrimary,
        ),
      ),

      // Typography (Optimized for Legibility & AAA Contrast)
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 28.0,
          fontWeight: FontWeight.bold,
          color: lightTextPrimary,
          height: 1.2,
        ),
        titleLarge: TextStyle(
          fontSize: 22.0,
          fontWeight: FontWeight.w600,
          color: lightTextPrimary,
          height: 1.2,
        ),
        bodyLarge: TextStyle(
          fontSize: 18.0,
          color: lightTextPrimary,
          height: 1.3,
        ),
        bodyMedium: TextStyle(
          fontSize: 16.0,
          color: lightTextSecondary,
          height: 1.3,
        ),
      ),

      // Primary Button Theme with 56px Touch Target & 1px Outline
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: activePrimary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 56.0),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: lightBorder, width: 1.0),
          ),
          elevation: 0,
        ),
      ),

      // Outlined Button Theme with 56px Touch Target
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: activePrimary,
          minimumSize: const Size(double.infinity, 56.0),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          side: const BorderSide(color: lightBorder, width: 1.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      // Input Field Styling
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lightSurfaceColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: lightBorder, width: 1.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: lightBorder, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: activePrimary, width: 2.0),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: lightError, width: 1.5),
        ),
        labelStyle: const TextStyle(color: lightTextSecondary),
        hintStyle: const TextStyle(color: lightTextSecondary),
      ),

      // Card Theme with Glassmorphic Surface Depth & 1px Outline Boundary
      cardTheme: CardThemeData(
        color: lightSurfaceColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: lightBorder, width: 1.0),
        ),
      ),

      dividerTheme: const DividerThemeData(
        color: lightBorder,
        thickness: 1.0,
      ),
    );
  }

  /// Dynamic Dark Theme Builder
  static ThemeData buildDarkTheme({Color? primaryColor}) {
    final activePrimary = (primaryColor == null || primaryColor == lightPrimaryAccent)
        ? darkPrimaryAccent
        : primaryColor;

    final colorScheme = ColorScheme.dark(
      primary: activePrimary,
      onPrimary: darkBackgroundColor,
      secondary: darkSecondaryAccent,
      onSecondary: darkBackgroundColor,
      surface: darkSurfaceColor,
      error: darkError,
      onError: Colors.black,
      onSurface: darkTextPrimary,
      onSurfaceVariant: darkTextSecondary,
      outline: darkBorder,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: activePrimary,
      scaffoldBackgroundColor: darkBackgroundColor,
      cardColor: darkSurfaceColor,
      dividerColor: darkBorder,
      colorScheme: colorScheme,

      // Global App Bar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: darkSurfaceColor,
        foregroundColor: darkTextPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: darkTextPrimary),
        titleTextStyle: TextStyle(
          fontSize: 20.0,
          fontWeight: FontWeight.bold,
          color: darkTextPrimary,
        ),
      ),

      // Typography
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 28.0,
          fontWeight: FontWeight.bold,
          color: darkTextPrimary,
          height: 1.2,
        ),
        titleLarge: TextStyle(
          fontSize: 22.0,
          fontWeight: FontWeight.w600,
          color: darkTextPrimary,
          height: 1.2,
        ),
        bodyLarge: TextStyle(
          fontSize: 18.0,
          color: darkTextPrimary,
          height: 1.3,
        ),
        bodyMedium: TextStyle(
          fontSize: 16.0,
          color: darkTextSecondary,
          height: 1.3,
        ),
      ),

      // Primary Button Theme with 56px Touch Target & 1px Outline
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: activePrimary,
          foregroundColor: darkBackgroundColor,
          minimumSize: const Size(double.infinity, 56.0),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: darkBorder, width: 1.0),
          ),
          elevation: 0,
        ),
      ),

      // Outlined Button Theme with 56px Touch Target
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: darkTextPrimary,
          minimumSize: const Size(double.infinity, 56.0),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          side: const BorderSide(color: darkBorder, width: 1.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      // Input Field Styling
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurfaceColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: darkBorder, width: 1.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: darkBorder, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: activePrimary, width: 2.0),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: darkError, width: 1.5),
        ),
        labelStyle: const TextStyle(color: darkTextSecondary),
        hintStyle: const TextStyle(color: darkTextSecondary),
      ),

      // Card Theme with Glassmorphic Surface Depth & 1px Outline Boundary
      cardTheme: CardThemeData(
        color: darkSurfaceColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: darkBorder, width: 1.0),
        ),
      ),

      dividerTheme: const DividerThemeData(
        color: darkBorder,
        thickness: 1.0,
      ),
    );
  }

  // Legacy Fallbacks
  static ThemeData get lightTheme => buildLightTheme();
  static ThemeData get darkTheme => buildDarkTheme();
}