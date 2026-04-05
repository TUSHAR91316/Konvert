import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ConfigService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<String> getBackendUrl() async {
    String? storedUrl = await _storage.read(key: 'backend_url');
    if (storedUrl != null && storedUrl.isNotEmpty) {
      return storedUrl;
    }
    // Fallback to .env variable
    return dotenv.env['BACKEND_URL'] ?? 'http://localhost:8080';
  }

  Future<void> setBackendUrl(String url) async {
    await _storage.write(key: 'backend_url', value: url.trim());
  }
}
