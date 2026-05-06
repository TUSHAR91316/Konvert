import 'package:converter_app/screens/signin_screen.dart';
import 'package:converter_app/screens/signup_screen.dart';
import 'package:converter_app/screens/home_screen.dart';
import 'package:converter_app/theme/app_colors.dart';
import 'package:converter_app/theme/app_text_styles.dart';
import 'package:converter_app/theme/responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:permission_handler/permission_handler.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    await [
      Permission.storage,
      Permission.manageExternalStorage,
    ].request();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    return Scaffold(
      backgroundColor: context.scaffoldBg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // ── Radial glow blob ──
              Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: KColors.primary.withValues(alpha: isDark ? 0.30 : 0.18),
                      blurRadius: 80,
                      spreadRadius: 20,
                    ),
                  ],
                ),
                child: Image.asset(
                  'assets/images/final_logo.png',
                  fit: BoxFit.contain,
                ),
              ).animate().fadeIn(duration: 600.ms).scale(
                    begin: const Offset(0.8, 0.8),
                    curve: Curves.easeOutBack,
                  ),

              const SizedBox(height: 32),

              // ── Logo wordmark ──
              ShaderMask(
                shaderCallback: (b) => KColors.primaryGradient.createShader(b),
                child: Text(
                  'Konvert',
                  style: KTextStyles.headlineXL(color: Colors.white)
                      .copyWith(fontSize: 42, fontWeight: FontWeight.w900),
                ),
              ).animate().fadeIn(delay: 200.ms, duration: 500.ms).slideY(
                    begin: 0.2,
                    curve: Curves.easeOut,
                  ),

              const SizedBox(height: 12),

              Text(
                'Convert, compress & manage your files — all on-device.',
                style: context.kBodyLG,
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 350.ms, duration: 500.ms),

              const SizedBox(height: 8),

              // ── Feature pills ──
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: const [
                  _FeaturePill('🔒 100% Private'),
                  _FeaturePill('⚡ Offline Images'),
                  _FeaturePill('📄 Docs to PDF'),
                  _FeaturePill('🗜️ Compress'),
                ].map((w) => w.animate().fadeIn(delay: 500.ms)).toList(),
              ),

              const Spacer(flex: 3),

              // ── CTA Buttons ──
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SignUpScreen()),
                ),
                child: Container(
                  height: context.kButtonHeight,
                  decoration: KDecorations.gradientButton(radius: 16),
                  child: Center(
                    child: Text('GET STARTED', style: KTextStyles.button()),
                  ),
                ),
              ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2),

              const SizedBox(height: 12),

              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SignInScreen()),
                ),
                child: Container(
                  height: context.kButtonHeight,
                  decoration: isDark
                      ? KDecorations.ghostButtonDark(radius: 16)
                      : KDecorations.ghostButtonLight(radius: 16),
                  child: Center(
                    child: Text(
                      'SIGN IN',
                      style: KTextStyles.button(color: KColors.primary),
                    ),
                  ),
                ),
              ).animate().fadeIn(delay: 680.ms).slideY(begin: 0.2),

              const SizedBox(height: 12),

              GestureDetector(
                onTap: () => Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const HomeScreen()),
                  (route) => false,
                ),
                child: Text(
                  'Continue as Guest',
                  style: context.kBodySM
                      .copyWith(decoration: TextDecoration.underline),
                ),
              ).animate().fadeIn(delay: 750.ms),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeaturePill extends StatelessWidget {
  final String label;
  const _FeaturePill(this.label);

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isDark
            ? KColors.surfaceContainerHigh
            : KColors.lightSurfaceContainerHigh,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : KColors.lightOutlineVariant,
        ),
      ),
      child: Text(label, style: context.kLabelSM),
    );
  }
}
