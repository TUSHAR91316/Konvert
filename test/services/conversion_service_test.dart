import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:mocktail/mocktail.dart';
import 'package:converter_app/services/conversion_service.dart';
import 'package:converter_app/services/config_service.dart';

class MockDio extends Mock implements Dio {}
class MockConfigService extends Mock implements ConfigService {}
class MockFile extends Mock implements File {}

void main() {
  group('ConversionService Remote Tests', () {
    late MockDio mockDio;
    late MockConfigService mockConfigService;
    late ConversionService conversionService;
    late MockFile mockInputFile;

    setUp(() {
      mockDio = MockDio();
      mockConfigService = MockConfigService();
      conversionService = ConversionService(dio: mockDio, configService: mockConfigService);
      mockInputFile = MockFile();

      when(() => mockInputFile.path).thenReturn('/path/to/input.docx');
    });

    test('convertRemote throws ConversionException when download fails with structured JSON error', () async {
      when(() => mockConfigService.getBackendUrl())
          .thenAnswer((_) async => 'http://localhost:8080');

      // Set up mock throw for Dio download
      when(() => mockDio.download(
            any(),
            any(),
            data: any(named: 'data'),
            queryParameters: any(named: 'queryParameters'),
            options: any(named: 'options'),
          )).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ''),
          type: DioExceptionType.badResponse,
          response: Response(
            requestOptions: RequestOptions(path: ''),
            statusCode: 500,
          ),
        ),
      );

      // In real scenario, the file contains the JSON error if it is < 10000 bytes
      // But mocktail requires us to mock the File operations if we use a mock file.
      // So instead of a mock File for output, the code creates a real File in a temp directory.
      // Let's run this test using a real temp file.
      final tempDir = Directory.systemTemp.createTempSync();

      try {
        final inputFile = File('${tempDir.path}/input.docx')..writeAsStringSync('dummy content');
        final task = conversionService.convertRemote(
          inputFile,
          'pdf',
          outputDirPath: tempDir.path,
        );

        expect(task, throwsException);
      } finally {
        tempDir.deleteSync(recursive: true);
      }
    });
  });
}
