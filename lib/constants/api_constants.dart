/// Centralized configuration constants for all external API endpoints,
/// file size limits, and network timeout durations.
///
/// Usage: Import this file instead of hardcoding values in service files.
class ApiConstants {
  ApiConstants._(); // Prevent instantiation

  // ── GitHub Releases API ───────────────────────────────────────────────────
  static const String githubReleasesUrl =
      'https://api.github.com/repos/TUSHAR91316/Konvert-Website/releases/latest';

  // ── VirusTotal API ────────────────────────────────────────────────────────
  static const String virusTotalBaseUrl = 'https://www.virustotal.com/api/v3';

  /// Free-tier VirusTotal upload limit (32 MB in bytes).
  static const int virusTotalMaxBytes = 32 * 1024 * 1024; // 32 MB

  // ── Backend / Self-Hosted ─────────────────────────────────────────────────
  /// Default backend URL used when no user-configured URL is present.
  /// On Android emulators, 10.0.2.2 is the alias for the host machine's
  /// loopback (localhost). On real devices / release builds, this default
  /// will always show "Offline" until the user configures their ngrok URL.
  static const String defaultBackendUrl = 'http://localhost:8080';
  static const String emulatorBackendUrl = 'http://10.0.2.2:8080';

  // ── Dio Timeouts ──────────────────────────────────────────────────────────
  static const Duration connectTimeout = Duration(minutes: 1);
  static const Duration sendTimeout = Duration(minutes: 5);
  static const Duration receiveTimeout = Duration(minutes: 5);
  static const Duration healthCheckTimeout = Duration(seconds: 4);

  // ── Error-response heuristic ──────────────────────────────────────────────
  /// If a downloaded file is smaller than this, it may be a JSON error payload
  /// rather than a real converted document. We attempt JSON parsing if so.
  static const int maxJsonErrorPayloadBytes = 10000;
}
