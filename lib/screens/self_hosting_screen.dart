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
        debugPrint('Could not launch $url');
      }
    } catch (e) {
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error opening URL: $e")),
        );
      }
      debugPrint('Error launching URL: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Self-Hosted Backend"),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Container(
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade700, Colors.blue.shade500],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Self-Hosted Backend Deployment",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    "Deploy Konvert backend on your infrastructure for complete data privacy. Process documents locally without relying on third-party servers.",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                      height: 1.6,
                    ),
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
            const SizedBox(height: 20),

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
            const SizedBox(height: 20),

            // Step 3: Expose with Tunnel
            _buildStep(
              context: context,
              number: "3",
              title: "Expose Backend via Tunnel",
              description:
                  "Use a tunneling service to expose your local backend globally. Choose from ngrok, Cloudflare Tunnel, or similar providers.",
              codeBlock: '''# ngrok (with static domain)
ngrok http --domain=your-domain.ngrok-free.app 8080

# Cloudflare Tunnel
cloudflare tunnel run --url http://localhost:8080 my-tunnel''',
            ),
            const SizedBox(height: 20),

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
            _buildSectionHeader("Key Capabilities"),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCapability(
                    "Data Privacy",
                    "All files remain on your infrastructure. No data sent to external services.",
                  ),
                  _buildCapability(
                    "Complete Control",
                    "Manage server resources, security policies, and access logs independently.",
                  ),
                  _buildCapability(
                    "Zero Hosting Costs",
                    "Leverage existing hardware and infrastructure. Minimal bandwidth requirements.",
                  ),
                  _buildCapability(
                    "Offline Operation",
                    "Function entirely within your network without external dependencies.",
                    isLast: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Supported Formats
            _buildSectionHeader("Supported Document Formats"),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFormatGroup("Documents", ["DOC", "DOCX", "TXT", "RTF", "ODT", "HTML"]),
                  const SizedBox(height: 12),
                  _buildFormatGroup("Spreadsheets", ["XLS", "XLSX"]),
                  const SizedBox(height: 12),
                  _buildFormatGroup("Presentations", ["PPT", "PPTX"]),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      "All formats convert to PDF",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.orange,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Resources
            _buildSectionHeader("Resources & Documentation"),
            const SizedBox(height: 16),
            _buildResourceLink(
              "GitHub Backend Repository",
              "https://github.com/TUSHAR91316/Konvert-Website/tree/main/backend",
              context,
            ),
            const SizedBox(height: 8),
            _buildResourceLink(
              "ngrok Documentation",
              "https://ngrok.com/docs",
              context,
            ),
            const SizedBox(height: 8),
            _buildResourceLink(
              "Cloudflare Tunnel Guide",
              "https://developers.cloudflare.com/cloudflare-one/connections/connect-applications/",
              context,
            ),
            const SizedBox(height: 8),
            _buildResourceLink(
              "Konvert Official Website",
              "https://konvert-website.vercel.app/",
              context,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
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
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    number,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            description,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black54,
              height: 1.6,
            ),
          ),
          if (codeBlock != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade900,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                codeBlock,
                style: const TextStyle(
                  color: Colors.green,
                  fontSize: 11,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ],
          if (highlightText != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.blue.shade300),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, size: 18, color: Colors.blue.shade700),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      highlightText,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (buttonLabel != null && onPressed != null) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onPressed,
                icon: const Icon(Icons.link),
                label: Text(buttonLabel),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCapability(String title, String description, {bool isLast = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text(
                  "✓",
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (!isLast) const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildFormatGroup(String category, List<String> formats) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Text(
            category,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: Colors.black87,
            ),
          ),
        ),
        Expanded(
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: formats
                .map(
                  (format) => Chip(
                    label: Text(format),
                    backgroundColor: Colors.orange.shade200,
                    labelStyle: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildResourceLink(String label, String url, BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  url,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.open_in_new),
            iconSize: 18,
            color: Colors.blue,
            onPressed: () => _launchURL(url, context),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}
