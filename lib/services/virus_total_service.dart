import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class VirusTotalService {
  final Dio _dio = Dio();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  static const String _baseUrl = 'https://www.virustotal.com/api/v3';

  Future<String?> getApiKey() async {
    return await _storage.read(key: 'vt_api_key');
  }

  Future<void> setApiKey(String key) async {
    await _storage.write(key: 'vt_api_key', value: key);
  }

  Future<bool> getAutoScanEnabled() async {
    String? val = await _storage.read(key: 'auto_scan_enabled');
    return val == 'true';
  }

  Future<void> setAutoScanEnabled(bool enabled) async {
    await _storage.write(key: 'auto_scan_enabled', value: enabled.toString());
  }

  // Upload file to VirusTotal
  // Returns analysis ID
  Future<String?> scanFile(File file) async {
    final apiKey = await getApiKey();
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception("API Key not found");
    }

    String fileName = file.path.split('/').last;
    FormData formData = FormData.fromMap({
      "file": await MultipartFile.fromFile(file.path, filename: fileName),
    });

    try {
      final response = await _dio.post(
        '$_baseUrl/files',
        data: formData,
        options: Options(headers: {'x-apikey': apiKey}),
      );

      return response.data['data']['id']; // Analysis ID
    } on DioException catch (e) {
      throw Exception("VirusTotal Upload Failed: ${e.message}");
    }
  }

  // Get Analysis Report
  // Returns simple status string or full json
  Future<Map<String, dynamic>> getReport(String analysisId) async {
    final apiKey = await getApiKey();
    if (apiKey == null) throw Exception("API Key not found");

    try {
      final response = await _dio.get(
        '$_baseUrl/analyses/$analysisId',
        options: Options(headers: {'x-apikey': apiKey}),
      );
      return response.data['data']['attributes'];
    } on DioException catch (e) {
      throw Exception("Failed to get report: ${e.message}");
    }
  }
}
