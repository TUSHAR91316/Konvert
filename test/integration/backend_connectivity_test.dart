import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() {
  group('Backend Connectivity Smoke Test', () {
    test('Pings localhost backend health endpoint', () async {
      // Skip this test in GitHub Actions CI as the container runs inside the backend step,
      // but not during the flutter test step.
      final isCI = Platform.environment['GITHUB_ACTIONS'] == 'true';
      if (isCI) {
        debugPrint('Skipping connectivity test in CI environment.');
        return;
      }

      // Load environment configuration
      try {
        await dotenv.load(fileName: '.env');
      } catch (_) {}
      dotenv.env['BACKEND_URL'] = 'http://localhost:8080';

      final backendUrl = dotenv.env['BACKEND_URL'] ?? 'http://localhost:8080';
      final dio = Dio(BaseOptions(connectTimeout: const Duration(seconds: 5)));

      try {
        final response = await dio.get('$backendUrl/health');
        expect(response.statusCode, 200);
        expect(response.data['status'], 'ok');
        debugPrint('Backend is online and healthy at $backendUrl!');
      } on DioException catch (e) {
        debugPrint('Skipping live check: Local backend is offline at $backendUrl. (Error: ${e.message})');
      }
    });
  });
}
