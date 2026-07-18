import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ConfigService {
  final FlutterSecureStorage _storage;

  ConfigService({FlutterSecureStorage? storage}) : _storage = storage ?? const FlutterSecureStorage();

  Future<String> getBackendUrl() async {
    String? storedUrl = await _storage.read(key: 'backend_url');
    String url = (storedUrl != null && storedUrl.isNotEmpty)
        ? storedUrl.trim()
        : (dotenv.env['BACKEND_URL'] ?? 'http://localhost:8080').trim();

    // Sanitize trailing slashes
    while (url.endsWith('/')) {
      url = url.substring(0, url.length - 1);
    }

    // Ensure it starts with http:// or https://
    if (!url.startsWith('http://') && !url.startsWith('https://') && url.isNotEmpty) {
      url = 'https://$url';
    }

    return url;
  }

  Future<void> setBackendUrl(String url) async {
    await _storage.write(key: 'backend_url', value: url.trim());
  }
}
