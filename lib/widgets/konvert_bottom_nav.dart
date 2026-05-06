import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Glass-morphic bottom navigation bar.
/// Active tab: violet icon + violet dot indicator.
/// Inactive: muted slate icon.
class KonvertBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const KonvertBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const _items = [
    _NavItem(icon: Icons.dashboard_outlined, activeIcon: Icons.dashboard, label: 'Dashboard'),
    _NavItem(icon: Icons.folder_outlined, activeIcon: Icons.folder, label: 'Library'),
    _NavItem(icon: Icons.construction_outlined, activeIcon: Icons.construction, label: 'Tools'),
    _NavItem(icon: Icons.settings_outlined, activeIcon: Icons.settings, label: 'Settings'),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF020617).withValues(alpha: 0.80)
            : Colors.white.withValues(alpha: 0.95),
        border: Border(
          top: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : KColors.lightOutlineVariant.withValues(alpha: 0.4),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: List.generate(_items.length, (index) {
              final item = _items[index];
              final isActive = currentIndex == index;

              return Expanded(
                child: GestureDetector(
                  onTap: () => onTap(index),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOut,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // ── Icon ──
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: Icon(
                            isActive ? item.activeIcon : item.icon,
                            key: ValueKey(isActive),
                            color: isActive
                                ? KColors.primary
                                : (isDark
                                    ? KColors.onSurfaceVariant.withValues(alpha: 0.6)
                                    : KColors.lightOnSurfaceVariant),
                            size: 24,
                          ),
                        ),
                        const SizedBox(height: 3),
                        // ── Label ──
                        Text(
                          item.label.toUpperCase(),
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                            color: isActive
                                ? KColors.primary
                                : (isDark
                                    ? KColors.onSurfaceVariant.withValues(alpha: 0.6)
                                    : KColors.lightOnSurfaceVariant),
                          ),
                        ),
                        const SizedBox(height: 2),
                        // ── Active dot ──
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeOut,
                          width: isActive ? 4 : 0,
                          height: isActive ? 4 : 0,
                          decoration: BoxDecoration(
                            color: KColors.primary,
                            shape: BoxShape.circle,
                            boxShadow: isActive
                                ? [
                                    BoxShadow(
                                      color: KColors.primary.withValues(alpha: 0.5),
                                      blurRadius: 6,
                                      spreadRadius: 1,
                                    ),
                                  ]
                                : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}
