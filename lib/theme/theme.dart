import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

// ─── Konvert Obsidian Theme ───────────────────────────────────────────────────
// v1.6.3 — Obsidian design system
// Dark mode: deep obsidian + electric violet
// Light mode: white/lavender surfaces + violet accent (Inter throughout)

// ── DARK MODE ────────────────────────────────────────────────────────────────

final ThemeData darkmode = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  scaffoldBackgroundColor: KColors.background,

  colorScheme: const ColorScheme(
    brightness: Brightness.dark,
    primary: KColors.primary,
    onPrimary: KColors.onPrimary,
    primaryContainer: KColors.primaryContainer,
    onPrimaryContainer: KColors.onPrimaryContainer,
    secondary: KColors.secondary,
    onSecondary: KColors.onSecondary,
    secondaryContainer: KColors.secondaryContainer,
    onSecondaryContainer: KColors.onSecondaryContainer,
    tertiary: KColors.tertiary,
    onTertiary: KColors.onTertiary,
    tertiaryContainer: KColors.tertiaryContainer,
    onTertiaryContainer: Color(0xFF31057E),
    error: KColors.error,
    onError: KColors.onError,
    errorContainer: KColors.errorContainer,
    onErrorContainer: Color(0xFFFFDAD6),
    surface: KColors.surface,
    onSurface: KColors.onSurface,
    onSurfaceVariant: KColors.onSurfaceVariant,
    outline: KColors.outline,
    outlineVariant: KColors.outlineVariant,
    shadow: Colors.black,
    inverseSurface: KColors.onSurface,
    onInverseSurface: Color(0xFF283044),
    inversePrimary: KColors.inversePrimary,
    surfaceTint: KColors.primary,
  ),

  // ── App Bar ──
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.transparent,
    elevation: 0,
    systemOverlayStyle: SystemUiOverlayStyle.light,
    titleTextStyle: GoogleFonts.inter(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: KColors.onSurface,
    ),
    iconTheme: const IconThemeData(color: KColors.onSurface),
  ),

  // ── Navigation Bar ──
  navigationBarTheme: NavigationBarThemeData(
    backgroundColor: Colors.transparent,
    elevation: 0,
    indicatorColor: KColors.primary.withValues(alpha: 0.15),
    labelTextStyle: WidgetStateProperty.resolveWith((states) {
      final active = states.contains(WidgetState.selected);
      return GoogleFonts.inter(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
        color: active ? KColors.primary : KColors.onSurfaceVariant,
      );
    }),
    iconTheme: WidgetStateProperty.resolveWith((states) {
      final active = states.contains(WidgetState.selected);
      return IconThemeData(
        color: active ? KColors.primary : KColors.onSurfaceVariant,
        size: 24,
      );
    }),
  ),

  // ── Cards ──
  cardTheme: CardThemeData(
    color: KColors.glassCardColor,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
      side: BorderSide(color: KColors.glassBorderColor, width: 1),
    ),
  ),

  // ── Elevated Button ──
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: WidgetStateProperty.all(KColors.primary),
      foregroundColor: WidgetStateProperty.all(Colors.white),
      elevation: WidgetStateProperty.all(0),
      overlayColor: WidgetStateProperty.all(Colors.white.withValues(alpha: 0.1)),
      padding: WidgetStateProperty.all(
        const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      ),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      textStyle: WidgetStateProperty.all(
        GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 0.5),
      ),
    ),
  ),

  // ── Text Button ──
  textButtonTheme: TextButtonThemeData(
    style: ButtonStyle(
      foregroundColor: WidgetStateProperty.all(KColors.primary),
      textStyle: WidgetStateProperty.all(
        GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    ),
  ),

  // ── Input Fields ──
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: KColors.surfaceContainerLow,
    hintStyle: GoogleFonts.inter(
      fontSize: 14,
      color: KColors.onSurfaceVariant.withValues(alpha: 0.5),
    ),
    labelStyle: GoogleFonts.inter(fontSize: 14, color: KColors.onSurfaceVariant),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: KColors.outlineVariant, width: 1),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: KColors.outlineVariant, width: 1),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: KColors.primary, width: 1.5),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  ),

  // ── Switches ──
  switchTheme: SwitchThemeData(
    thumbColor: WidgetStateProperty.resolveWith((states) =>
        states.contains(WidgetState.selected) ? Colors.white : KColors.outlineVariant),
    trackColor: WidgetStateProperty.resolveWith((states) =>
        states.contains(WidgetState.selected) ? KColors.primary : KColors.surfaceContainerHigh),
    trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
  ),

  // ── Sliders ──
  sliderTheme: SliderThemeData(
    activeTrackColor: KColors.primary,
    inactiveTrackColor: KColors.surfaceContainerHigh,
    thumbColor: KColors.primary,
    overlayColor: KColors.primary.withValues(alpha: 0.15),
    trackHeight: 4,
  ),

  // ── Dividers ──
  dividerTheme: DividerThemeData(
    color: Colors.white.withValues(alpha: 0.06),
    thickness: 1,
    space: 1,
  ),

  // ── Progress Indicator ──
  progressIndicatorTheme: const ProgressIndicatorThemeData(
    color: KColors.primary,
    linearTrackColor: KColors.surfaceContainerHigh,
  ),

  // ── Dialog ──
  dialogTheme: DialogThemeData(
    backgroundColor: KColors.surfaceContainerLow,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    titleTextStyle: GoogleFonts.inter(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: KColors.onSurface,
    ),
    contentTextStyle: GoogleFonts.inter(
      fontSize: 14,
      color: KColors.onSurfaceVariant,
    ),
  ),

  // ── Snack Bar ──
  snackBarTheme: SnackBarThemeData(
    backgroundColor: KColors.surfaceContainerHigh,
    contentTextStyle: GoogleFonts.inter(fontSize: 14, color: KColors.onSurface),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    behavior: SnackBarBehavior.floating,
  ),

  // ── Text Theme (base) ──
  textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
);

// ── LIGHT MODE ───────────────────────────────────────────────────────────────

final ThemeData lightmode = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  scaffoldBackgroundColor: KColors.lightBackground,

  colorScheme: ColorScheme(
    brightness: Brightness.light,
    primary: KColors.primary,
    onPrimary: Colors.white,
    primaryContainer: const Color(0xFFEDE9FF),
    onPrimaryContainer: const Color(0xFF3B0090),
    secondary: KColors.secondary,
    onSecondary: Colors.white,
    secondaryContainer: const Color(0xFFE0E0FF),
    onSecondaryContainer: const Color(0xFF09006A),
    tertiary: const Color(0xFF6D3BD7),
    onTertiary: Colors.white,
    tertiaryContainer: const Color(0xFFEADDFF),
    onTertiaryContainer: const Color(0xFF22005D),
    error: const Color(0xFFBA1A1A),
    onError: Colors.white,
    errorContainer: const Color(0xFFFFDAD6),
    onErrorContainer: const Color(0xFF410002),
    surface: KColors.lightSurface,
    onSurface: KColors.lightOnSurface,
    onSurfaceVariant: KColors.lightOnSurfaceVariant,
    outline: KColors.lightOutline,
    outlineVariant: KColors.lightOutlineVariant,
    shadow: Colors.black,
    inverseSurface: KColors.lightOnSurface,
    onInverseSurface: Colors.white,
    inversePrimary: KColors.primaryDim,
    surfaceTint: KColors.primary,
  ),

  // ── App Bar ──
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.transparent,
    elevation: 0,
    systemOverlayStyle: SystemUiOverlayStyle.dark,
    titleTextStyle: GoogleFonts.inter(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: KColors.lightOnSurface,
    ),
    iconTheme: const IconThemeData(color: KColors.lightOnSurface),
  ),

  // ── Navigation Bar ──
  navigationBarTheme: NavigationBarThemeData(
    backgroundColor: Colors.white.withValues(alpha: 0.95),
    elevation: 0,
    indicatorColor: KColors.primary.withValues(alpha: 0.12),
    labelTextStyle: WidgetStateProperty.resolveWith((states) {
      final active = states.contains(WidgetState.selected);
      return GoogleFonts.inter(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
        color: active ? KColors.primary : KColors.lightOnSurfaceVariant,
      );
    }),
    iconTheme: WidgetStateProperty.resolveWith((states) {
      final active = states.contains(WidgetState.selected);
      return IconThemeData(
        color: active ? KColors.primary : KColors.lightOnSurfaceVariant,
        size: 24,
      );
    }),
  ),

  // ── Cards ──
  cardTheme: CardThemeData(
    color: KColors.lightSurface,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
      side: BorderSide(color: KColors.lightCardBorderColor, width: 1),
    ),
    shadowColor: KColors.lightCardShadowColor,
  ),

  // ── Elevated Button ──
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: WidgetStateProperty.all(KColors.primary),
      foregroundColor: WidgetStateProperty.all(Colors.white),
      elevation: WidgetStateProperty.all(0),
      overlayColor: WidgetStateProperty.all(Colors.white.withValues(alpha: 0.1)),
      padding: WidgetStateProperty.all(
        const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      ),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      textStyle: WidgetStateProperty.all(
        GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 0.5),
      ),
    ),
  ),

  // ── Text Button ──
  textButtonTheme: TextButtonThemeData(
    style: ButtonStyle(
      foregroundColor: WidgetStateProperty.all(KColors.primary),
      textStyle: WidgetStateProperty.all(
        GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    ),
  ),

  // ── Input Fields ──
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: KColors.lightSurfaceContainer,
    hintStyle: GoogleFonts.inter(
      fontSize: 14,
      color: KColors.lightOnSurfaceVariant.withValues(alpha: 0.5),
    ),
    labelStyle: GoogleFonts.inter(fontSize: 14, color: KColors.lightOnSurfaceVariant),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: KColors.lightOutlineVariant, width: 1),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: KColors.lightOutlineVariant, width: 1),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: KColors.primary, width: 1.5),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  ),

  // ── Switches ──
  switchTheme: SwitchThemeData(
    thumbColor: WidgetStateProperty.resolveWith((states) =>
        states.contains(WidgetState.selected) ? Colors.white : const Color(0xFFD0C8E0)),
    trackColor: WidgetStateProperty.resolveWith((states) =>
        states.contains(WidgetState.selected) ? KColors.primary : const Color(0xFFE0DCF0)),
    trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
  ),

  // ── Sliders ──
  sliderTheme: SliderThemeData(
    activeTrackColor: KColors.primary,
    inactiveTrackColor: KColors.lightSurfaceContainerHigh,
    thumbColor: KColors.primary,
    overlayColor: KColors.primary.withValues(alpha: 0.12),
    trackHeight: 4,
  ),

  // ── Dividers ──
  dividerTheme: DividerThemeData(
    color: KColors.lightOutlineVariant.withValues(alpha: 0.5),
    thickness: 1,
    space: 1,
  ),

  // ── Progress Indicator ──
  progressIndicatorTheme: const ProgressIndicatorThemeData(
    color: KColors.primary,
    linearTrackColor: Color(0xFFE8E2FF),
  ),

  // ── Dialog ──
  dialogTheme: DialogThemeData(
    backgroundColor: KColors.lightSurface,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    titleTextStyle: GoogleFonts.inter(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: KColors.lightOnSurface,
    ),
    contentTextStyle: GoogleFonts.inter(
      fontSize: 14,
      color: KColors.lightOnSurfaceVariant,
    ),
  ),

  // ── Snack Bar ──
  snackBarTheme: SnackBarThemeData(
    backgroundColor: KColors.lightOnSurface,
    contentTextStyle: GoogleFonts.inter(fontSize: 14, color: Colors.white),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    behavior: SnackBarBehavior.floating,
  ),

  // ── Text Theme (base) ──
  textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme),
);
