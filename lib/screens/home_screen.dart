import 'package:converter_app/screens/compress_image_screen.dart';
import 'package:converter_app/screens/convert_screen.dart';
import 'package:converter_app/screens/history_screen.dart';
import 'package:converter_app/screens/settings_screen.dart';
import 'package:converter_app/screens/signin_screen.dart';
import 'package:converter_app/services/config_service.dart';
import 'package:converter_app/services/history_service.dart';
import 'package:converter_app/services/update_service.dart';
import 'package:converter_app/theme/app_colors.dart';
import 'package:converter_app/theme/app_text_styles.dart';
import 'package:converter_app/theme/responsive.dart';
import 'package:converter_app/widgets/konvert_bottom_nav.dart';
import 'package:converter_app/widgets/konvert_top_bar.dart';
import 'package:converter_app/constants/api_constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:converter_app/main.dart';
import 'package:dio/dio.dart';

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
    // Defer the update dialog until after the widget is fully mounted
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) UpdateService().checkForUpdate(context);
    });
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
                  onPressed: () async {
                    final newMode = themeNotifier.value == ThemeMode.light
                        ? ThemeMode.dark
                        : ThemeMode.light;
                    themeNotifier.value = newMode;
                    // Persist so the choice survives a cold restart
                    const storage = FlutterSecureStorage();
                    await storage.write(
                      key: 'theme_mode',
                      value: newMode == ThemeMode.dark ? 'dark' : 'light',
                    );
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
  bool _isBackendOnline = false;
  bool _checkingStatus = true;
  int _historyCount = 0;

  @override
  void initState() {
    super.initState();
    _loadRecent();
    _checkSystemStatus();
  }

  Future<void> _checkSystemStatus() async {
    setState(() => _checkingStatus = true);
    try {
      final backendUrl = await ConfigService().getBackendUrl();
      debugPrint('Checking backend status at: $backendUrl/health');
      final response = await Dio().get('$backendUrl/health').timeout(ApiConstants.healthCheckTimeout);
      debugPrint('Backend response: ${response.statusCode}');
      if (mounted) {
        setState(() {
          _isBackendOnline = response.statusCode == 200;
          _checkingStatus = false;
        });
      }
    } catch (e) {
      debugPrint('System status check failed: $e');
      if (mounted) {
        setState(() {
          _isBackendOnline = false;
          _checkingStatus = false;
        });
      }
    }
  }

  Future<void> _loadRecent() async {
    final all = await HistoryService().getHistory();
    if (mounted) {
      setState(() {
        _recentHistory = all.take(3).toList();
        _historyCount = all.length;
      });
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  /// Shows a bottom sheet with live server health details and a refresh button.
  void _showTelemetrySheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _TelemetrySheet(
        isOnline: _isBackendOnline,
        isChecking: _checkingStatus,
        onRefresh: () {
          Navigator.pop(context);
          _checkSystemStatus();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final name = user?.displayName?.split(' ').first;
    final greetingText = name != null ? '${_getGreeting()}, $name' : _getGreeting();

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
              greetingText,
              style: context.kHeadlineXL,
            ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2, curve: Curves.easeOut),
            const SizedBox(height: 4),
            Text(
              'What would you like to convert today?',
              style: context.kBodySM,
            ).animate().fadeIn(delay: 100.ms, duration: 400.ms),
            const SizedBox(height: 16),

            // ── System Status & Stats Row ──
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _showTelemetrySheet(context),
                    child: Container(
                      padding: EdgeInsets.all(context.kSpacingMD),
                      decoration: context.bentoCard,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('SYSTEM STATUS', style: context.kLabelCaps.copyWith(fontSize: 10)),
                              _checkingStatus
                                  ? const SizedBox(
                                      width: 8,
                                      height: 8,
                                      child: CircularProgressIndicator(strokeWidth: 1.5),
                                    )
                                  : Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: _isBackendOnline ? KColors.success : KColors.error,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: (_isBackendOnline ? KColors.success : KColors.error)
                                                .withValues(alpha: 0.4),
                                            blurRadius: 4,
                                            spreadRadius: 1,
                                          )
                                        ],
                                      ),
                                    ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _checkingStatus ? 'Checking...' : (_isBackendOnline ? 'Online' : 'Offline'),
                            style: context.kHeadlineSM,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _isBackendOnline ? 'Tap for details' : 'Tap to retry',
                            style: context.kLabelSM.copyWith(fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(context.kSpacingMD),
                    decoration: context.bentoCard,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('MY LIBRARY', style: context.kLabelCaps.copyWith(fontSize: 10)),
                            Icon(Icons.folder_outlined, color: KColors.primary, size: 14),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$_historyCount Files',
                          style: context.kHeadlineSM,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Total conversions done',
                          style: context.kLabelSM.copyWith(fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ).animate().fadeIn(delay: 120.ms),
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
            const SizedBox(height: 12),

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



class _ToolsTab extends StatelessWidget {
  const _ToolsTab();

  void _navigate(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: context.kPagePaddingTop(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Toolbox',
            style: context.kHeadlineXL,
          ).animate().fadeIn(duration: 400.ms),
          const SizedBox(height: 4),
          Text(
            'Select a specialized tool to start converting',
            style: context.kBodySM,
          ).animate().fadeIn(delay: 100.ms),
          const SizedBox(height: 24),

          // ── Image Tools ──
          Text(
            'IMAGE TOOLS',
            style: context.kLabelCaps,
          ).animate().fadeIn(delay: 150.ms),
          const SizedBox(height: 12),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: context.isWideScreen ? 3 : 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: context.toolCardRatio,
            children: [
              _ToolCard(
                title: 'Images → PDF',
                subtitle: 'JPG, PNG, WEBP, HEIC',
                icon: Icons.image_outlined,
                delay: 200,
                onTap: () => _navigate(context,
                    ConvertScreen(initialFormat: 'pdf', allowedExtensions: ['jpg', 'jpeg', 'png', 'webp', 'heic'])),
              ),
              _ToolCard(
                title: 'Compress Image',
                subtitle: 'JPG, PNG — Quality/Size',
                icon: Icons.compress_outlined,
                delay: 240,
                onTap: () => _navigate(context, const CompressImageScreen()),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ── Document Tools ──
          Text(
            'DOCUMENT TOOLS',
            style: context.kLabelCaps,
          ).animate().fadeIn(delay: 300.ms),
          const SizedBox(height: 12),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: context.isWideScreen ? 3 : 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: context.toolCardRatio,
            children: [
              _ToolCard(
                title: 'Word → PDF',
                subtitle: 'DOC, DOCX',
                icon: Icons.description_outlined,
                delay: 350,
                onTap: () => _navigate(context,
                    ConvertScreen(initialFormat: 'pdf', allowedExtensions: ['doc', 'docx'])),
              ),
              _ToolCard(
                title: 'Excel → PDF',
                subtitle: 'XLS, XLSX',
                icon: Icons.table_chart_outlined,
                delay: 390,
                onTap: () => _navigate(context,
                    ConvertScreen(initialFormat: 'pdf', allowedExtensions: ['xls', 'xlsx'])),
              ),
              _ToolCard(
                title: 'PPT → PDF',
                subtitle: 'PPT, PPTX',
                icon: Icons.slideshow_outlined,
                delay: 430,
                onTap: () => _navigate(context,
                    ConvertScreen(initialFormat: 'pdf', allowedExtensions: ['ppt', 'pptx'])),
              ),
              _ToolCard(
                title: 'Docs → PDF',
                subtitle: 'TXT, RTF, HTML, ODT',
                icon: Icons.article_outlined,
                delay: 470,
                onTap: () => _navigate(context,
                    ConvertScreen(initialFormat: 'pdf', allowedExtensions: ['txt', 'rtf', 'html', 'odt'])),
              ),
            ],
          ),
          const SizedBox(height: 48), // Padding bottom for floating navigation
        ],
      ),
    );
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(context.kSpacingMD),
        decoration: context.bentoCard,
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
        padding: EdgeInsets.all(context.kSpacingMD),
        decoration: context.bentoCard,
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
      margin: EdgeInsets.only(bottom: context.kSpacingSM),
      padding: EdgeInsets.symmetric(horizontal: context.kSpacingMD, vertical: context.kSpacingMD),
      decoration: context.bentoCard,
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
    return Container(
      padding: EdgeInsets.all(context.kSpacingMD),
      decoration: context.bentoCard,
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

// ─── Telemetry Bottom Sheet ───────────────────────────────────────────────────

class _TelemetrySheet extends StatefulWidget {
  final bool isOnline;
  final bool isChecking;
  final VoidCallback onRefresh;

  const _TelemetrySheet({
    required this.isOnline,
    required this.isChecking,
    required this.onRefresh,
  });

  @override
  State<_TelemetrySheet> createState() => _TelemetrySheetState();
}

class _TelemetrySheetState extends State<_TelemetrySheet> {
  bool _loadingDetails = false;
  double? _cpuPercent;
  int? _memUsedMb;
  int? _memTotalMb;
  int? _diskFreeGb;
  int? _latencyMs;
  String? _detailError;

  @override
  void initState() {
    super.initState();
    if (widget.isOnline) _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    if (!mounted) return;
    setState(() {
      _loadingDetails = true;
      _detailError = null;
    });
    try {
      final backendUrl = await ConfigService().getBackendUrl();
      final start = DateTime.now();
      final response = await Dio().get(
        '$backendUrl/health/details',
        options: Options(sendTimeout: ApiConstants.healthCheckTimeout, receiveTimeout: ApiConstants.healthCheckTimeout),
      );
      final latency = DateTime.now().difference(start).inMilliseconds;
      if (mounted && response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        setState(() {
          _latencyMs = latency;
          _cpuPercent = (data['cpu_percent'] as num?)?.toDouble();
          _memUsedMb = (data['memory_used_mb'] as num?)?.toInt();
          _memTotalMb = (data['memory_total_mb'] as num?)?.toInt();
          _diskFreeGb = (data['disk_free_gb'] as num?)?.toInt();
          _loadingDetails = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() { _loadingDetails = false; _detailError = 'Could not load metrics'; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final memPercent = (_memUsedMb != null && _memTotalMb != null && _memTotalMb! > 0)
        ? _memUsedMb! / _memTotalMb!
        : null;

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? KColors.outline : KColors.lightOutline,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: KColors.primaryGradientVertical,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.monitor_heart_outlined, color: Colors.white, size: 18),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Server Status', style: context.kHeadlineSM),
                    Text('Self-Hosted Backend', style: context.kLabelSM.copyWith(fontSize: 10)),
                  ],
                ),
                const Spacer(),
                // Latency badge
                if (_latencyMs != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: KColors.success.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: KColors.success.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      '${_latencyMs}ms',
                      style: context.kLabelSM.copyWith(color: KColors.success, fontWeight: FontWeight.w700, fontSize: 11),
                    ),
                  )
                else
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: widget.isChecking
                          ? KColors.onSurfaceVariant
                          : (widget.isOnline ? KColors.success : KColors.error),
                      shape: BoxShape.circle,
                      boxShadow: widget.isChecking
                          ? []
                          : [
                              BoxShadow(
                                color: (widget.isOnline ? KColors.success : KColors.error).withValues(alpha: 0.4),
                                blurRadius: 6,
                                spreadRadius: 2,
                              )
                            ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            Divider(
              color: isDark ? KColors.outline.withValues(alpha: 0.5) : KColors.lightOutline.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),

            // ── Connection & Mode rows ──
            _TelemetryRow(
              icon: Icons.cloud_outlined,
              label: 'Connection',
              value: widget.isChecking ? 'Checking...' : (widget.isOnline ? 'Online' : 'Offline'),
              valueColor: widget.isChecking ? null : (widget.isOnline ? KColors.success : KColors.error),
            ),
            const SizedBox(height: 12),
            _TelemetryRow(
              icon: Icons.swap_horiz_rounded,
              label: 'Mode',
              value: widget.isOnline ? 'Remote (Docker)' : 'Local Fallback',
            ),
            const SizedBox(height: 12),
            _TelemetryRow(
              icon: Icons.shield_outlined,
              label: 'Images',
              value: '100% Offline · No upload',
              valueColor: KColors.success,
            ),

            // ── Live Telemetry Metrics (only when online) ──
            if (widget.isOnline) ...[
              const SizedBox(height: 16),
              Divider(
                color: isDark ? KColors.outline.withValues(alpha: 0.5) : KColors.lightOutline.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 14),
              if (_loadingDetails)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                  ),
                )
              else if (_detailError != null)
                Center(child: Text(_detailError!, style: context.kLabelSM.copyWith(color: KColors.error)))
              else ...[
                // CPU
                if (_cpuPercent != null) ...[
                  _TelemetryRow(
                    icon: Icons.memory_rounded,
                    label: 'CPU',
                    value: '${_cpuPercent!.toStringAsFixed(1)}%',
                    valueColor: _cpuPercent! > 80 ? KColors.error : (_cpuPercent! > 50 ? Colors.orange : KColors.success),
                    progress: _cpuPercent! / 100,
                  ),
                  const SizedBox(height: 10),
                ],
                // RAM
                if (memPercent != null) ...[
                  _TelemetryRow(
                    icon: Icons.storage_rounded,
                    label: 'RAM',
                    value: '$_memUsedMb / $_memTotalMb MB',
                    valueColor: memPercent > 0.85 ? KColors.error : (memPercent > 0.65 ? Colors.orange : KColors.success),
                    progress: memPercent,
                  ),
                  const SizedBox(height: 10),
                ],
                // Disk
                if (_diskFreeGb != null)
                  _TelemetryRow(
                    icon: Icons.disc_full_outlined,
                    label: 'Disk Free',
                    value: '$_diskFreeGb GB',
                    valueColor: _diskFreeGb! < 2 ? KColors.error : KColors.success,
                  ),
              ],
            ],

            const SizedBox(height: 20),

            // ── Info box ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: KColors.primary.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: KColors.primary.withValues(alpha: 0.15)),
              ),
              child: Text(
                widget.isOnline
                    ? 'Your backend is reachable. Complex documents (DOCX, XLSX, PPTX) will be converted via your self-hosted Docker server.'
                    : 'Backend is offline. Image → PDF conversions still work 100% locally. Start your Docker container and tap Reconnect.',
                style: context.kBodySM.copyWith(height: 1.5),
              ),
            ),
            const SizedBox(height: 20),

            // ── Reconnect / Refresh button ──
            GestureDetector(
              onTap: onRefresh,
              child: Container(
                height: 46,
                width: double.infinity,
                decoration: KDecorations.gradientButton(radius: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.refresh_rounded, color: Colors.white, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      widget.isOnline ? 'REFRESH STATUS' : 'RECONNECT',
                      style: KTextStyles.button(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void onRefresh() => widget.onRefresh();
}

class _TelemetryRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;
  final double? progress; // 0.0–1.0, shows a progress bar when not null

  const _TelemetryRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
    this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: KColors.onSurfaceVariant),
            const SizedBox(width: 10),
            Text(label, style: context.kBodySM),
            const Spacer(),
            Text(
              value,
              style: context.kBodySM.copyWith(
                fontWeight: FontWeight.w600,
                color: valueColor,
              ),
            ),
          ],
        ),
        if (progress != null) ...[
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress!.clamp(0.0, 1.0),
              minHeight: 4,
              backgroundColor: KColors.outline.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation<Color>(
                valueColor ?? KColors.primary,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

