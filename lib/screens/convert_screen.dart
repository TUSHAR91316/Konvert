import 'dart:io';
import 'package:converter_app/services/conversion_service.dart';
import 'package:converter_app/services/history_service.dart';
import 'package:converter_app/services/virus_total_service.dart';
import 'package:converter_app/theme/app_colors.dart';
import 'package:converter_app/theme/app_text_styles.dart';
import 'package:converter_app/theme/responsive.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ConvertScreen extends StatefulWidget {
  final String initialFormat;
  final List<String>? allowedExtensions;

  const ConvertScreen({
    super.key,
    this.initialFormat = 'pdf',
    this.allowedExtensions,
  });

  @override
  State<ConvertScreen> createState() => _ConvertScreenState();
}

class _ConvertScreenState extends State<ConvertScreen> {
  List<File> _selectedFiles = [];
  bool _isConverting = false;
  String? _statusMessage;
  bool _isSuccess = false;
  late String _targetFormat;
  String? _outputDirectory;

  // Page settings
  String _pageSize = 'A4';
  String _orientation = 'Portrait';
  bool _maximizeQuality = true;

  final _conversionService = ConversionService();

  @override
  void initState() {
    super.initState();
    _targetFormat = widget.initialFormat;
    if (Platform.isAndroid) {
      _outputDirectory = '/storage/emulated/0/Download';
    }
  }

  // No disposables in this screen — no leak

  Future<void> _selectOutputDirectory() async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
    if (selectedDirectory != null) {
      setState(() {
        _outputDirectory = selectedDirectory;
      });
    }
  }

  Future<void> _pickFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: widget.allowedExtensions != null ? FileType.custom : FileType.any,
      allowedExtensions: widget.allowedExtensions,
    );
    if (result != null) {
      setState(() {
        _selectedFiles = result.paths.map((p) => File(p!)).toList();
        _statusMessage = null;
        _isSuccess = false;
      });
    }
  }

  Future<void> _processConversion() async {
    if (_selectedFiles.isEmpty) return;
    setState(() {
      _isConverting = true;
      _isSuccess = false;
      _statusMessage = 'Starting...';
    });

    try {
      bool autoScan = await VirusTotalService().getAutoScanEnabled();
      String? apiKey = await VirusTotalService().getApiKey();

      if (autoScan && apiKey != null && apiKey.isNotEmpty) {
        setState(() => _statusMessage = 'Scanning with VirusTotal...');
        for (var file in _selectedFiles) {
          try {
            String? analysisId = await VirusTotalService().scanFile(file);
            if (analysisId == null) throw Exception('Scan failed for ${file.path}');
          } catch (e) {
            final msg = e.toString().replaceFirst('Exception: ', '');
            throw Exception('VirusTotal Blocked: $msg');
          }
        }
        setState(() => _statusMessage = 'Scan complete. Processing...');
      }

      late File resultFile;
      String ext = _selectedFiles.first.path.split('.').last.toLowerCase();

      if (['jpg', 'jpeg', 'png', 'webp', 'heic'].contains(ext)) {
        if (_targetFormat != 'pdf') throw Exception('Local conversion only supports PDF output.');
        
        bool backendSuccess = false;
        if (_selectedFiles.length == 1) {
          try {
            setState(() => _statusMessage = 'Converting via backend...');
            resultFile = await _conversionService.convertRemote(
              _selectedFiles.first,
              _targetFormat,
              outputDirPath: _outputDirectory,
            );
            backendSuccess = true;
          } catch (e) {
            debugPrint("Backend image conversion failed: $e. Falling back to local...");
          }
        }
        
        if (!backendSuccess) {
          setState(() => _statusMessage = 'Processing locally...');
          resultFile = await _conversionService.imagesToPdf(
            _selectedFiles,
            outputDirPath: _outputDirectory,
          );
        }
      } else if (ext == 'pdf' && _selectedFiles.length > 1) {
        throw 'Multiple PDFs merging is not supported yet.';
      } else if (['docx', 'doc', 'ppt', 'pptx', 'xls', 'xlsx', 'txt', 'rtf', 'html', 'odt']
          .contains(ext)) {
        setState(() => _statusMessage = 'Converting via backend...');
        resultFile = await _conversionService.convertRemote(
          _selectedFiles.first,
          _targetFormat,
          outputDirPath: _outputDirectory,
        );
      } else {
        throw Exception('Unsupported format: $ext');
      }

      int sizeBytes = await resultFile.length();
      double sizeMb = sizeBytes / (1024 * 1024);
      String sizeStr = sizeMb >= 1
          ? '${sizeMb.toStringAsFixed(2)} MB'
          : '${(sizeBytes / 1024).toStringAsFixed(0)} KB';

      await HistoryService().addEntry(
        originalName: _selectedFiles.first.path.split('/').last,
        targetFormat: _targetFormat,
        resultPath: resultFile.path,
      );

      setState(() {
        _statusMessage = 'Saved ($sizeStr) · ${resultFile.path.split('/').last}';
        _isConverting = false;
        _isSuccess = true;
      });
    } on ConversionException catch (e) {
      setState(() {
        _statusMessage = 'Conversion failed';
        _isConverting = false;
        _isSuccess = false;
      });
      _showErrorDialog(e.code, e.message, e.resolution);
    } catch (e) {
      setState(() {
        _statusMessage = e.toString().replaceFirst('Exception: ', '');
        _isConverting = false;
        _isSuccess = false;
      });
    }
  }

  void _showErrorDialog(String code, String message, String resolution) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.isDark ? KColors.surfaceContainerLow : KColors.lightSurfaceContainer,
        title: Text(code, style: context.kHeadlineSM.copyWith(color: KColors.error)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message, style: context.kBodySM),
            const SizedBox(height: 16),
            Text("RESOLUTION", style: context.kLabelCaps.copyWith(color: KColors.primary)),
            const SizedBox(height: 4),
            Text(resolution, style: context.kBodySM),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('DISMISS', style: context.kLabelCaps.copyWith(color: KColors.primary)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(
        title: Text('Convert File', style: context.kHeadlineMD),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20, 8, 20, context.kBottomPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Upload Zone ──
              GestureDetector(
                onTap: _pickFiles,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: context.uploadZoneHeight,
                  decoration: BoxDecoration(
                    color: context.sectionBg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _selectedFiles.isEmpty
                          ? KColors.primary.withValues(alpha: 0.40)
                          : KColors.primary,
                      width: 1.5,
                      style: BorderStyle.solid,
                    ),
                    boxShadow: _selectedFiles.isNotEmpty
                        ? [
                            BoxShadow(
                              color: KColors.primary.withValues(alpha: 0.12),
                              blurRadius: 20,
                              spreadRadius: 0,
                            )
                          ]
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: KColors.primary.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.upload_file_outlined,
                          color: KColors.primary,
                          size: 26,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _selectedFiles.isEmpty
                            ? 'Tap to Select Files'
                            : '${_selectedFiles.length} file(s) selected',
                        style: context.kHeadlineSM.copyWith(color: KColors.primary),
                      ),
                      const SizedBox(height: 4),
                      if (widget.allowedExtensions != null)
                        Text(
                          widget.allowedExtensions!.join(', ').toUpperCase(),
                          style: context.kLabelSM,
                        ),
                    ],
                  ),
                ),
              ).animate().fadeIn().scale(begin: const Offset(0.97, 0.97)),

              // ── File List ──
              if (_selectedFiles.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text('UPLOADED FILES', style: context.kLabelCaps),
                const SizedBox(height: 8),
                SizedBox(
                  height: 90,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _selectedFiles.length,
                    separatorBuilder: (context, index) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final name = _selectedFiles[index].path.split('/').last;
                      return Container(
                        width: 110,
                        decoration: context.bentoCard,
                        child: Stack(
                          children: [
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.all(8),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.insert_drive_file_outlined,
                                        color: KColors.primary, size: 28),
                                    const SizedBox(height: 4),
                                    Text(
                                      name,
                                      style: context.kLabelSM,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                              top: 4,
                              right: 4,
                              child: GestureDetector(
                                onTap: () => setState(() => _selectedFiles.removeAt(index)),
                                child: Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: KColors.error.withValues(alpha: 0.15),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(Icons.close, size: 12, color: KColors.error),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],

              // ── Document Setup ──
              const SizedBox(height: 20),
              _BentoSection(
                label: 'DOCUMENT SETUP',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Page Size', style: context.kBodySM),
                    const SizedBox(height: 8),
                    _SegmentedToggle(
                      options: const ['A4', 'Letter'],
                      selected: _pageSize,
                      onChanged: (v) => setState(() => _pageSize = v),
                    ),
                    const SizedBox(height: 16),
                    Text('Orientation', style: context.kBodySM),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _OrientationButton(
                            icon: Icons.stay_current_portrait_outlined,
                            label: 'Portrait',
                            isSelected: _orientation == 'Portrait',
                            onTap: () => setState(() => _orientation = 'Portrait'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _OrientationButton(
                            icon: Icons.stay_current_landscape_outlined,
                            label: 'Landscape',
                            isSelected: _orientation == 'Landscape',
                            onTap: () => setState(() => _orientation = 'Landscape'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 200.ms),

              const SizedBox(height: 12),

              // ── Quality Toggle ──
              _BentoSection(
                label: 'OUTPUT QUALITY',
                child: Row(
                  children: [
                    Icon(Icons.hd_outlined, color: KColors.primary, size: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Maximize Quality', style: context.kHeadlineSM.copyWith(fontSize: 14)),
                          Text('Optimized rendering', style: context.kBodySM),
                        ],
                      ),
                    ),
                    Switch(
                      value: _maximizeQuality,
                      onChanged: (v) => setState(() => _maximizeQuality = v),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 280.ms),

              const SizedBox(height: 12),

              // ── Save Location ──
              _BentoSection(
                label: 'SAVE LOCATION',
                child: GestureDetector(
                  onTap: _selectOutputDirectory,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: context.kSpacingMD, vertical: context.kSpacingMD),
                    decoration: context.bentoCard,
                    child: Row(
                      children: [
                        Icon(Icons.folder_open_outlined, color: KColors.primary, size: 22),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Output Folder', style: context.kHeadlineSM.copyWith(fontSize: 14)),
                              Text(_outputDirectory ?? 'Default Application Directory',
                                  style: context.kBodySM,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis),
                            ],
                          ),
                        ),
                        Icon(Icons.chevron_right, color: KColors.primary, size: 20),
                      ],
                    ),
                  ),
                ),
              ).animate().fadeIn(delay: 340.ms),

              const SizedBox(height: 24),

              // ── Status Message ──
              if (_statusMessage != null && !_isConverting) ...[
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: (_isSuccess ? KColors.success : KColors.error)
                        .withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: (_isSuccess ? KColors.success : KColors.error)
                          .withValues(alpha: 0.25),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _isSuccess ? Icons.check_circle_outline : Icons.error_outline,
                        color: _isSuccess ? KColors.success : KColors.error,
                        size: 18,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _statusMessage!,
                          style: KTextStyles.bodySM(
                            color: _isSuccess ? KColors.success : KColors.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn().slideY(begin: 0.2),
                const SizedBox(height: 16),
              ],

              // ── Progress ──
              if (_isConverting) ...[
                Container(
                  padding: EdgeInsets.all(context.kSpacingMD),
                  decoration: context.bentoCard,
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          minHeight: 6,
                          backgroundColor: isDark
                              ? KColors.surfaceContainerHigh
                              : KColors.lightSurfaceContainerHigh,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(_statusMessage ?? 'Processing...',
                          style: KTextStyles.bodySM(color: KColors.primary),
                          textAlign: TextAlign.center),
                    ],
                  ),
                ).animate().fadeIn(),
                const SizedBox(height: 16),
              ],

              // ── CTA Button ──
              if (!_isConverting)
                GestureDetector(
                  onTap: _selectedFiles.isEmpty ? null : _processConversion,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: context.kButtonHeight,
                    decoration: _selectedFiles.isEmpty
                        ? BoxDecoration(
                            color: isDark
                                ? KColors.surfaceContainerHigh
                                : KColors.lightSurfaceContainerHigh,
                            borderRadius: BorderRadius.circular(16),
                          )
                        : KDecorations.gradientButton(radius: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.picture_as_pdf_outlined,
                          color: _selectedFiles.isEmpty
                              ? (isDark ? KColors.onSurfaceVariant : KColors.lightOnSurfaceVariant)
                              : Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'CONVERT TO ${_targetFormat.toUpperCase()}',
                          style: KTextStyles.button(
                            color: _selectedFiles.isEmpty
                                ? (isDark
                                    ? KColors.onSurfaceVariant
                                    : KColors.lightOnSurfaceVariant)
                                : Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ).animate(target: _selectedFiles.isNotEmpty ? 1.0 : 0.8).fadeIn().scale(),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Shared sub-widgets ───────────────────────────────────────────────────────

class _BentoSection extends StatelessWidget {
  final String label;
  final Widget child;

  const _BentoSection({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.kSpacingMD),
      decoration: context.bentoCard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: context.kLabelCaps),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _SegmentedToggle extends StatelessWidget {
  final List<String> options;
  final String selected;
  final ValueChanged<String> onChanged;

  const _SegmentedToggle({
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: isDark ? KColors.surfaceContainerHigh : KColors.lightSurfaceContainerHigh,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: options.map((opt) {
          final isSelected = opt == selected;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(opt),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: isSelected
                    ? BoxDecoration(
                        gradient: KColors.primaryGradient,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: KColors.primary.withValues(alpha: 0.25),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      )
                    : BoxDecoration(borderRadius: BorderRadius.circular(8)),
                child: Text(
                  opt,
                  textAlign: TextAlign.center,
                  style: KTextStyles.button(
                    color: isSelected
                        ? Colors.white
                        : (isDark ? KColors.onSurfaceVariant : KColors.lightOnSurfaceVariant),
                  ).copyWith(fontSize: 13),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _OrientationButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _OrientationButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? KColors.primary.withValues(alpha: 0.12)
              : (isDark
                  ? KColors.surfaceContainerHigh
                  : KColors.lightSurfaceContainerHigh),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? KColors.primary
                : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Icon(icon,
                color: isSelected ? KColors.primary : (isDark ? KColors.onSurfaceVariant : KColors.lightOnSurfaceVariant),
                size: 22),
            const SizedBox(height: 4),
            Text(
              label.toUpperCase(),
              style: KTextStyles.labelCaps(
                color: isSelected
                    ? KColors.primary
                    : (isDark ? KColors.onSurfaceVariant : KColors.lightOnSurfaceVariant),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
