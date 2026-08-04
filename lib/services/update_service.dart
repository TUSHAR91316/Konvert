import 'dart:io';
import 'package:converter_app/constants/api_constants.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:converter_app/theme/app_colors.dart';
import 'package:converter_app/theme/app_text_styles.dart';

class UpdateService {
  final Dio _dio;
  final String _githubLatestReleaseUrl = ApiConstants.githubReleasesUrl;

  UpdateService({Dio? dio}) : _dio = dio ?? Dio();

  Future<void> checkForUpdate(BuildContext context) async {
    try {
      final response = await _dio.get(_githubLatestReleaseUrl);
      if (response.statusCode == 200) {
        final String latestVersionTag = response.data['tag_name'] ?? '';
        final String releaseUrl = response.data['html_url'] ?? '';
        final String releaseNotes =
            response.data['body'] ?? 'Minor bug fixes and performance improvements.';

        // Look for direct APK asset in release assets list
        String? apkDownloadUrl;
        final List<dynamic>? assets = response.data['assets'] as List<dynamic>?;
        if (assets != null) {
          for (final asset in assets) {
            final String name = (asset['name'] ?? '').toString().toLowerCase();
            final String downloadUrl = (asset['browser_download_url'] ?? '').toString();
            if (name.endsWith('.apk') && downloadUrl.isNotEmpty) {
              apkDownloadUrl = downloadUrl;
              break;
            }
          }
        }

        if (latestVersionTag.isNotEmpty && releaseUrl.isNotEmpty) {
          // Clean tag string: 'v1.7.0' -> '1.7.0'
          final latestVersion =
              latestVersionTag.replaceAll(RegExp(r'[vV]'), '').trim();

          final PackageInfo packageInfo = await PackageInfo.fromPlatform();
          final String currentVersion = packageInfo.version;

          if (isUpdateAvailable(currentVersion, latestVersion)) {
            if (context.mounted) {
              _showUpdateDialog(
                context,
                latestVersion,
                releaseNotes,
                releaseUrl,
                apkDownloadUrl,
              );
            }
          }
        }
      }
    } catch (e) {
      debugPrint("Update Check Failed: $e");
    }
  }

  @visibleForTesting
  bool isUpdateAvailable(String current, String latest) {
    try {
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
    BuildContext context,
    String newVersion,
    String releaseNotes,
    String webUrl,
    String? apkDownloadUrl,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return _InAppUpdateDialog(
          newVersion: newVersion,
          releaseNotes: releaseNotes,
          webUrl: webUrl,
          apkDownloadUrl: apkDownloadUrl,
        );
      },
    );
  }
}

class _InAppUpdateDialog extends StatefulWidget {
  final String newVersion;
  final String releaseNotes;
  final String webUrl;
  final String? apkDownloadUrl;

  const _InAppUpdateDialog({
    required this.newVersion,
    required this.releaseNotes,
    required this.webUrl,
    this.apkDownloadUrl,
  });

  @override
  State<_InAppUpdateDialog> createState() => _InAppUpdateDialogState();
}

class _InAppUpdateDialogState extends State<_InAppUpdateDialog> {
  bool _isDownloading = false;
  double _downloadProgress = 0.0;
  String? _statusText;
  bool _downloadFailed = false;

  Future<void> _startInAppDownload() async {
    if (widget.apkDownloadUrl == null || widget.apkDownloadUrl!.isEmpty) {
      _fallbackToWeb();
      return;
    }

    setState(() {
      _isDownloading = true;
      _downloadProgress = 0.0;
      _statusText = 'Downloading update... 0%';
      _downloadFailed = false;
    });

    try {
      Directory tempDir;
      if (Platform.isAndroid) {
        tempDir = (await getExternalStorageDirectory()) ?? (await getTemporaryDirectory());
      } else {
        tempDir = await getTemporaryDirectory();
      }

      final savePath = '${tempDir.path}/Konvert_v${widget.newVersion}.apk';
      final apkFile = File(savePath);
      if (apkFile.existsSync()) apkFile.deleteSync();

      await Dio().download(
        widget.apkDownloadUrl!,
        savePath,
        onReceiveProgress: (received, total) {
          if (total > 0 && mounted) {
            final progress = received / total;
            setState(() {
              _downloadProgress = progress;
              _statusText = 'Downloading... ${(progress * 100).toInt()}%';
            });
          }
        },
      );

      if (mounted) {
        setState(() {
          _isDownloading = false;
          _statusText = 'Download complete! Opening installer...';
        });
      }

      // Trigger native package installer prompt via open_file
      final result = await OpenFile.open(savePath);
      if (result.type != ResultType.done && mounted) {
        setState(() {
          _statusText = 'Installer prompt opened.';
        });
      }
    } catch (e) {
      debugPrint('In-app update download error: $e');
      if (mounted) {
        setState(() {
          _isDownloading = false;
          _downloadFailed = true;
          _statusText = 'Download failed. Tap to open in browser.';
        });
      }
    }
  }

  Future<void> _fallbackToWeb() async {
    final Uri uri = Uri.parse(widget.webUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

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
              'Version ${widget.newVersion} is now live!',
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
                widget.releaseNotes,
                style: context.kBodySM.copyWith(
                  color: context.textSecondary,
                ),
              ),
            ),
            if (_isDownloading) ...[
              const SizedBox(height: 16),
              LinearProgressIndicator(
                value: _downloadProgress > 0 ? _downloadProgress : null,
                backgroundColor: KColors.outline.withValues(alpha: 0.2),
                color: KColors.primary,
                minHeight: 6,
              ),
            ],
            if (_statusText != null) ...[
              const SizedBox(height: 8),
              Text(
                _statusText!,
                style: context.kLabelSM.copyWith(
                  color: _downloadFailed ? KColors.error : KColors.primary,
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        if (!_isDownloading)
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
          onTap: _isDownloading
              ? null
              : (_downloadFailed ? _fallbackToWeb : _startInAppDownload),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: KDecorations.gradientButton(radius: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_isDownloading)
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                else
                  const Icon(Icons.download_rounded, color: Colors.white, size: 16),
                const SizedBox(width: 6),
                Text(
                  _isDownloading
                      ? 'Downloading...'
                      : (_downloadFailed ? 'Open Web' : 'Install Update'),
                  style: KTextStyles.button(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
