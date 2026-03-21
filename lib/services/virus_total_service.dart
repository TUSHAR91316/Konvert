import 'dart:io';
import 'dart:convert';
import 'package:crypto/crypto.dart';
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

  /// Computes the SHA-256 hash of a file.
  Future<String> _sha256OfFile(File file) async {
    final bytes = await file.readAsBytes();
    return sha256.convert(bytes).toString();
  }

  /// Scans a file with VirusTotal.
  /// First checks if VT already knows the file by hash (avoids 409 Conflict).
  /// Returns an analysis ID or file ID that can be used with [getReport].
  Future<String?> scanFile(File file) async {
    final apiKey = await getApiKey();
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception("API Key not found");
    }

    final headers = {'x-apikey': apiKey};

    // Step 1: Check by SHA-256 hash first — avoids 409 if VT already has it.
    final fileHash = await _sha256OfFile(file);
    try {
      final hashResponse = await _dio.get(
        '$_baseUrl/files/$fileHash',
        options: Options(headers: headers),
      );
      // VT already has this file — return its ID directly (no re-upload needed).
      return hashResponse.data['data']['id'];
    } on DioException catch (e) {
      // 404 = file is new to VT, proceed to upload.
      // Any other error = re-throw.
      if (e.response?.statusCode != 404) {
        _handleCommonErrors(e, 'VirusTotal Hash Lookup Failed');
      }
    }

    // Step 2: File is new — upload it.
    final String fileName = file.path.split('/').last;
    final FormData formData = FormData.fromMap({
      "file": await MultipartFile.fromFile(file.path, filename: fileName),
    });

    try {
      final response = await _dio.post(
        '$_baseUrl/files',
        data: formData,
        options: Options(headers: headers),
      );
      return response.data['data']['id'];
    } on DioException catch (e) {
      // 409 = race condition: file was indexed between our hash check and upload.
      // Re-try the hash lookup to get the existing ID.
      if (e.response?.statusCode == 409) {
        try {
          final retryResponse = await _dio.get(
            '$_baseUrl/files/$fileHash',
            options: Options(headers: headers),
          );
          return retryResponse.data['data']['id'];
        } catch (_) {
          // Ignore retry failure — fall through to generic error.
        }
        throw Exception(
          "This file is already known to VirusTotal. "
          "Please try scanning again to retrieve its existing report.",
        );
      }
      _handleCommonErrors(e, 'VirusTotal Upload Failed');
    }
    return null;
  }

  /// Throws a user-friendly exception for common VirusTotal HTTP errors.
  Never _handleCommonErrors(DioException e, String context) {
    final status = e.response?.statusCode;
    if (status == 401) {
      throw Exception("VirusTotal API Key is invalid or unauthorized.");
    } else if (status == 429) {
      throw Exception("VirusTotal rate limit exceeded. Please try again later.");
    }
    throw Exception("$context: ${e.message}");
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
      if (e.response != null) {
        if (e.response!.statusCode == 401) {
          throw Exception("VirusTotal API Key is invalid or unauthorized.");
        } else if (e.response!.statusCode == 404) {
          throw Exception("VirusTotal analysis report not found.");
        } else if (e.response!.statusCode == 429) {
          throw Exception("VirusTotal Rate Limit exceeded. Please try again later.");
        }
      }
      throw Exception("Failed to get VirusTotal report: ${e.message}");
    }
  }
}
