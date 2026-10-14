import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// A lightweight background wrapper that applies a consistent accessible surface gradient
/// without creating nested Scaffolds or breaking gesture/navigation routes.
class GradientWrapper extends StatelessWidget {
  final Widget child;

  const GradientWrapper({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Soft, non-glare canvas gradients aligned with exact Deep Blue & Ocean palette
    final List<Color> backgroundColors = isDark
        ? [
      AppTheme.darkBackgroundColor, // Deep Navy Black (#0B111E)
      AppTheme.darkSurfaceColor,     // Elevated Midnight Blue (#162032)
    ]
        : [
      AppTheme.lightBackgroundColor, // Very Light Blue-Gray (#F3F7FA)
      const Color(0xFFE2EBF1),       // Soft subtle tint transition
    ];

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: backgroundColors,
        ),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: child,
      ),
    );
  }
}