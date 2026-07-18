import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:converter_app/theme/app_colors.dart';
import 'package:converter_app/theme/app_text_styles.dart';

class UpdateService {
  final Dio _dio;
  final String _githubLatestReleaseUrl =
      'https://api.github.com/repos/TUSHAR91316/Konvert-Website/releases/latest';

  UpdateService({Dio? dio}) : _dio = dio ?? Dio();

  Future<void> checkForUpdate(BuildContext context) async {
    try {
      final response = await _dio.get(_githubLatestReleaseUrl);
      if (response.statusCode == 200) {
        final String latestVersionTag = response.data['tag_name'] ?? '';
        final String releaseUrl = response.data['html_url'] ?? '';
        final String releaseNotes = response.data['body'] ?? 'Minor bug fixes and performance improvements.';

        if (latestVersionTag.isNotEmpty && releaseUrl.isNotEmpty) {
          // Clean the tag string, e.g., 'v1.6.2' or 'V1.6.2' -> '1.6.2'
          final latestVersion = latestVersionTag.replaceAll(RegExp(r'[vV]'), '').trim();

          final PackageInfo packageInfo = await PackageInfo.fromPlatform();
          final String currentVersion = packageInfo.version;

          if (isUpdateAvailable(currentVersion, latestVersion)) {
            if (context.mounted) {
              _showUpdateDialog(context, latestVersion, releaseNotes, releaseUrl);
            }
          }
        }
      }
    } catch (e) {
      // Fail silently for background checks so it doesn't disturb the UX
      debugPrint("Update Check Failed: $e");
    }
  }

  @visibleForTesting
  bool isUpdateAvailable(String current, String latest) {
    try {
      // Stripping out build numbers if present (e.g. 1.6.1+6 -> 1.6.1)
      current = current.split('+').first;
      latest = latest.split('+').first;

      List<int> currParts = current.split('.').map(int.parse).toList();
      List<int> latestParts = latest.split('.').map(int.parse).toList();

      for (int i = 0; i < 3; i++) {
        int cur = currParts.length > i ? currParts[i] : 0;
        int lat = latestParts.length > i ? latestParts[i] : 0;
        if (lat > cur) return true;
        if (cur > lat) return false;
      }
    } catch (e) {
      return false;
    }
    return false;
  }

  void _showUpdateDialog(
      BuildContext context, String newVersion, String releaseNotes, String url) {
    final isDark = context.isDark;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: context.cardBg,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: isDark ? KColors.outline : KColors.lightOutline,
              width: 1,
            ),
          ),
          title: Row(
            children: [
              Icon(Icons.system_update_rounded, color: KColors.primary, size: 24),
              const SizedBox(width: 10),
              Text(
                'Update Available!',
                style: context.kHeadlineSM,
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Version $newVersion is now out! You are on an older version.',
                  style: context.kBodySM.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 16),
                Text('What\'s new:', style: context.kLabelSM),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: context.sectionBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    releaseNotes,
                    style: context.kBodySM.copyWith(
                      color: context.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Later',
                style: KTextStyles.bodySM(
                  color: isDark ? KColors.onSurfaceVariant : KColors.lightOnSurfaceVariant,
                ).copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () async {
                final Uri uri = Uri.parse(url);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: KDecorations.gradientButton(radius: 10),
                child: Text(
                  'Download Update',
                  style: KTextStyles.button(),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
