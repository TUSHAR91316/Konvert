import 'dart:math' as math;
import 'package:flutter/material.dart';

// ─── Konvert Responsive Utilities ─────────────────────────────────────────────
// Provides breakpoint-aware helpers for all screen sizes:
//   Phone portrait  : 360–420dp wide
//   Phone landscape : 640–900dp wide
//   Tablet          : 600dp+ wide
//   Large tablet    : 840dp+ wide

class KResponsive {
  KResponsive._();

  // ── Breakpoints ──
  static const double _phoneMax = 599;
  static const double _tabletMax = 839;

  static bool isPhone(BuildContext context) =>
      MediaQuery.sizeOf(context).width <= _phoneMax;

  static bool isTablet(BuildContext context) =>
      MediaQuery.sizeOf(context).width > _phoneMax &&
      MediaQuery.sizeOf(context).width <= _tabletMax;

  static bool isLargeTablet(BuildContext context) =>
      MediaQuery.sizeOf(context).width > _tabletMax;

  static bool isWideScreen(BuildContext context) =>
      MediaQuery.sizeOf(context).width > _phoneMax;

  // ── Grid cross-axis count ──
  // Phone → 2 columns, Tablet → 3, Large tablet → 4
  static int gridCount(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    if (w > _tabletMax) return 4;
    if (w > _phoneMax) return 3;
    return 2;
  }

  // ── Featured hero card count ──
  // Phone → 2 (side-by-side), Tablet → 3
  static int heroCount(BuildContext context) =>
      MediaQuery.sizeOf(context).width > _phoneMax ? 3 : 2;

  // ── Upload zone height ──
  // Proportional to screen height, clamped between 130px and 220px
  static double uploadZoneHeight(BuildContext context) {
    final h = MediaQuery.sizeOf(context).height;
    return math.min(220, math.max(130, h * 0.22));
  }

  // ── Bottom scroll padding ──
  // Accounts for the glass bottom nav (≈64dp) + system nav bar inset
  static double bottomPadding(BuildContext context) {
    final systemNavBar = MediaQuery.viewPaddingOf(context).bottom;
    return 64 + systemNavBar + 24; // nav height + system bar + extra gutter
  }

  // ── Safe horizontal page padding ──
  // Scales slightly on wide screens so content doesn't stretch too much
  static EdgeInsets pagePadding(BuildContext context, {double top = 16}) {
    final w = MediaQuery.sizeOf(context).width;
    final hPad = w > _phoneMax ? math.min(w * 0.08, 48.0) : 20.0;
    return EdgeInsets.fromLTRB(hPad, top, hPad, bottomPadding(context));
  }

  // ── Font scale guard ──
  // Returns clamped textScaler (applied in main.dart)
  static TextScaler clampedTextScaler(BuildContext context) {
    return MediaQuery.textScalerOf(context).clamp(
      minScaleFactor: 0.85,
      maxScaleFactor: 1.2,
    );
  }

  // ── Card aspect ratio for tool grid ──
  // Slightly wider on tablets so cards look balanced
  static double toolCardRatio(BuildContext context) =>
      MediaQuery.sizeOf(context).width > _phoneMax ? 1.6 : 1.4;

  // ── Button height ──
  // Slightly taller on large tablets
  static double buttonHeight(BuildContext context) =>
      MediaQuery.sizeOf(context).width > _tabletMax ? 60 : 52;
}

// ─── Extension for ergonomic access ─────────────────────────────────────────

extension KResponsiveContext on BuildContext {
  bool get isPhone => KResponsive.isPhone(this);
  bool get isTablet => KResponsive.isTablet(this);
  bool get isLargeTablet => KResponsive.isLargeTablet(this);
  bool get isWideScreen => KResponsive.isWideScreen(this);

  int get gridCount => KResponsive.gridCount(this);
  double get uploadZoneHeight => KResponsive.uploadZoneHeight(this);
  double get kBottomPadding => KResponsive.bottomPadding(this);
  EdgeInsets get kPagePadding => KResponsive.pagePadding(this);
  double get toolCardRatio => KResponsive.toolCardRatio(this);
  double get kButtonHeight => KResponsive.buttonHeight(this);

  EdgeInsets kPagePaddingTop(double top) =>
      KResponsive.pagePadding(this, top: top);
}
