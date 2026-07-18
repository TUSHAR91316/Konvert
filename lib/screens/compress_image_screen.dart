import 'dart:io';
import 'package:converter_app/services/compression_service.dart';
import 'package:converter_app/theme/app_colors.dart';
import 'package:converter_app/theme/app_text_styles.dart';
import 'package:converter_app/theme/responsive.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart' as p;

class CompressImageScreen extends StatefulWidget {
  const CompressImageScreen({super.key});

  @override
  State<CompressImageScreen> createState() => _CompressImageScreenState();
}

class _CompressImageScreenState extends State<CompressImageScreen> {
  final _compressionService = CompressionService();
  // ── MEMORY LEAK: _sizeController is properly disposed ──
  final _sizeController = TextEditingController();

  File? _selectedFile;
  File? _resultFile;
  bool _isCompressing = false;
  String? _statusMessage;
  bool _isSuccess = false;
  String? _outputDirectory;

  int _mode = 0; // 0 = percentage, 1 = target size
  double _quality = 80;
  String _sizeUnit = 'KB';

  @override
  void dispose() {
    // ✅ Properly disposed — no leak
    _sizeController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );
    if (result != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
        _resultFile = null;
        _statusMessage = null;
        _isSuccess = false;
      });
    }
  }

  Future<void> _pickDirectory() async {
    String? dir = await FilePicker.platform.getDirectoryPath();
    if (dir != null) setState(() => _outputDirectory = dir);
  }

  Future<void> _processCompression() async {
    if (_selectedFile == null) return;
    setState(() {
      _isCompressing = true;
      _statusMessage = 'Compressing...';
      _resultFile = null;
      _isSuccess = false;
    });

    try {
      File? compressed;
      if (_mode == 0) {
        compressed = await _compressionService.compressImagePercentage(
            _selectedFile!, _quality.toInt());
      } else {
        final inputVal = double.tryParse(_sizeController.text);
        if (inputVal == null || inputVal <= 0) throw Exception('Invalid size');
        int targetBytes = _sizeUnit == 'MB'
            ? (inputVal * 1024 * 1024).toInt()
            : (inputVal * 1024).toInt();
        compressed = await _compressionService.compressImageToSize(
            _selectedFile!, targetBytes);
      }

      if (compressed == null) throw Exception('Compression failed');

      if (_outputDirectory != null) {
        final fileName = 'compressed_${p.basename(_selectedFile!.path)}';
        final newPath = p.join(_outputDirectory!, fileName);
        _resultFile = await compressed.copy(newPath);
      } else {
        _resultFile = compressed;
      }

      int originalSize = await _selectedFile!.length();
      int newSize = await _resultFile!.length();
      double saved = (originalSize - newSize) / originalSize * 100;
      String sizeStr = _formatSize(newSize);

      setState(() {
        _statusMessage = 'Reduced by ${saved.toStringAsFixed(1)}% → $sizeStr';
        _isCompressing = false;
        _isSuccess = true;
      });
    } catch (e) {
      setState(() {
        _statusMessage = e.toString().replaceFirst('Exception: ', '');
        _isCompressing = false;
        _isSuccess = false;
      });
    }
  }

  String _formatSize(int bytes) {
    double kb = bytes / 1024;
    double mb = kb / 1024;
    return mb >= 1 ? '${mb.toStringAsFixed(2)} MB' : '${kb.toStringAsFixed(0)} KB';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(
        title: Text('Compress Image', style: context.kHeadlineMD),
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
                onTap: _pickFile,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: context.uploadZoneHeight,
                  decoration: BoxDecoration(
                    color: context.sectionBg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _selectedFile == null
                          ? KColors.primary.withValues(alpha: 0.40)
                          : KColors.success,
                      width: 1.5,
                    ),
                    boxShadow: _selectedFile != null
                        ? [
                            BoxShadow(
                              color: KColors.success.withValues(alpha: 0.10),
                              blurRadius: 16,
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
                          color: (_selectedFile != null ? KColors.success : KColors.primary)
                              .withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _selectedFile != null
                              ? Icons.check_circle_outline
                              : Icons.add_photo_alternate_outlined,
                          color: _selectedFile != null ? KColors.success : KColors.primary,
                          size: 26,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _selectedFile != null
                            ? p.basename(_selectedFile!.path)
                            : 'Tap to Pick Image',
                        style: context.kHeadlineSM.copyWith(
                          color: _selectedFile != null ? KColors.success : KColors.primary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                      if (_selectedFile != null) ...[
                        const SizedBox(height: 4),
                        FutureBuilder<int>(
                          future: _selectedFile!.length(),
                          builder: (_, snap) => Text(
                            snap.hasData ? _formatSize(snap.data!) : '...',
                            style: context.kBodySM,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ).animate().fadeIn().scale(begin: const Offset(0.97, 0.97)),

              if (_selectedFile != null) ...[
                const SizedBox(height: 20),

                // ── Mode Selector ──
                Container(
                  padding: EdgeInsets.all(context.kSpacingMD),
                  decoration: context.bentoCard,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('COMPRESSION MODE', style: context.kLabelCaps),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: _ModeButton(
                              label: 'Percentage',
                              icon: Icons.percent_outlined,
                              isSelected: _mode == 0,
                              onTap: () => setState(() => _mode = 0),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _ModeButton(
                              label: 'Target Size',
                              icon: Icons.data_usage_outlined,
                              isSelected: _mode == 1,
                              onTap: () => setState(() => _mode = 1),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // ── Mode-specific Controls ──
                      if (_mode == 0) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Quality', style: context.kBodySM),
                            Text(
                              '${_quality.toInt()}%',
                              style: KTextStyles.headlineSM(color: KColors.primary),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: 4,
                            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
                          ),
                          child: Slider(
                            value: _quality,
                            min: 5,
                            max: 100,
                            divisions: 19,
                            onChanged: (v) => setState(() => _quality = v),
                          ),
                        ),
                      ] else ...[
                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: TextField(
                                controller: _sizeController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Target Size',
                                  hintText: 'e.g. 500',
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              flex: 2,
                              child: DropdownButtonFormField<String>(
                                initialValue: _sizeUnit,
                                items: const [
                                  DropdownMenuItem(value: 'KB', child: Text('KB')),
                                  DropdownMenuItem(value: 'MB', child: Text('MB')),
                                ],
                                onChanged: (v) => setState(() => _sizeUnit = v!),
                                decoration: const InputDecoration(),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ).animate().fadeIn(delay: 150.ms),

                const SizedBox(height: 12),

                // ── Save Location ──
                GestureDetector(
                  onTap: _pickDirectory,
                  child: Container(
                    padding: EdgeInsets.all(context.kSpacingMD),
                    decoration: context.bentoCard,
                    child: Row(
                      children: [
                        Icon(Icons.folder_outlined, color: KColors.primary, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Save Location', style: context.kHeadlineSM.copyWith(fontSize: 13)),
                              Text(
                                _outputDirectory ?? 'Default: Downloads',
                                style: context.kBodySM,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.chevron_right,
                            size: 18,
                            color: isDark ? KColors.onSurfaceVariant : KColors.lightOnSurfaceVariant),
                      ],
                    ),
                  ),
                ).animate().fadeIn(delay: 200.ms),

                const SizedBox(height: 24),

                // ── Progress / CTA ──
                if (_isCompressing) ...[
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
                        Text('Compressing...',
                            style: KTextStyles.bodySM(color: KColors.primary)),
                      ],
                    ),
                  ).animate().fadeIn(),
                ] else ...[
                  GestureDetector(
                    onTap: _processCompression,
                    child: Container(
                      height: context.kButtonHeight,
                      decoration: KDecorations.gradientButton(radius: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.compress, color: Colors.white, size: 20),
                          const SizedBox(width: 10),
                          Text('COMPRESS NOW', style: KTextStyles.button()),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(delay: 250.ms).scale(begin: const Offset(0.97, 0.97)),
                ],

                // ── Status ──
                if (_statusMessage != null && !_isCompressing) ...[
                  const SizedBox(height: 16),
                  Container(
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
                        if (_isSuccess && _resultFile != null)
                          TextButton.icon(
                            onPressed: () => OpenFile.open(_resultFile!.path),
                            icon: const Icon(Icons.open_in_new, size: 14),
                            label: const Text('Open'),
                            style: TextButton.styleFrom(
                              foregroundColor: KColors.success,
                              padding: EdgeInsets.zero,
                            ),
                          ),
                      ],
                    ),
                  ).animate().fadeIn().slideY(begin: 0.2),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ModeButton({
    required this.label,
    required this.icon,
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
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? KColors.primary.withValues(alpha: 0.12)
              : (isDark
                  ? KColors.surfaceContainerHigh
                  : KColors.lightSurfaceContainerHigh),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? KColors.primary : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected
                  ? KColors.primary
                  : (isDark ? KColors.onSurfaceVariant : KColors.lightOnSurfaceVariant),
            ),
            const SizedBox(width: 6),
            Text(
              label,
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
