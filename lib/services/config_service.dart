import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:converter_app/constants/api_constants.dart';

class ConfigService {
  final FlutterSecureStorage _storage;

  ConfigService({FlutterSecureStorage? storage}) : _storage = storage ?? const FlutterSecureStorage();

  Future<String> getBackendUrl() async {
    String? storedUrl = await _storage.read(key: 'backend_url');

    // Use stored URL if the user has configured one.
    if (storedUrl != null && storedUrl.isNotEmpty) {
      return _sanitize(storedUrl);
    }

    // Check .env fallback
    final envUrl = dotenv.env['BACKEND_URL'];
    if (envUrl != null && envUrl.isNotEmpty) {
      return _sanitize(envUrl);
    }

    // Smart platform fallback:
    // On Android Emulators, 'localhost' resolves to the emulator's own loopback.
    // The host machine's localhost is reachable via 10.0.2.2.
    // On physical devices / other platforms, default to localhost (offline by design
    // until the user configures their ngrok URL in Settings).
    if (Platform.isAndroid) {
      // Heuristic: emulators typically have hostname starting with 'generic' or 'sdk_'
      // but this is not reliable. We default to the emulator address for Android
      // so local dev works. On production physical devices this will fail gracefully
      // (backend shows offline, which is correct until user pastes ngrok URL).
      return ApiConstants.emulatorBackendUrl;
    }

    return ApiConstants.defaultBackendUrl;
  }

  Future<void> setBackendUrl(String url) async {
    await _storage.write(key: 'backend_url', value: url.trim());
  }

  /// Sanitizes a raw URL string:
  ///   1. Trims surrounding whitespace.
  ///   2. Strips trailing slashes.
  ///   3. Prepends https:// if no scheme is present.
  String _sanitize(String url) {
    url = url.trim();

    // Strip trailing slashes
    while (url.endsWith('/')) {
      url = url.substring(0, url.length - 1);
    }

    // Ensure a scheme is present
    if (url.isNotEmpty && !url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
    }

    return url;
  }
}
