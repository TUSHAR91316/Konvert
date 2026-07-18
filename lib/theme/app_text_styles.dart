import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

// ─── Konvert 2.0 Professional Typography ───────────────────────────────────────
// Font: Inter (via google_fonts)
// Theme: Clean Minimalist (Lighter weights, balanced tracking)

class KTextStyles {
  KTextStyles._();

  // ── Headline XL — 32px, w700, tracking -0.02em ──
  static TextStyle headlineXL({Color? color}) => GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.64,
        height: 1.2,
        color: color,
      );

  // ── Headline MD — 20px, w600, tracking -0.01em ──
  static TextStyle headlineMD({Color? color}) => GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.20,
        height: 1.4,
        color: color,
      );

  // ── Headline SM — 16px, w600 ──
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

  // ── Body SM — 14px, w400 (Highly readable secondary text) ──
  static TextStyle bodySM({Color? color}) => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.1,
        height: 1.5,
        color: color,
      );

  // ── Label Caps — 12px, w600, tracking +0.03em, UPPERCASE ──
  // Slightly lighter weight and less tracking than before for a cleaner look.
  static TextStyle labelCaps({Color? color}) => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.36, 
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

  // ── Logo — clean wordmark ──
  static TextStyle logo() => GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.44,
        height: 1.0,
      );

  // ── Button text ──
  // 15px, w600: Professional, legible, modern.
  static TextStyle button({Color? color}) => GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
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
        color: _isDark ? KColors.onSurfaceVariant : KColors.lightOnSurfaceVariant,
      );

  TextStyle get kLabelSM => KTextStyles.labelSM(
        color: _isDark ? KColors.onSurfaceVariant : KColors.lightOnSurfaceVariant,
      );
}
