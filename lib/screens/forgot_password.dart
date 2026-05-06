import 'package:converter_app/services/auth_service.dart';
import 'package:converter_app/theme/app_colors.dart';
import 'package:converter_app/theme/app_text_styles.dart';
import 'package:converter_app/theme/responsive.dart';
import 'package:flutter/material.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  // ✅ Properly disposed below — no memory leak
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _sent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendReset() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      await AuthService().sendPasswordResetEmail(_emailController.text.trim());
      if (mounted) {
        setState(() {
          _isLoading = false;
          _sent = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(
          color: isDark ? KColors.onSurface : KColors.lightOnSurface,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: context.kPagePaddingTop(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Header ──
              ShaderMask(
                shaderCallback: (b) => KColors.primaryGradient.createShader(b),
                child: Text(
                  'Konvert',
                  style: KTextStyles.logo().copyWith(fontSize: 28, color: Colors.white),
                ),
              ),
              const SizedBox(height: 32),

              _sent ? _SuccessState() : _FormCard(
                isDark: isDark,
                formKey: _formKey,
                emailController: _emailController,
                isLoading: _isLoading,
                onSend: _sendReset,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FormCard extends StatelessWidget {
  final bool isDark;
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final bool isLoading;
  final VoidCallback onSend;

  const _FormCard({
    required this.isDark,
    required this.formKey,
    required this.emailController,
    required this.isLoading,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: isDark
          ? KDecorations.glassCard(radius: 24)
          : KDecorations.lightCard(radius: 24),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Forgot Password', style: context.kHeadlineMD),
            const SizedBox(height: 8),
            Text(
              'Enter your email address and we\'ll send you a link to reset your password.',
              style: context.kBodySM,
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'Enter your email' : null,
              decoration: const InputDecoration(
                labelText: 'Email Address',
                hintText: 'you@example.com',
                prefixIcon: Icon(Icons.mail_outline),
              ),
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: isLoading ? null : onSend,
              child: Container(
                height: context.kButtonHeight,
                decoration: KDecorations.gradientButton(radius: 14),
                child: Center(
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : Text('SEND RESET LINK', style: KTextStyles.button()),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SuccessState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: KColors.success.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.mark_email_read_outlined,
              color: KColors.success, size: 36),
        ),
        const SizedBox(height: 20),
        Text('Check your inbox!', style: context.kHeadlineMD),
        const SizedBox(height: 8),
        Text(
          'A password reset link has been sent to your email address.',
          style: context.kBodySM,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            height: context.kButtonHeight,
            decoration: KDecorations.gradientButton(radius: 14),
            child: Center(
              child: Text('BACK TO SIGN IN', style: KTextStyles.button()),
            ),
          ),
        ),
      ],
    );
  }
}
