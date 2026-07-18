import 'package:converter_app/main.dart';
import 'package:converter_app/screens/signin_screen.dart';
import 'package:converter_app/services/auth_service.dart';
import 'package:converter_app/services/config_service.dart';
import 'package:converter_app/services/virus_total_service.dart';
import 'package:converter_app/theme/app_colors.dart';
import 'package:converter_app/theme/app_text_styles.dart';
import 'package:converter_app/theme/responsive.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // ── Controllers ──
  final _apiKeyController = TextEditingController();
  final _backendUrlController = TextEditingController();

  // ── Services ──
  final _vtService = VirusTotalService();
  final _configService = ConfigService();

  bool _isLoading = true;
  bool _autoScanEnabled = false;
  String _appVersion = '1.6.3';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  /// ✅ MEMORY LEAK FIX: Both TextEditingControllers are now disposed.
  /// Previously this screen had NO dispose() method at all — both controllers
  /// were leaking every time Settings was opened.
  Future<void> _updateAccentColor(Color color) async {
    const storage = FlutterSecureStorage();
    await storage.write(key: 'accent_color', value: color.toARGB32().toString());
    KColors.primary = color;
    accentColorNotifier.value = color;
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    _backendUrlController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final key = await _vtService.getApiKey();
    if (key != null) _apiKeyController.text = key;

    final url = await _configService.getBackendUrl();
    _backendUrlController.text = url;

    _autoScanEnabled = await _vtService.getAutoScanEnabled();

    try {
      final info = await PackageInfo.fromPlatform();
      _appVersion = info.version;
    } catch (_) {
      _appVersion = '1.6.3';
    }

    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _saveBackendUrl() async {
    await _configService.setBackendUrl(_backendUrlController.text);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Backend URL saved!')),
      );
    }
  }

  Future<void> _saveApiKey() async {
    await _vtService.setApiKey(_apiKeyController.text);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('API key saved!')),
      );
    }
  }

  Future<void> _signOut() async {
    await AuthService().signOut();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const SignInScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(
        title: Text('Settings', style: context.kHeadlineMD),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: KColors.primary))
          : SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(20, 8, 20, context.kBottomPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Account ──
                  _BentoCard(
                    label: 'ACCOUNT',
                    icon: Icons.person_outline,
                    child: user == null
                        ? _GuestAccountTile(context: context)
                        : _LoggedInAccountTile(
                            user: user,
                            onSignOut: _signOut,
                          ),
                  ),
                  const SizedBox(height: 12),

                  // ── Appearance ──
                  _BentoCard(
                    label: 'APPEARANCE',
                    icon: Icons.palette_outlined,
                    child: Column(
                      children: [
                        _SettingRow(
                          icon: isDark
                              ? Icons.dark_mode_outlined
                              : Icons.light_mode_outlined,
                          label: isDark ? 'Dark Mode' : 'Light Mode',
                          trailing: ValueListenableBuilder<ThemeMode>(
                            valueListenable: themeNotifier,
                            builder: (_, mode, ctx) => Switch(
                              value: mode == ThemeMode.dark,
                              onChanged: (val) {
                                themeNotifier.value =
                                    val ? ThemeMode.dark : ThemeMode.light;
                              },
                            ),
                          ),
                        ),
                        Divider(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.06)
                              : KColors.lightOutlineVariant.withValues(alpha: 0.5),
                          height: 1,
                        ),
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text('Accent Color', style: context.kBodySM),
                        ),
                        const SizedBox(height: 10),
                         ValueListenableBuilder<Color>(
                          valueListenable: accentColorNotifier,
                          builder: (context, activeColor, _) {
                            return Row(
                              children: [
                                _AccentSwatch(
                                  color: const Color(0xFF4F46E5), // Indigo
                                  isActive: activeColor.toARGB32() == 0xFF4F46E5,
                                  onTap: () => _updateAccentColor(const Color(0xFF4F46E5)),
                                ),
                                const SizedBox(width: 12),
                                _AccentSwatch(
                                  color: const Color(0xFF60A5FA), // Blue
                                  isActive: activeColor.toARGB32() == 0xFF60A5FA,
                                  onTap: () => _updateAccentColor(const Color(0xFF60A5FA)),
                                ),
                                const SizedBox(width: 12),
                                _AccentSwatch(
                                  color: const Color(0xFF34D399), // Emerald
                                  isActive: activeColor.toARGB32() == 0xFF34D399,
                                  onTap: () => _updateAccentColor(const Color(0xFF34D399)),
                                ),
                                const SizedBox(width: 12),
                                _AccentSwatch(
                                  color: const Color(0xFFF87171), // Red
                                  isActive: activeColor.toARGB32() == 0xFFF87171,
                                  onTap: () => _updateAccentColor(const Color(0xFFF87171)),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ── Backend ──
                  _BentoCard(
                    label: 'BACKEND',
                    icon: Icons.cloud_outlined,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Connect to your self-hosted FastAPI backend. Use ngrok, Cloudflare Tunnel, or any tunneling service.',
                          style: context.kBodySM,
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          controller: _backendUrlController,
                          decoration: const InputDecoration(
                            labelText: 'Backend URL',
                            hintText: 'https://abc123.ngrok-free.app',
                            prefixIcon: Icon(Icons.link_outlined),
                          ),
                        ),
                        const SizedBox(height: 10),
                        _GradientButton(
                          label: 'SAVE URL',
                          icon: Icons.save_outlined,
                          onTap: _saveBackendUrl,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ── VirusTotal ──
                  _BentoCard(
                    label: 'SECURITY',
                    icon: Icons.security_outlined,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Enter your VirusTotal API key to enable automatic file scanning before conversion.',
                          style: context.kBodySM,
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          controller: _apiKeyController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: 'VirusTotal API Key',
                            prefixIcon: Icon(Icons.vpn_key_outlined),
                          ),
                        ),
                        const SizedBox(height: 10),
                        _GradientButton(
                          label: 'SAVE KEY',
                          icon: Icons.save_outlined,
                          onTap: _saveApiKey,
                        ),
                        const SizedBox(height: 12),
                        _SettingRow(
                          icon: Icons.radar_outlined,
                          label: 'Auto-Scan Files',
                          subtitle: 'Scan before every conversion',
                          trailing: Switch(
                            value: _autoScanEnabled,
                            onChanged: (val) {
                              if (val && _apiKeyController.text.trim().isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Please save an API Key first!'),
                                  ),
                                );
                                return;
                              }
                              setState(() => _autoScanEnabled = val);
                              _vtService.setAutoScanEnabled(val);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ── About ──
                  _BentoCard(
                    label: 'ABOUT',
                    icon: Icons.info_outline,
                    child: Column(
                      children: [
                        _AboutRow(label: 'Version', value: _appVersion),
                        Divider(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.06)
                              : KColors.lightOutlineVariant.withValues(alpha: 0.5),
                          height: 20,
                        ),
                        _AboutRow(label: 'Platform', value: 'Android'),
                        Divider(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.06)
                              : KColors.lightOutlineVariant.withValues(alpha: 0.5),
                          height: 20,
                        ),
                        _AboutRow(label: 'Engine', value: 'Hybrid (Local + Docker)'),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: KColors.primary.withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: KColors.primary.withValues(alpha: 0.15),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "What's New in v$_appVersion",
                                style: KTextStyles.bodySM(color: KColors.primary)
                                    .copyWith(fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 8),
                              ...const [
                                '• Precision Slate UI — new premium dark/light design system',
                                '• 4-tab bottom navigation (Dashboard, Library, Tools, Settings)',
                                '• Date-grouped conversion Library',
                                '• Memory leak fix in Settings controllers',
                              ].map((s) => Padding(
                                    padding: const EdgeInsets.only(bottom: 4),
                                    child: Text(s,
                                        style: KTextStyles.bodySM(
                                            color: KColors.onSurfaceVariant)),
                                  )),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

// ─── Reusable Settings Widgets ────────────────────────────────────────────────

class _BentoCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final Widget child;

  const _BentoCard({
    required this.label,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: context.bentoCard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: KColors.primary, size: 16),
              const SizedBox(width: 8),
              Text(label, style: context.kLabelCaps),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _SettingRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final Widget trailing;

  const _SettingRow({
    required this.icon,
    required this.label,
    required this.trailing,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    return Row(
      children: [
        Icon(icon,
            size: 20,
            color: isDark ? KColors.onSurfaceVariant : KColors.lightOnSurfaceVariant),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: context.kBodyLG),
              if (subtitle != null)
                Text(subtitle!, style: context.kBodySM),
            ],
          ),
        ),
        trailing,
      ],
    );
  }
}

class _AboutRow extends StatelessWidget {
  final String label;
  final String value;

  const _AboutRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: context.kBodyLG),
        Text(value, style: context.kBodySM),
      ],
    );
  }
}

class _AccentSwatch extends StatelessWidget {
  final Color color;
  final bool isActive;
  final VoidCallback onTap;

  const _AccentSwatch({
    required this.color,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: isActive
              ? Border.all(color: Colors.white, width: 2.5)
              : null,
          boxShadow: isActive
              ? [BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 8)]
              : null,
        ),
      ),
    );
  }
}

class _GradientButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _GradientButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 46,
        decoration: KDecorations.gradientButton(radius: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 16),
            const SizedBox(width: 8),
            Text(label, style: KTextStyles.button()),
          ],
        ),
      ),
    );
  }
}

class _LoggedInAccountTile extends StatelessWidget {
  final User user;
  final VoidCallback onSignOut;

  const _LoggedInAccountTile({required this.user, required this.onSignOut});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final initials = _initials(user.displayName ?? '');
    return Row(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: user.photoURL == null ? KColors.primaryGradient : null,
            border: Border.all(color: KColors.primary.withValues(alpha: 0.3), width: 1.5),
          ),
          child: ClipOval(
            child: user.photoURL != null
                ? Image.network(user.photoURL!, fit: BoxFit.cover,
                    errorBuilder: (_, err, st) => Center(
                          child: Text(initials,
                              style: KTextStyles.headlineSM(color: Colors.white)),
                        ))
                : Center(
                    child:
                        Text(initials, style: KTextStyles.headlineSM(color: Colors.white))),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(user.displayName ?? 'Konvert User', style: context.kHeadlineSM),
              Text(user.email ?? '', style: context.kBodySM,
                  maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
        GestureDetector(
          onTap: onSignOut,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: isDark
                ? KDecorations.ghostButtonDark(radius: 8)
                : KDecorations.ghostButtonLight(radius: 8),
            child: Text('Logout', style: KTextStyles.button(color: KColors.primary).copyWith(fontSize: 13)),
          ),
        ),
      ],
    );
  }

  String _initials(String name) {
    if (name.isEmpty) return 'K';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name[0].toUpperCase();
  }
}

class _GuestAccountTile extends StatelessWidget {
  final BuildContext context;
  const _GuestAccountTile({required this.context});

  @override
  Widget build(BuildContext ctx) {
    return Row(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: KColors.primary.withValues(alpha: 0.10),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.person_outline, color: KColors.primary, size: 26),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Guest User', style: ctx.kHeadlineSM),
              Text('Sign in to sync your history.', style: ctx.kBodySM),
            ],
          ),
        ),
        GestureDetector(
          onTap: () => Navigator.push(
            ctx,
            MaterialPageRoute(builder: (_) => const SignInScreen()),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: KDecorations.gradientButton(radius: 8),
            child: Text('Sign In', style: KTextStyles.button().copyWith(fontSize: 13)),
          ),
        ),
      ],
    );
  }
}
