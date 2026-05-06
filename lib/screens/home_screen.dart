import 'package:converter_app/screens/compress_image_screen.dart';
import 'package:converter_app/screens/convert_screen.dart';
import 'package:converter_app/screens/history_screen.dart';
import 'package:converter_app/screens/settings_screen.dart';
import 'package:converter_app/screens/signin_screen.dart';
import 'package:converter_app/services/history_service.dart';
import 'package:converter_app/services/update_service.dart';
import 'package:converter_app/theme/app_colors.dart';
import 'package:converter_app/theme/app_text_styles.dart';
import 'package:converter_app/theme/responsive.dart';
import 'package:converter_app/widgets/konvert_bottom_nav.dart';
import 'package:converter_app/widgets/konvert_top_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:converter_app/main.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _requestPermissions();
    UpdateService().checkForUpdate(context);
  }

  Future<void> _requestPermissions() async {
    if (await Permission.manageExternalStorage.isDenied) {
      await Permission.manageExternalStorage.request();
    }
    if (await Permission.storage.isDenied) {
      await Permission.storage.request();
    }
  }

  // IndexedStack keeps all tabs alive (no rebuild on switch)
  static const List<Widget> _tabs = [
    _DashboardTab(),
    HistoryScreen(),
    _ToolsTab(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: context.scaffoldBg,
      extendBody: true,
      appBar: KonvertTopBar(
        displayName: user?.displayName,
        photoUrl: user?.photoURL,
        trailingAction: _currentIndex == 0
            ? ValueListenableBuilder<ThemeMode>(
                valueListenable: themeNotifier,
                builder: (_, mode, ctx) => IconButton(
                  icon: Icon(
                    mode == ThemeMode.dark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                    color: KColors.onSurfaceVariant,
                    size: 20,
                  ),
                  onPressed: () {
                    themeNotifier.value = themeNotifier.value == ThemeMode.light
                        ? ThemeMode.dark
                        : ThemeMode.light;
                  },
                ),
              )
            : null,
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _tabs,
      ),
      bottomNavigationBar: KonvertBottomNav(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}

// ─── Dashboard Tab ────────────────────────────────────────────────────────────

class _DashboardTab extends StatefulWidget {
  const _DashboardTab();

  @override
  State<_DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<_DashboardTab> {
  List<Map<String, dynamic>> _recentHistory = [];

  @override
  void initState() {
    super.initState();
    _loadRecent();
  }

  Future<void> _loadRecent() async {
    final all = await HistoryService().getHistory();
    if (mounted) {
      setState(() {
        _recentHistory = all.take(3).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final name = user?.displayName?.split(' ').first ?? 'there';

    return RefreshIndicator(
      color: KColors.primary,
      onRefresh: _loadRecent,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: context.kPagePaddingTop(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Greeting ──
            Text(
              'Hello, $name 👋',
              style: context.kHeadlineXL,
            ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2, curve: Curves.easeOut),
            const SizedBox(height: 4),
            Text(
              'What do you want to convert today?',
              style: context.kBodySM,
            ).animate().fadeIn(delay: 100.ms, duration: 400.ms),
            const SizedBox(height: 24),

            // ── Featured Tools ──
            Text(
              'FEATURED TOOLS',
              style: context.kLabelCaps,
            ).animate().fadeIn(delay: 150.ms),
            const SizedBox(height: 12),

            // Phone: 2 side-by-side  |  Tablet: 3 side-by-side
            LayoutBuilder(builder: (context, constraints) {
              final count = context.isWideScreen ? 3 : 2;
              final spacing = 12.0;
              final cardWidth =
                  (constraints.maxWidth - spacing * (count - 1)) / count;
              return Row(
                children: [
                  SizedBox(
                    width: cardWidth,
                    child: _FeaturedCard(
                      title: 'Images → PDF',
                      subtitle: '100% Offline',
                      icon: Icons.image_outlined,
                      badgeText: 'OFFLINE',
                      badgeColor: KColors.success,
                      onTap: () => _navigate(context, ConvertScreen(initialFormat: 'pdf', allowedExtensions: ['jpg', 'jpeg', 'png', 'webp', 'heic'])),
                    ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.1),
                  ),
                  SizedBox(width: spacing),
                  SizedBox(
                    width: cardWidth,
                    child: _FeaturedCard(
                      title: 'Compress Image',
                      subtitle: 'Shrink any image fast',
                      icon: Icons.compress_outlined,
                      onTap: () => _navigate(context, const CompressImageScreen()),
                    ).animate().fadeIn(delay: 280.ms).slideX(begin: 0.1),
                  ),
                  if (context.isWideScreen) ...[
                    SizedBox(width: spacing),
                    SizedBox(
                      width: cardWidth,
                      child: _FeaturedCard(
                        title: 'Docs → PDF',
                        subtitle: 'TXT, RTF, HTML, ODT',
                        icon: Icons.article_outlined,
                        onTap: () => _navigate(context, ConvertScreen(initialFormat: 'pdf', allowedExtensions: ['txt', 'rtf', 'html', 'odt'])),
                      ).animate().fadeIn(delay: 350.ms).slideX(begin: 0.1),
                    ),
                  ],
                ],
              );
            }),
            const SizedBox(height: 24),

            // ── All Conversion Tools ──
            Text(
              'ALL CONVERSION TOOLS',
              style: context.kLabelCaps,
            ).animate().fadeIn(delay: 320.ms),
            const SizedBox(height: 12),

            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: context.gridCount,  // 2 phone / 3 tablet / 4 large
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: context.toolCardRatio,
              children: [
                _ToolCard(
                  title: 'Images → PDF',
                  subtitle: 'JPG, PNG, WEBP, HEIC',
                  icon: Icons.image_outlined,
                  delay: 360,
                  onTap: () => _navigate(context,
                      ConvertScreen(initialFormat: 'pdf', allowedExtensions: ['jpg', 'jpeg', 'png', 'webp', 'heic'])),
                ),
                _ToolCard(
                  title: 'Word → PDF',
                  subtitle: 'DOC, DOCX',
                  icon: Icons.description_outlined,
                  delay: 400,
                  onTap: () => _navigate(context,
                      ConvertScreen(initialFormat: 'pdf', allowedExtensions: ['doc', 'docx'])),
                ),
                _ToolCard(
                  title: 'Excel → PDF',
                  subtitle: 'XLS, XLSX',
                  icon: Icons.table_chart_outlined,
                  delay: 440,
                  onTap: () => _navigate(context,
                      ConvertScreen(initialFormat: 'pdf', allowedExtensions: ['xls', 'xlsx'])),
                ),
                _ToolCard(
                  title: 'PPT → PDF',
                  subtitle: 'PPT, PPTX',
                  icon: Icons.slideshow_outlined,
                  delay: 480,
                  onTap: () => _navigate(context,
                      ConvertScreen(initialFormat: 'pdf', allowedExtensions: ['ppt', 'pptx'])),
                ),
                _ToolCard(
                  title: 'Docs → PDF',
                  subtitle: 'TXT, RTF, HTML, ODT',
                  icon: Icons.article_outlined,
                  delay: 520,
                  onTap: () => _navigate(context,
                      ConvertScreen(initialFormat: 'pdf', allowedExtensions: ['txt', 'rtf', 'html', 'odt'])),
                ),
                _ToolCard(
                  title: 'Compress',
                  subtitle: 'JPG, PNG — Quality or Size',
                  icon: Icons.compress_outlined,
                  delay: 560,
                  onTap: () => _navigate(context, const CompressImageScreen()),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ── Recent Conversions ──
            if (_recentHistory.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('RECENT CONVERSIONS', style: context.kLabelCaps),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      'View All →',
                      style: KTextStyles.bodySM(color: KColors.primary),
                    ),
                  ),
                ],
              ).animate().fadeIn(delay: 600.ms),
              const SizedBox(height: 8),
              ...List.generate(_recentHistory.length, (i) {
                final item = _recentHistory[i];
                return _HistoryItem(item: item)
                    .animate()
                    .fadeIn(delay: Duration(milliseconds: 640 + i * 60))
                    .slideY(begin: 0.1);
              }),
            ],

            // ── Guest sign-in nudge ──
            if (FirebaseAuth.instance.currentUser == null) ...[
              const SizedBox(height: 24),
              _SignInNudge().animate().fadeIn(delay: 700.ms),
            ],
          ],
        ),
      ),
    );
  }

  void _navigate(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }
}

// ─── Tools Tab (convert picker) ───────────────────────────────────────────────

class _ToolsTab extends StatelessWidget {
  const _ToolsTab();

  @override
  Widget build(BuildContext context) {
    // Opens Convert screen directly from the Tools tab
    return const ConvertScreen(initialFormat: 'pdf');
  }
}

// ─── Reusable Widgets ─────────────────────────────────────────────────────────

class _FeaturedCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final String? badgeText;
  final Color? badgeColor;
  final VoidCallback onTap;

  const _FeaturedCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    this.badgeText,
    this.badgeColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: isDark
            ? KDecorations.glassCard(
                shadows: [
                  BoxShadow(
                    color: KColors.primary.withValues(alpha: 0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              )
            : KDecorations.lightCard(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: KColors.primaryGradientVertical,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: Colors.white, size: 18),
                ),
                if (badgeText != null) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: (badgeColor ?? KColors.success).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      badgeText!,
                      style: KTextStyles.labelCaps(
                        color: badgeColor ?? KColors.success,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 10),
            Text(title, style: context.kHeadlineSM),
            const SizedBox(height: 2),
            Text(subtitle, style: context.kLabelSM, maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}

class _ToolCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final int delay;
  final VoidCallback onTap;

  const _ToolCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.delay,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: isDark
            ? KDecorations.glassCard()
            : KDecorations.lightCard(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: KColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: KColors.primary, size: 18),
            ),
            const SizedBox(height: 8),
            Text(title,
                style: KTextStyles.bodySM(
                    color: isDark ? KColors.onSurface : KColors.lightOnSurface)
                  ..copyWith(fontWeight: FontWeight.w600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            const SizedBox(height: 2),
            Text(subtitle, style: context.kLabelSM, maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
      ).animate().fadeIn(delay: Duration(milliseconds: delay)).slideY(begin: 0.1),
    );
  }
}

class _HistoryItem extends StatelessWidget {
  final Map<String, dynamic> item;

  const _HistoryItem({required this.item});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final name = item['originalName'] as String? ?? 'Unknown';
    final format = (item['targetFormat'] as String? ?? 'pdf').toUpperCase();

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: isDark
          ? KDecorations.glassCard(radius: 14)
          : KDecorations.lightCard(radius: 14),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: KColors.success.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.check_circle_outline, color: KColors.success, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: context.kBodySM.copyWith(
                    color: isDark ? KColors.onSurface : KColors.lightOnSurface,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text('→ $format', style: context.kLabelSM),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios_rounded,
            size: 12,
            color: isDark ? KColors.onSurfaceVariant : KColors.lightOnSurfaceVariant,
          ),
        ],
      ),
    );
  }
}

class _SignInNudge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            KColors.primary.withValues(alpha: isDark ? 0.15 : 0.08),
            KColors.secondary.withValues(alpha: isDark ? 0.10 : 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: KColors.primary.withValues(alpha: 0.20),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.account_circle_outlined, color: KColors.primary, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Sign in to sync history', style: context.kHeadlineSM.copyWith(fontSize: 14)),
                Text('Your conversions are saved locally.', style: context.kBodySM),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SignInScreen()),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: KDecorations.gradientButton(radius: 10),
              child: Text('Sign In', style: KTextStyles.button()),
            ),
          ),
        ],
      ),
    );
  }
}
