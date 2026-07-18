import 'package:flutter/material.dart';

// ─── Konvert 2.0 Professional Color Tokens ───────────────────────────────────
// Theme: Clean Minimalist (Silicon Valley vibe)
// Primary accent: Professional Indigo (#4F46E5)

class KColors {
  KColors._();

  // ── Dark Mode Tokens ──
  static const Color background = Color(0xFF030712); // Gray 950
  static const Color surface = Color(0xFF111827); // Gray 900
  static const Color surfaceContainerLow = Color(0xFF1F2937); // Gray 800
  static const Color surfaceContainer = Color(0xFF1F2937); // Gray 800
  static const Color surfaceContainerHigh = Color(0xFF374151); // Gray 700
  static const Color surfaceContainerHighest = Color(0xFF4B5563); // Gray 600

  static const Color onSurface = Color(0xFFF9FAFB); // Gray 50
  static const Color onSurfaceVariant = Color(0xFF9CA3AF); // Gray 400
  static const Color onBackground = Color(0xFFF9FAFB);

  static const Color outline = Color(0xFF374151); // Gray 700
  static const Color outlineVariant = Color(0xFF1F2937); // Gray 800

  // ── Light Mode Tokens ──
  static const Color lightBackground = Color(0xFFF9FAFB); // Gray 50
  static const Color lightSurface = Color(0xFFFFFFFF); // White
  static const Color lightSurfaceContainer = Color(0xFFF3F4F6); // Gray 100
  static const Color lightSurfaceContainerHigh = Color(0xFFE5E7EB); // Gray 200
  static const Color lightOnSurface = Color(0xFF111827); // Gray 900
  static const Color lightOnSurfaceVariant = Color(0xFF6B7280); // Gray 500
  
  static const Color lightOutline = Color(0xFFE5E7EB); // Gray 200
  static const Color lightOutlineVariant = Color(0xFFF3F4F6); // Gray 100

  // ── Accent – Primary (Indigo) ──
  static Color primary = const Color(0xFF4F46E5); // Indigo 600 default
  static const Color onPrimary = Color(0xFFFFFFFF);
  
  // ── Status ──
  static const Color error = Color(0xFFEF4444); // Red 500
  static const Color success = Color(0xFF10B981); // Emerald 500

  // ── Legacy Aliases (Prevents compile errors while refactoring) ──
  static Color glassCardColor = surface;
  static Color glassBorderColor = outline;
  static Color lightCardBorderColor = lightOutline;
  static Color lightCardShadowColor = Colors.black.withValues(alpha: 0.02);

  // ── Legacy Aliases (Prevents compile errors while refactoring) ──
  static Color get tertiary => surfaceContainerHigh;
  static LinearGradient get primaryGradientVertical => primaryGradient;
  static Color get secondary => primary;
  static const Color primaryContainer = surfaceContainer;
  static const Color onPrimaryContainer = onSurface;
  static const Color onSecondary = onSurface;
  static const Color secondaryContainer = surfaceContainer;
  static const Color onSecondaryContainer = onSurface;
  static const Color onTertiary = onSurface;
  static const Color tertiaryContainer = surfaceContainer;
  static const Color onError = onSurface;
  static const Color errorContainer = surfaceContainer;
  static Color get inversePrimary => primary;
  static Color get primaryDim => primary;
  
  // Flat gradient for legacy button support
  static LinearGradient get primaryGradient => LinearGradient(
    colors: [primary, primary.withValues(alpha: 0.85)], 
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}

// ─── Decoration Helpers ───────────────────────────────────────────────────────

class KDecorations {
  KDecorations._();

  /// Dark mode flat card with crisp border (replaces glassCard)
  static BoxDecoration glassCard({
    double radius = 16,
    Color? borderColor,
    List<BoxShadow>? shadows,
  }) {
    return BoxDecoration(
      color: KColors.surface,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: borderColor ?? KColors.outline,
        width: 1,
      ),
      boxShadow: shadows, // Usually null for flat design
    );
  }

  /// Light mode flat card with crisp border
  static BoxDecoration lightCard({
    double radius = 16,
    Color? color,
  }) {
    return BoxDecoration(
      color: color ?? KColors.lightSurface,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: KColors.lightOutline,
        width: 1,
      ),
      // Subtle 3% opacity shadow just to lift slightly
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.03),
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  /// Solid primary button (replaces gradient button for modern look)
  static BoxDecoration gradientButton({double radius = 12}) {
    return BoxDecoration(
      color: KColors.primary,
      borderRadius: BorderRadius.circular(radius),
      // subtle shadow for CTA
      boxShadow: [
        BoxShadow(
          color: KColors.primary.withValues(alpha: 0.2),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  /// Ghost button (dark mode)
  static BoxDecoration ghostButtonDark({double radius = 12}) {
    return BoxDecoration(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: KColors.outline, width: 1),
    );
  }

  /// Ghost button (light mode)
  static BoxDecoration ghostButtonLight({double radius = 12}) {
    return BoxDecoration(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: KColors.lightOutline, width: 1),
    );
  }
}

// ─── Extension for theme-aware card decoration ────────────────────────────────

extension KThemeHelpers on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  BoxDecoration get bentoCard => isDark
      ? KDecorations.glassCard()
      : KDecorations.lightCard();

  Color get cardBg => isDark
      ? KColors.surface
      : KColors.lightSurface;

  Color get textPrimary => isDark
      ? KColors.onSurface
      : KColors.lightOnSurface;

  Color get textSecondary => isDark
      ? KColors.onSurfaceVariant
      : KColors.lightOnSurfaceVariant;

  Color get scaffoldBg => isDark
      ? KColors.background
      : KColors.lightBackground;

  Color get sectionBg => isDark
      ? KColors.surfaceContainerLow
      : KColors.lightSurfaceContainer;
}
