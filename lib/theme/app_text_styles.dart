import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

// ─── Konvert Obsidian Typography ──────────────────────────────────────────────
// Font: Inter (via google_fonts)
// Source: UI_IDEA/screen/DESIGN.md — Typography section

class KTextStyles {
  KTextStyles._();

  // ── Headline XL — 32px, w700, tracking -0.02em ──
  static TextStyle headlineXL({Color? color}) => GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.64, // -0.02em of 32px
        height: 1.2,
        color: color,
      );

  // ── Headline MD — 20px, w600, tracking -0.01em ──
  static TextStyle headlineMD({Color? color}) => GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.20, // -0.01em of 20px
        height: 1.4,
        color: color,
      );

  // ── Headline SM — 16px, w600 (sub-section headers) ──
  static TextStyle headlineSM({Color? color}) => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.16,
        height: 1.4,
        color: color,
      );

  // ── Body LG — 16px, w400 ──
  static TextStyle bodyLG({Color? color}) => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        height: 1.6,
        color: color,
      );

  // ── Body SM — 14px, w400 ──
  static TextStyle bodySM({Color? color}) => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        height: 1.5,
        color: color,
      );

  // ── Label Caps — 12px, w700, tracking +0.05em, UPPERCASE ──
  static TextStyle labelCaps({Color? color}) => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.60, // +0.05em of 12px
        height: 1.0,
        color: color,
      );

  // ── Label SM — 11px, w500 (minor metadata) ──
  static TextStyle labelSM({Color? color}) => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0,
        height: 1.2,
        color: color,
      );

  // ── Logo — gradient "Konvert" wordmark ──
  static TextStyle logo() => GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.w900,
        letterSpacing: -0.44,
        height: 1.0,
      );

  // ── Button text ──
  static TextStyle button({Color? color}) => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
        height: 1.0,
        color: color ?? Colors.white,
      );
}

// ─── Theme-aware helpers via extension ───────────────────────────────────────

extension KTextTheme on BuildContext {
  bool get _isDark => Theme.of(this).brightness == Brightness.dark;

  TextStyle get kHeadlineXL => KTextStyles.headlineXL(
        color: _isDark ? KColors.onSurface : KColors.lightOnSurface,
      );

  TextStyle get kHeadlineMD => KTextStyles.headlineMD(
        color: _isDark ? KColors.onSurface : KColors.lightOnSurface,
      );

  TextStyle get kHeadlineSM => KTextStyles.headlineSM(
        color: _isDark ? KColors.onSurface : KColors.lightOnSurface,
      );

  TextStyle get kBodyLG => KTextStyles.bodyLG(
        color: _isDark ? KColors.onSurface : KColors.lightOnSurface,
      );

  TextStyle get kBodySM => KTextStyles.bodySM(
        color: _isDark ? KColors.onSurfaceVariant : KColors.lightOnSurfaceVariant,
      );

  TextStyle get kLabelCaps => KTextStyles.labelCaps(
        color: KColors.primary.withValues(alpha: 0.85),
      );

  TextStyle get kLabelSM => KTextStyles.labelSM(
        color: _isDark ? KColors.onSurfaceVariant : KColors.lightOnSurfaceVariant,
      );
}
