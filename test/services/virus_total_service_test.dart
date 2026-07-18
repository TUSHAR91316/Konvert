import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mocktail/mocktail.dart';
import 'package:converter_app/services/virus_total_service.dart';

class MockDio extends Mock implements Dio {}
class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}
class MockFile extends Mock implements File {}

void main() {
  group('VirusTotalService Tests', () {
    late MockDio mockDio;
    late MockFlutterSecureStorage mockStorage;
    late VirusTotalService vtService;
    late MockFile mockFile;

    setUp(() {
      mockDio = MockDio();
      mockStorage = MockFlutterSecureStorage();
      vtService = VirusTotalService(dio: mockDio, storage: mockStorage);
      mockFile = MockFile();

      // Default mock for file path
      when(() => mockFile.path).thenReturn('/path/to/test_file.txt');
    });

    test('getApiKey returns stored API key', () async {
      when(() => mockStorage.read(key: 'vt_api_key'))
          .thenAnswer((_) async => 'fake_api_key');

      final key = await vtService.getApiKey();
      expect(key, 'fake_api_key');
    });

    test('scanFile throws exception if API Key is missing', () async {
      when(() => mockStorage.read(key: 'vt_api_key'))
          .thenAnswer((_) async => null);

      expect(() => vtService.scanFile(mockFile), throwsException);
    });

    test('scanFile throws exception if file size is > 32MB', () async {
      when(() => mockStorage.read(key: 'vt_api_key'))
          .thenAnswer((_) async => 'fake_key');
      
      // Simulate 33MB file
      when(() => mockFile.length()).thenAnswer((_) async => 33 * 1024 * 1024);

      expect(
        () => vtService.scanFile(mockFile),
        throwsA(
          predicate((e) =>
              e is Exception &&
              e.toString().contains("File exceeds VirusTotal's 32MB limit")),
        ),
      );
    });

    test('scanFile retrieves existing ID on status 200 (hash check)', () async {
      when(() => mockStorage.read(key: 'vt_api_key'))
          .thenAnswer((_) async => 'fake_key');
      when(() => mockFile.length()).thenAnswer((_) async => 1024);
      when(() => mockFile.readAsBytes()).thenAnswer((_) async => Uint8List.fromList([1, 2, 3]));

      when(() => mockDio.get(
            any(),
            options: any(named: 'options'),
          )).thenAnswer((_) async => Response(
            requestOptions: RequestOptions(path: ''),
            statusCode: 200,
            data: {
              'data': {'id': 'existing_analysis_id'}
            },
          ));

      final result = await vtService.scanFile(mockFile);
      expect(result, 'existing_analysis_id');
    });
  });
}
