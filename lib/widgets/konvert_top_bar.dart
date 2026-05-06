import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

/// Shared glass top app bar used across all tabs.
/// Shows the "Konvert" gradient logo on the left and a profile
/// avatar circle (or initials fallback) on the right.
class KonvertTopBar extends StatelessWidget implements PreferredSizeWidget {
  final String? displayName;
  final String? photoUrl;

  /// Optional trailing widget (e.g. a delete icon for History tab)
  final Widget? trailingAction;

  const KonvertTopBar({
    super.key,
    this.displayName,
    this.photoUrl,
    this.trailingAction,
  });

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Make status bar icons match theme
    SystemChrome.setSystemUIOverlayStyle(isDark
        ? SystemUiOverlayStyle.light
        : SystemUiOverlayStyle.dark);

    return ClipRect(
      child: Container(
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF020617).withValues(alpha: 0.60)
              : Colors.white.withValues(alpha: 0.90),
          border: Border(
            bottom: BorderSide(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : KColors.lightOutlineVariant.withValues(alpha: 0.4),
              width: 1,
            ),
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              children: [
                // ── Logo ──
                ShaderMask(
                  shaderCallback: (bounds) =>
                      KColors.primaryGradient.createShader(bounds),
                  child: Text(
                    'Konvert',
                    style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                      color: Colors.white, // shaderMask colors this
                    ),
                  ),
                ),

                const Spacer(),

                // ── Trailing action (optional) ──
                if (trailingAction != null) ...[
                  trailingAction!,
                  const SizedBox(width: 8),
                ],

                // ── Profile avatar ──
                _Avatar(displayName: displayName, photoUrl: photoUrl),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String? displayName;
  final String? photoUrl;

  const _Avatar({this.displayName, this.photoUrl});

  String get _initials {
    if (displayName == null || displayName!.isEmpty) return 'K';
    final parts = displayName!.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return displayName![0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: photoUrl == null ? KColors.primaryGradient : null,
        border: Border.all(
          color: KColors.primary.withValues(alpha: 0.40),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: KColors.primary.withValues(alpha: 0.20),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: ClipOval(
        child: photoUrl != null && photoUrl!.isNotEmpty
            ? Image.network(
                photoUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, err, st) => _initialsWidget(),
              )
            : _initialsWidget(),
      ),
    );
  }

  Widget _initialsWidget() => Center(
        child: Text(
          _initials,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      );
}
