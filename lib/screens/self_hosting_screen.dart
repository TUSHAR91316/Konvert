import 'package:converter_app/theme/app_colors.dart';
import 'package:converter_app/theme/app_text_styles.dart';
import 'package:converter_app/theme/responsive.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SelfHostingScreen extends StatelessWidget {
  const SelfHostingScreen({super.key});

  Future<void> _launchURL(String url, BuildContext? context) async {
    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context != null && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Could not open URL: $url")),
          );
        }
      }
    } catch (e) {
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error opening URL: $e")),
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
        title: Text("Self-Hosted Backend", style: context.kHeadlineMD),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(
          color: isDark ? KColors.onSurface : KColors.lightOnSurface,
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20, 8, 20, context.kBottomPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                gradient: KColors.primaryGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Self-Hosted Backend Deployment",
                    style: KTextStyles.headlineMD(color: Colors.white),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Deploy Konvert backend on your infrastructure for complete data privacy. Process documents locally without relying on third-party servers.",
                    style: KTextStyles.bodySM(color: Colors.white.withValues(alpha: 0.8)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Step 1: Download Backend
            _buildStep(
              context: context,
              number: "1",
              title: "Download Backend Files",
              description:
                  "Clone or download the backend repository from GitHub. The package includes FastAPI framework and LibreOffice integration for document processing.",
              buttonLabel: "View Repository",
              onPressed: () => _launchURL(
                  'https://github.com/TUSHAR91316/Konvert-Website/tree/main/backend', context),
            ),
            const SizedBox(height: 16),

            // Step 2: Setup Docker
            _buildStep(
              context: context,
              number: "2",
              title: "Configure Docker Container",
              description:
                  "Build and run the Docker container on port 8080. Ensure Docker is installed and running on your system.",
              codeBlock: '''docker build -t converter-backend .
docker run -d -p 8080:8080 converter-backend''',
            ),
            const SizedBox(height: 16),

            // Step 3: Expose with Tunnel
            _buildStep(
              context: context,
              number: "3",
              title: "Expose Backend via Tunnel",
              description:
                  "Use a tunneling service to expose your local backend globally. Choose from ngrok, Cloudflare Tunnel, or similar providers.",
              codeBlock: '''# ngrok (with static domain)
ngrok http --url=your-domain.ngrok-free.app 8080

# Cloudflare Tunnel
cloudflare tunnel run --url http://localhost:8080 my-tunnel''',
            ),
            const SizedBox(height: 16),

            // Step 4: Configure App
            _buildStep(
              context: context,
              number: "4",
              title: "Configure Application",
              description:
                  "Enter your tunnel URL in Konvert Settings → Server Configuration. No application rebuild required.",
              highlightText: "Dynamic configuration — settings apply immediately",
            ),
            const SizedBox(height: 32),

            // Key Features
            _buildSectionHeader("Key Capabilities", context),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20.0),
              decoration: context.bentoCard,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCapability(context, "Data Privacy", "All files remain on your infrastructure. No data sent to external services."),
                  _buildCapability(context, "Complete Control", "Manage server resources, security policies, and access logs independently."),
                  _buildCapability(context, "Zero Hosting Costs", "Leverage existing hardware and infrastructure. Minimal bandwidth requirements."),
                  _buildCapability(context, "Offline Operation", "Function entirely within your network without external dependencies.", isLast: true),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Supported Formats
            _buildSectionHeader("Supported Document Formats", context),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20.0),
              decoration: context.bentoCard,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFormatGroup(context, "Documents", ["DOC", "DOCX", "TXT", "RTF", "ODT", "HTML"]),
                  const SizedBox(height: 16),
                  _buildFormatGroup(context, "Spreadsheets", ["XLS", "XLSX"]),
                  const SizedBox(height: 16),
                  _buildFormatGroup(context, "Presentations", ["PPT", "PPTX"]),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: KColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "All formats convert to PDF",
                      style: KTextStyles.labelCaps(color: KColors.primary),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Resources
            _buildSectionHeader("Resources & Documentation", context),
            const SizedBox(height: 16),
            _buildResourceLink("GitHub Backend Repository", "https://github.com/TUSHAR91316/Konvert-Website/tree/main/backend", context),
            const SizedBox(height: 12),
            _buildResourceLink("ngrok Documentation", "https://ngrok.com/docs", context),
            const SizedBox(height: 12),
            _buildResourceLink("Cloudflare Tunnel Guide", "https://developers.cloudflare.com/cloudflare-one/connections/connect-applications/", context),
            const SizedBox(height: 12),
            _buildResourceLink("Konvert Official Website", "https://konvert-website.vercel.app/", context),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, BuildContext context) {
    return Text(title, style: context.kHeadlineMD);
  }

  Widget _buildStep({
    required BuildContext context,
    required String number,
    required String title,
    required String description,
    String? buttonLabel,
    VoidCallback? onPressed,
    String? codeBlock,
    String? highlightText,
  }) {
    final isDark = context.isDark;
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: context.bentoCard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: KColors.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    number,
                    style: KTextStyles.headlineSM(color: KColors.primary),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(title, style: context.kHeadlineSM),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(description, style: context.kBodySM),
          if (codeBlock != null) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? KColors.background : KColors.lightSurfaceContainerHigh,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                codeBlock,
                style: const TextStyle(
                  color: KColors.success,
                  fontSize: 12,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ],
          if (highlightText != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: KColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: KColors.primary.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 20, color: KColors.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      highlightText,
                      style: KTextStyles.bodySM(color: KColors.primary)
                          .copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (buttonLabel != null && onPressed != null) ...[
            const SizedBox(height: 16),
            GestureDetector(
              onTap: onPressed,
              child: Container(
                height: 46,
                decoration: KDecorations.gradientButton(radius: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.link, color: Colors.white, size: 18),
                    const SizedBox(width: 8),
                    Text(buttonLabel, style: KTextStyles.button()),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCapability(BuildContext context, String title, String description, {bool isLast = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 2),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: KColors.success.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(Icons.check, size: 14, color: KColors.success),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: context.kBodyLG),
                  const SizedBox(height: 4),
                  Text(description, style: context.kBodySM),
                ],
              ),
            ),
          ],
        ),
        if (!isLast) const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildFormatGroup(BuildContext context, String category, List<String> formats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(category, style: context.kBodyLG),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: formats.map((format) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: context.isDark ? KColors.surfaceContainerHigh : KColors.lightSurfaceContainerHigh,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(format, style: context.kLabelSM),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildResourceLink(String label, String url, BuildContext context) {
    return GestureDetector(
      onTap: () => _launchURL(url, context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: context.bentoCard,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: KTextStyles.bodySM(color: KColors.primary).copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(
                    url,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.kLabelSM,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Icon(Icons.open_in_new, size: 20, color: KColors.primary),
          ],
        ),
      ),
    );
  }
}
