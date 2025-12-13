import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class HistoryService {
  static const String _fileName = 'conversion_history.json';

  Future<File> _getFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/$_fileName');
  }

  Future<List<Map<String, dynamic>>> getHistory() async {
    try {
      final file = await _getFile();
      if (!await file.exists()) {
        return [];
      }
      final content = await file.readAsString();
      final List<dynamic> jsonList = jsonDecode(content);
      return jsonList.cast<Map<String, dynamic>>();
    } catch (e) {
      return [];
    }
  }

  Future<void> addEntry({
    required String originalName,
    required String targetFormat,
    required String resultPath,
  }) async {
    final history = await getHistory();
    
    final newEntry = {
      'originalName': originalName,
      'targetFormat': targetFormat,
      'resultPath': resultPath,
      'timestamp': DateTime.now().toIso8601String(),
    };

    history.insert(0, newEntry); // Add to beginning

    final file = await _getFile();
    await file.writeAsString(jsonEncode(history));
  }

  Future<void> clearHistory() async {
    final file = await _getFile();
    if (await file.exists()) {
      await file.delete();
    }
  }
}
