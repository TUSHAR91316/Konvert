# 🚀 Konvert Release Notes & Changelog

All notable changes, new capabilities, architectural improvements, and bug fixes for every public release of **Konvert** are documented in this file.

---

## 📌 Version 1.7.0 (Current Release)
*Full Package Upgrade, Live Telemetry, In-App Direct Installer & Hybrid PDF Merge*

### 🌟 Core Highlights
This release upgrades every direct dependency to its latest available version, modernizes Google Sign-In to the new v7 API (Android Credential Manager), bumps the Android build toolchain to Java 17 / Gradle 8.14 / AGP 8.11.1, introduces real-time system hardware telemetry, and adds seamless in-app direct APK updates.

---

### 🚀 Key Features & Architectural Enhancements

1. 📊 **Real-Time System Hardware Telemetry**
   - **Backend Telemetry Endpoint**: Added `psutil` hardware inspection (`GET /health/details`) reporting real-time CPU %, RAM consumption (used/total MB), and free disk space (GB).
   - **Interactive Status Modal**: Tapping the "SYSTEM STATUS" Bento card opens a real-time telemetry bottom sheet with animated progress bars, live latency ping (ms), and an instant reconnect button.

2. 📲 **In-App Direct Release Downloader & Native Installer**
   - **Seamless In-App Streaming**: Replaced external browser redirects with a built-in streaming downloader (`Dio().download`) displaying real-time download progress (`0%` → `100%`).
   - **One-Tap System Installation**: Tapping "Install Update" downloads the `.apk` directly and triggers the native Android package installer prompt via `open_file` — zero manual web browsing or file manager searching required.

3. 🧩 **Lossless Hybrid Multi-PDF Merging**
   - **Smart Fallback Engine**: Multi-PDF merges process losslessly on the self-hosted backend (`/merge-pdfs`) when connected, and automatically fall back to **100% offline** on-device merging via the `pdf` & `printing` Dart packages when offline.

4. ⚡ **Asynchronous Non-Blocking Document Processing**
   - **Async Subprocess Execution**: Replaced blocking calls with `asyncio.create_subprocess_exec()` in backend LibreOffice handlers so heavy document processing never blocks server health checks or telemetry requests.
   - **Startup Dialog Safety**: Wrapped update checks in `addPostFrameCallback` to eliminate cold-launch UI rendering race conditions.

5. 🛠️ **Refined Theme & System Persistence**
   - **Theme Mode Persistence**: Persisted `ThemeMode` (`light`/`dark`) in `FlutterSecureStorage` across both the Settings toggle and the top navigation quick-toggle, surviving app restarts.
   - **Dynamic Storage Paths**: Implemented `path_provider` directory resolution and dynamic folder pickers for full Android Scoped Storage compliance.
   - **Smart Emulator Loopback**: Configured `ConfigService` to auto-detect Android emulators (`10.0.2.2:8080`) while preserving `localhost` and Ngrok static domain configurations for physical devices.
   - **Centralized API Constants**: Centralized all endpoint routes, network timeouts, and file size thresholds in `ApiConstants`.

---

### 📦 Major Package Upgrades

| Package | Previous | Now | Purpose |
|---|---|---|---|
| `google_sign_in` | 6.2.2 | **7.2.0** | Migrated to Android Credential Manager API |
| `permission_handler` | 12.0.3 | **13.0.1** | Android 14 granular media permissions |
| `firebase_core` | 4.12.1 | **4.14.0** | Core Firebase SDK modernization |
| `firebase_auth` | 6.5.6 | **6.6.0** | Authentication session stability |
| `cloud_firestore` | 6.7.1 | **6.9.0** | Cloud database sync performance |
| `google_fonts` | 6.3.3 | **8.2.1** | Inter font family typography updates |
| `file_picker` | 10.x | **12.1.1** | High-performance document & image picker (v12 API) |
| `flutter_secure_storage` | 10.3.1 | **11.0.0** | Hardware-backed secure storage with Windows 4.2.2 support |
| `open_file` | 3.x | **4.0.0** | Native Android installer invocation |
| `pdf` | 3.12.0 | **3.13.0** | Offline document rendering & PDF creation |
| `printing` | 5.14.3 | **5.15.0** | Direct rasterization & print engine |
| `dio` | 5.10.0 | **5.11.0** | Streaming HTTP client with Ngrok bypass headers |
| `sqflite` | 2.4.2+1 | **2.4.3** | High-speed local history database |
| `flutter_image_compress` | 2.5.0 | **2.5.1** | Native image compression algorithms |
| `package_info_plus` | 9.0.1 | **10.2.1** | Modernized app metadata platform interface |

---

### 🛡️ Build Toolchain & Deprecation Fixes
- **Gradle** upgraded from 8.11.1 → **8.14**.
- **Java 17 Compatibility**: Upgraded Java source & target compatibility to `JavaVersion.VERSION_17` and `jvmTarget = "17"` in `build.gradle.kts`.
- **Android Gradle Plugin (AGP)** set to **8.11.1**.
- **Kotlin** upgraded to **2.2.20**.
- **compileSdk** set to **37** (required for `permission_handler` v13 / Android 14+).

---

## 📌 Version 1.6.4
*Precision Slate UI, Stability & Error Handling*

* 🎨 **Precision Slate UI**: Modern, clean design system with 1px card outlines, strict 8-point grid alignment, and Slate-inspired colors.
* 🎨 **Dynamic Accent Colors**: Interactive accent color swatches (Indigo, Blue, Emerald, Red) persisting in secure storage.
* 🧭 **4-Tab Navigation**: Clean bottom navigation (Dashboard, Library, Tools, Settings) with categorized Toolbox.
* 🔢 **Numeric Error Codes**: Structured numeric error codes (`4001`, `5001`, `5002`) with clear explanations and troubleshooting tips.
* 🐛 **Zero Storage Leaks**: Automatic cleanup of temporary `/tmp/outputs/` files upon conversion completion or failure.
* 🐛 **Streamed Large File Transfers**: Replaced in-memory RAM buffering with streaming downloads for 100MB+ files.

---

## 📌 Version 1.6.3
*UI Overhaul — Obsidian Design System*

* 🌌 **Obsidian Theme**: Deep dark backgrounds with electric violet accents and Inter typography.
* 📱 **Bottom Navigation Bar**: Modern animated bottom navigation with active dot indicators.
* 🔍 **Grouped Library**: Conversion history organized by Today, Yesterday, Last Week, and Older.

---

## 📌 Version 1.6.2
*In-App Notifier & Self-Hosting Integration*

* 🔔 **In-App Update Notifier**: Automatic GitHub release checking.
* 💾 **SQLite Migration**: High-speed local database for conversion logs.
* 🐳 **Self-Hosting Guide**: Integrated in-app guide for Docker and Ngrok setups.

---

## 📌 Version 1.6.1
*Initial Hybrid Release*

* Initial release of the hybrid on-device + self-hosted Docker conversion architecture with Google Sign-In and local image tools.
