import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdateService {
  final Dio _dio = Dio();
  final String _githubLatestReleaseUrl =
      'https://api.github.com/repos/TUSHAR91316/Konvert-Website/releases/latest';

  Future<void> checkForUpdate(BuildContext context) async {
    try {
      final response = await _dio.get(_githubLatestReleaseUrl);
      if (response.statusCode == 200) {
        final String latestVersionTag = response.data['tag_name'] ?? '';
        final String releaseUrl = response.data['html_url'] ?? '';
        final String releaseNotes = response.data['body'] ?? 'Minor bug fixes and performance improvements.';

        if (latestVersionTag.isNotEmpty && releaseUrl.isNotEmpty) {
          // Clean the tag string, e.g., 'v1.6.2' -> '1.6.2'
          final latestVersion = latestVersionTag.replaceAll('v', '').trim();

          final PackageInfo packageInfo = await PackageInfo.fromPlatform();
          final String currentVersion = packageInfo.version;

          if (_isUpdateAvailable(currentVersion, latestVersion)) {
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

  bool _isUpdateAvailable(String current, String latest) {
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
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.system_update_rounded, color: Colors.blue, size: 28),
              SizedBox(width: 8),
              Text('Update Available!'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Version $newVersion is now out! You are on an older version.',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                const Text('What\'s new:', style: TextStyle(color: Colors.black54)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    releaseNotes,
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Later', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () async {
                final Uri uri = Uri.parse(url);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
              child: const Text('Download Update', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}
