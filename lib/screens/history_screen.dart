import 'dart:io';
import 'package:flutter/material.dart';
import 'package:converter_app/services/history_service.dart';
import 'package:converter_app/theme/app_colors.dart';
import 'package:converter_app/theme/app_text_styles.dart';
import 'package:converter_app/theme/responsive.dart';
import 'package:open_file/open_file.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _historyService = HistoryService();
  List<Map<String, dynamic>> _history = [];
  bool _isLoading = true;

  // No disposables — no leak risk

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final data = await _historyService.getHistory();
    if (mounted) {
      setState(() {
        _history = data;
        _isLoading = false;
      });
    }
  }

  Future<void> _clearHistory() async {
    await _historyService.clearHistory();
    _loadHistory();
  }

  /// Groups history list by date label: TODAY / YESTERDAY / LAST WEEK / OLDER
  Map<String, List<Map<String, dynamic>>> _groupByDate(
      List<Map<String, dynamic>> items) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final lastWeekStart = today.subtract(const Duration(days: 7));

    final groups = <String, List<Map<String, dynamic>>>{};

    for (final item in items) {
      final date = DateTime.parse(item['timestamp'] as String);
      final dateOnly = DateTime(date.year, date.month, date.day);

      String group;
      if (dateOnly == today) {
        group = 'TODAY';
      } else if (dateOnly == yesterday) {
        group = 'YESTERDAY';
      } else if (dateOnly.isAfter(lastWeekStart)) {
        group = 'LAST WEEK';
      } else {
        group = 'OLDER';
      }
      groups.putIfAbsent(group, () => []).add(item);
    }
    return groups;
  }

  // Color-code by file type
  Color _typeColor(String format) {
    switch (format.toLowerCase()) {
      case 'pdf':
        return KColors.primary;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'webp':
        return KColors.tertiary;
      case 'docx':
      case 'doc':
        return const Color(0xFF60A5FA); // blue
      case 'xlsx':
      case 'xls':
        return KColors.success;
      case 'pptx':
      case 'ppt':
        return const Color(0xFFFB923C); // orange
      default:
        return KColors.onSurfaceVariant;
    }
  }

  IconData _typeIcon(String format) {
    switch (format.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf_outlined;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'webp':
        return Icons.image_outlined;
      case 'docx':
      case 'doc':
        return Icons.description_outlined;
      case 'xlsx':
      case 'xls':
        return Icons.table_chart_outlined;
      case 'pptx':
      case 'ppt':
        return Icons.slideshow_outlined;
      default:
        return Icons.insert_drive_file_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(
        title: Text('Library', style: context.kHeadlineMD),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (_history.isNotEmpty)
            IconButton(
              icon: Icon(
                Icons.delete_sweep_outlined,
                color: isDark ? KColors.onSurfaceVariant : KColors.lightOnSurfaceVariant,
              ),
              tooltip: 'Clear all history',
              onPressed: () => _showClearDialog(context),
            ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(color: KColors.primary),
            )
          : _history.isEmpty
              ? _EmptyState()
              : RefreshIndicator(
                  color: KColors.primary,
                  onRefresh: _loadHistory,
                  child: ListView(
                    padding: EdgeInsets.fromLTRB(20, 8, 20, context.kBottomPadding),
                    children: _buildGroupedList(isDark),
                  ),
                ),
    );
  }

  List<Widget> _buildGroupedList(bool isDark) {
    final grouped = _groupByDate(_history);
    final groupOrder = ['TODAY', 'YESTERDAY', 'LAST WEEK', 'OLDER'];
    final widgets = <Widget>[];

    for (final groupLabel in groupOrder) {
      final items = grouped[groupLabel];
      if (items == null || items.isEmpty) continue;

      // Group header
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 10, top: 16),
          child: Text(groupLabel, style: context.kLabelCaps),
        ),
      );

      // Items
      for (final item in items) {
        final name = item['originalName'] as String? ?? 'Unknown';
        final format = (item['targetFormat'] as String? ?? 'pdf');
        final resultPath = item['resultPath'] as String? ?? '';
        final timestamp = DateTime.parse(item['timestamp'] as String);
        final formattedTime = DateFormat('h:mm a').format(timestamp);
        final exists = resultPath.isNotEmpty && File(resultPath).existsSync();

        final color = _typeColor(format);
        final icon = _typeIcon(format);

        widgets.add(
          GestureDetector(
            onTap: exists ? () => OpenFile.open(resultPath) : null,
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: context.bentoCard,
              child: Row(
                children: [
                  // ── File type icon ──
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: color, size: 20),
                  ),
                  const SizedBox(width: 12),
                  // ── File info ──
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: KTextStyles.bodySM(
                            color: exists
                                ? (isDark ? KColors.onSurface : KColors.lightOnSurface)
                                : (isDark ? KColors.onSurfaceVariant : KColors.lightOnSurfaceVariant),
                          ).copyWith(fontWeight: FontWeight.w500),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${format.toUpperCase()} · $formattedTime',
                          style: context.kLabelSM,
                        ),
                      ],
                    ),
                  ),
                  // ── Trailing ──
                  exists
                      ? Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 12,
                          color: isDark
                              ? KColors.onSurfaceVariant
                              : KColors.lightOnSurfaceVariant,
                        )
                      : Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: KColors.error.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'DELETED',
                            style: KTextStyles.labelCaps(color: KColors.error),
                          ),
                        ),
                ],
              ),
            ),
          ),
        );
      }
    }
    return widgets;
  }

  void _showClearDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear Library?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _clearHistory();
            },
            child: Text(
              'Clear',
              style: KTextStyles.bodySM(color: KColors.error)
                  .copyWith(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: KColors.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.folder_open_outlined,
              size: 36,
              color: KColors.primary.withValues(alpha: 0.60),
            ),
          ),
          const SizedBox(height: 20),
          Text('Library is empty', style: context.kHeadlineSM),
          const SizedBox(height: 8),
          Text(
            'Your converted files will appear here.',
            style: context.kBodySM,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
