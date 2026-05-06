import 'package:flutter/material.dart';

// ─── Konvert Obsidian Color Tokens ───────────────────────────────────────────
// Source: UI_IDEA/screen/DESIGN.md — "Konvert Obsidian" system
// Primary accent: Electric Violet (#8B5CF6) → Indigo (#6366F1)

class KColors {
  KColors._();

  // ── Backgrounds ──
  static const Color background = Color(0xFF0B1326);
  static const Color surface = Color(0xFF0B1326);
  static const Color surfaceDim = Color(0xFF0B1326);
  static const Color surfaceContainerLowest = Color(0xFF060E20);
  static const Color surfaceContainerLow = Color(0xFF131B2E);
  static const Color surfaceContainer = Color(0xFF171F33);
  static const Color surfaceContainerHigh = Color(0xFF222A3D);
  static const Color surfaceContainerHighest = Color(0xFF2D3449);
  static const Color surfaceBright = Color(0xFF31394D);

  // ── Text ──
  static const Color onSurface = Color(0xFFDAE2FD);
  static const Color onSurfaceVariant = Color(0xFFCBC3D7);
  static const Color onBackground = Color(0xFFDAE2FD);

  // ── Accent – Primary (Violet) ──
  static const Color primary = Color(0xFF8B5CF6); // Electric Violet
  static const Color primaryDim = Color(0xFFD0BCFF);
  static const Color primaryContainer = Color(0xFFA078FF);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onPrimaryContainer = Color(0xFF340080);
  static const Color inversePrimary = Color(0xFF6D3BD7);

  // ── Accent – Secondary (Indigo) ──
  static const Color secondary = Color(0xFF6366F1);
  static const Color secondaryDim = Color(0xFFC0C1FF);
  static const Color secondaryContainer = Color(0xFF3131C0);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color onSecondaryContainer = Color(0xFFB0B2FF);

  // ── Tertiary ──
  static const Color tertiary = Color(0xFFCEBDFF);
  static const Color tertiaryContainer = Color(0xFF9B7FED);
  static const Color onTertiary = Color(0xFF381385);

  // ── Status ──
  static const Color error = Color(0xFFFFB4AB);
  static const Color onError = Color(0xFF690005);
  static const Color errorContainer = Color(0xFF93000A);
  static const Color success = Color(0xFF34D399); // Emerald green
  static const Color successDim = Color(0xFF6EE7B7);

  // ── Borders / Outline ──
  static const Color outline = Color(0xFF958EA0);
  static const Color outlineVariant = Color(0xFF494454);

  // ── Glass effect ──
  // Glass card fill: #2D3449 at 40% opacity
  static Color glassCardColor = const Color(0xFF2D3449).withValues(alpha: 0.40);
  // Inner glow border: white at 10%
  static Color glassBorderColor = Colors.white.withValues(alpha: 0.10);
  // Violet inner glow
  static Color innerGlowColor = const Color(0xFF8B5CF6).withValues(alpha: 0.15);
  // Active bloom (outer glow)
  static Color activeBloomColor = const Color(0xFF8B5CF6).withValues(alpha: 0.30);

  // ── Gradient ──
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient primaryGradientVertical = LinearGradient(
    colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ── Light Mode Tokens ──
  static const Color lightBackground = Color(0xFFF5F3FF);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceContainer = Color(0xFFF0ECFF);
  static const Color lightSurfaceContainerHigh = Color(0xFFE8E2FF);
  static const Color lightOnSurface = Color(0xFF1C1838);
  static const Color lightOnSurfaceVariant = Color(0xFF49454F);
  static const Color lightOutline = Color(0xFF79747E);
  static const Color lightOutlineVariant = Color(0xFFCAC4D0);
  static Color lightCardBorderColor = const Color(0xFF8B5CF6).withValues(alpha: 0.12);
  static Color lightCardShadowColor = const Color(0xFF8B5CF6).withValues(alpha: 0.08);
}

// ─── Decoration Helpers ───────────────────────────────────────────────────────

class KDecorations {
  KDecorations._();

  /// Glass morphism card — used in dark mode bento tiles
  static BoxDecoration glassCard({
    double radius = 20,
    Color? borderColor,
    List<BoxShadow>? shadows,
  }) {
    return BoxDecoration(
      color: KColors.glassCardColor,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: borderColor ?? KColors.glassBorderColor,
        width: 1,
      ),
      boxShadow: shadows,
    );
  }

  /// Solid card — used in light mode (no blur, just shadow)
  static BoxDecoration lightCard({
    double radius = 20,
    Color? color,
  }) {
    return BoxDecoration(
      color: color ?? KColors.lightSurface,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: KColors.lightCardBorderColor,
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: KColors.lightCardShadowColor,
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  /// Active bloom outer glow box shadow
  static List<BoxShadow> get activeBloom => [
    BoxShadow(
      color: KColors.activeBloomColor,
      blurRadius: 20,
      spreadRadius: 0,
    ),
  ];

  /// Subtle inner glow box shadow
  static List<BoxShadow> get innerGlow => [
    BoxShadow(
      color: KColors.innerGlowColor,
      blurRadius: 12,
      spreadRadius: -2,
    ),
  ];

  /// Gradient button decoration
  static BoxDecoration gradientButton({double radius = 16}) {
    return BoxDecoration(
      gradient: KColors.primaryGradient,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF8B5CF6).withValues(alpha: 0.35),
          blurRadius: 20,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  /// Ghost button (dark mode)
  static BoxDecoration ghostButtonDark({double radius = 16}) {
    return BoxDecoration(
      color: Colors.white.withValues(alpha: 0.06),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: Colors.white.withValues(alpha: 0.12),
        width: 1,
      ),
    );
  }

  /// Ghost button (light mode)
  static BoxDecoration ghostButtonLight({double radius = 16}) {
    return BoxDecoration(
      color: const Color(0xFF8B5CF6).withValues(alpha: 0.06),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: const Color(0xFF8B5CF6).withValues(alpha: 0.25),
        width: 1,
      ),
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
      ? KColors.glassCardColor
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
