import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:converter_app/services/config_service.dart';

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  setUpAll(() async {
    // Populate fake dotenv
    await dotenv.load(fileName: '.env');
    dotenv.env['BACKEND_URL'] = 'http://env-url.com';
  });

  group('ConfigService Tests', () {
    late MockFlutterSecureStorage mockStorage;
    late ConfigService configService;

    setUp(() {
      mockStorage = MockFlutterSecureStorage();
      configService = ConfigService(storage: mockStorage);
    });

    test('getBackendUrl returns stored URL if present', () async {
      when(() => mockStorage.read(key: 'backend_url'))
          .thenAnswer((_) async => 'http://custom-url.com');

      final url = await configService.getBackendUrl();

      expect(url, 'http://custom-url.com');
      verify(() => mockStorage.read(key: 'backend_url')).called(1);
    });

    test('getBackendUrl returns dotenv fallback if storage is empty', () async {
      when(() => mockStorage.read(key: 'backend_url'))
          .thenAnswer((_) async => null);

      final url = await configService.getBackendUrl();

      expect(url, 'http://env-url.com');
      verify(() => mockStorage.read(key: 'backend_url')).called(1);
    });

    test('setBackendUrl writes trimmed URL to secure storage', () async {
      when(() => mockStorage.write(key: 'backend_url', value: 'http://new-url.com'))
          .thenAnswer((_) async => {});

      await configService.setBackendUrl('  http://new-url.com  ');

      verify(() => mockStorage.write(key: 'backend_url', value: 'http://new-url.com')).called(1);
    });
  });
}
