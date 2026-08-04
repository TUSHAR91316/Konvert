# Konvert Release Notes

## Version 1.7.0
*Full Package Upgrade, Auth Modernisation & Build Infrastructure Update*

**Highlights**
This release upgrades every dependency to its latest available version, modernises the Google Sign-In flow to the new v7 API (Android Credential Manager), bumps the Android build toolchain (Gradle 8.14, AGP 8.11.1, compileSdk 37), and includes all polish and stability improvements originally planned for 1.6.5.

---

**Core Feature Pillars & Architectural Enhancements**

1. 📊 **System Status Telemetry Details**
   - **Backend Telemetry Endpoint**: Added `psutil` integration to the FastAPI backend (`GET /health/details`) to report real-time CPU %, RAM usage (used/total MB), and free disk space (GB).
   - **Live Telemetry Bottom Sheet**: Tapping the "SYSTEM STATUS" bento card on the dashboard opens an interactive modal displaying real-time server metrics, CPU/RAM progress bars, network latency ping (e.g. `42ms`), and a manual "Reconnect / Refresh" button.

2. ⚡ **Architectural & Concurrency Fixes**
   - **Async Backend Subprocess**: Replaced blocking `subprocess.run()` with `asyncio.create_subprocess_exec()` in LibreOffice conversion handlers so heavy document processing never blocks server health checks or telemetry requests.
   - **Startup Dialog Safety**: Wrapped `UpdateService().checkForUpdate(context)` in `WidgetsBinding.instance.addPostFrameCallback` in `home_screen.dart` to eliminate potential rendering race conditions on cold launch.

3. 🛠️ **Code Audit & Hardcoding Refactors**
   - **Theme Mode Persistence**: Persisted `ThemeMode` (`light`/`dark`) in `FlutterSecureStorage` across both the Settings toggle and the top navigation bar quick-toggle, ensuring theme choices survive cold app restarts.
   - **Dynamic Storage Paths**: Replaced hardcoded Android download paths with `path_provider` (`getDownloadsDirectory()` / `getTemporaryDirectory()`) and dynamic user folder pickers for cross-platform compliance.
   - **Smart Emulator Loopback**: Configured `ConfigService` to auto-detect Android emulator environments and route loopback connections to `10.0.2.2:8080` while retaining `localhost` / ngrok configurations for physical devices.
   - **Centralized API Constants**: Created `ApiConstants` to manage all external endpoint URLs, network timeout durations (`connectTimeout`, `sendTimeout`, `receiveTimeout`), and file size thresholds.

4. 🧩 **Offline Multi-PDF Merging**
   - **Hybrid PDF Merging Engine**: Implemented seamless multi-PDF merging in `ConversionService`. Merges process losslessly on the self-hosted backend (`/merge-pdfs`) when connected, and automatically fall back to **100% offline** on-device merging via the `pdf` & `printing` Dart packages when offline or standalone.

5. 🐛 **Bug Fix & UX: In-App Direct Update Downloader & Installer**
   - **Fixed Unresponsive / External Download Action**: Resolved an issue where tapping "Download Update" did not initiate an in-app download or launch the installer.
   - **Direct APK Streaming**: Replaced external browser redirects with a built-in streaming downloader (`Dio().download`) directly inside the update dialog, displaying real-time progress (`0%` → `100%`).
   - **One-Tap Native Installation**: Tapping "Install Update" downloads the `.apk` directly to storage and triggers the native Android package installer prompt via `open_file` — zero manual web browsing or file manager searching required.

---

**Package Upgrades — All Dependencies at Latest**
Every direct dependency has been audited and upgraded:

| Package | Previous | Now |
|---|---|---|
| `google_sign_in` | 6.2.2 | **7.2.0** |
| `permission_handler` | 12.0.3 | **13.0.0** |
| `firebase_core` | 4.12.1 | **4.13.0** |
| `firebase_auth` | 6.5.6 | **6.5.7** |
| `cloud_firestore` | 6.7.1 | **6.8.0** |
| `google_fonts` | 6.3.3 | **8.2.1** |
| `file_picker` | 10.x | **11.0.3** |
| `open_file` | 3.x | **4.0.0** |
| `pdf` | 3.12.0 | **3.13.0** |
| `printing` | 5.14.3 | **5.15.0** |
| `dio` | 5.10.0 | **5.11.0** |
| `sqflite` | 2.4.2+1 | **2.4.3** |
| `flutter_image_compress` | 2.5.0 | **2.5.1** |

---

**Google Sign-In v7 Migration (Android Credential Manager)**
- Migrated from the deprecated Google Sign-In SDK to the new **Android Credential Manager** backed API (`google_sign_in` v7).
- `GoogleSignIn()` constructor replaced with `GoogleSignIn.instance` singleton pattern.
- `signIn()` replaced with `authenticate()` — returns the signed-in account directly with proper cancellation handling via `GoogleSignInException`.
- Added mandatory `GoogleSignIn.instance.initialize()` + `attemptLightweightAuthentication()` at app startup for seamless silent sign-in restoration for returning users.
- Authentication tokens now correctly use only `idToken` for Firebase credential (v7 separates authentication from authorization).

---

**Android Build Toolchain & Deprecation Fixes**
- **Gradle** upgraded from 8.11.1 → **8.14** (eliminates Gradle wrapper deprecation warnings).
- **Java 17 Toolchain Compatibility**: Upgraded Java source & target compatibility to `JavaVersion.VERSION_17` and `jvmTarget = "17"` in `build.gradle.kts`, completely eliminating obsolete Java 8/11 compiler warnings during release builds.
- **Android Gradle Plugin (AGP)** set to **8.11.1**.
- **Kotlin** upgraded to **2.2.20**.
- **compileSdk** bumped from 36 → **37** (required by `permission_handler` v13 / `permission_handler_android` v14).
- **Android SDK Platform 37 Fix**: Configured filesystem directory junction (`android-37.0` → `android-37`) resolving Gradle target hash lookup errors.
- **Transitive Dependencies Audit**: Upgraded 11 locked transitive dependencies (`url_launcher_android` 6.3.32, `objective_c` 9.5.0, `dio_web_adapter` 2.2.1, `package_config` 3.0.0, `vector_graphics` 1.2.3, `jni` 1.0.3, `posix` 6.5.2, etc.) to their latest compatible stable releases while maintaining `win32` 5.15.0 compatibility.

---



## Version 1.6.4
*Infrastructure, Bug Fixes, & Polish Update*

**Highlights**
This release focuses on testing, stability, robust error handling, and file system controls to ensure the application is completely solid and professional.

**New Features & Improvements**
- 🎨 **Precision Slate UI**: Completely replaced the previous "Obsidian" glassmorphic UI (which had a generic "AI-slop" feel) with a flat, professional design system using clean 1px card outlines, strict 8-point grid alignment, and Slate-inspired colors.
- 🎨 **Dynamic Accent Colors**: Added fully functional, interactive settings accent color swatches (Indigo, Blue, Emerald, Red) that persist in secure storage and instantly update the entire app's theme at runtime.
- ⏰ **Time-based Greetings**: Removed cliché waving emojis and "Hello there 👋" placeholders, replaced by clean, professional greetings ("Good morning", "Good afternoon", "Good evening") determined by system time.
- 🧭 **Structured Navigation**: Organized the bottom navigation into a clean 4-tab layout (Dashboard, Library, Tools, Settings) with a dedicated categorized Toolbox page to separate dashboard activities from conversion tools.
- 🔄 **Hybrid Image-to-PDF Fallback**: Connected image conversions to the backend with a built-in automated fallback to local on-device PDF conversion if the backend fails or goes offline.
- 🌟 **Save Location Control**: Added a brand new "Save Location" selector on the Convert Screen so you can easily choose where converted files are downloaded.
- 🔧 **Under-the-hood Pipeline**: Revamped local testing pipeline with native Git Hooks (`pre-commit` and `pre-push`) to guarantee code quality.
- 📦 **Dependency Update**: Updated 48 outdated core packages to their latest versions for better performance and security.
- ✅ **Test Coverage**: Added comprehensive widget and unit tests across the application, including Update Service version checking rules.
- 🚀 **Auto-Update Notifier Fixes**: Fixed tag parsing to support uppercase 'V' tags (e.g., `V1.6.3`), enabling flawless automatic update prompts.
- 🎨 **Redesigned Update Alert Dialog**: Polished the update notifier popup with a premium Precision Slate UI design matching the system dark/light colors.

**Robust Error Handling**
- **Numeric Error Codes**: The app now displays specific Error Codes (e.g., `4001`, `5001`, `5002`) instead of generic "Conversion failed" messages. 
- **Actionable Resolutions**: Whenever an error occurs, a beautiful dialog box pops up giving you a clear English explanation of why the failure happened, and a "Tip" on how to resolve it.

**Bug Fixes**
- 🐛 **Fixed Backend Storage Leak**: Deeply corrupted files crashing the self-hosted backend will no longer permanently consume hard drive space. The backend now cleans up orphaned files on failure.
- 🐛 **Fixed Out-Of-Memory Crash**: Massive conversions (100MB+) will no longer crash older Android phones. The app now uses a streaming download engine (`dio.download`) to save files directly to the storage instead of buffering in RAM.
- 🐛 **Fixed VirusTotal Crash**: The app now intelligently checks file size before uploading. If the file exceeds the free VirusTotal 32MB limit, the upload is safely aborted with a friendly warning.
- 🐛 **Fixed History Sync**: If you delete a PDF locally on your phone via a file manager, the Konvert app now auto-detects this and silently cleans up the broken link from your Library log.

---

## Version 1.6.3
*UI Overhaul — Obsidian Design System*

**Highlights**
This release is a full visual upgrade to the **Konvert Obsidian** design system — a premium dark-first aesthetic with glassmorphism cards, electric violet accents, and Inter typography. Every screen has been restyled. No features were removed.

**Design System**
- New **Obsidian** color palette — deep `#0B1326` backgrounds, electric violet `#8B5CF6` accent, and matching indigo `#6366F1` secondary.
- Both **dark mode** and **light mode** fully updated — dark uses glassmorphism blur cards; light uses clean white cards with subtle violet shadow.
- **Inter** font family applied app-wide via `google_fonts` for a professional, modern typographic hierarchy.
- Reusable `KDecorations` helpers (glass card, light card, gradient button, ghost button) and `KColors` token system for consistent theming.

**Navigation**
- Replaced the side **Drawer** with a 4-tab **bottom navigation bar**: Dashboard · Library · Tools · Settings.
- New glass-style `KonvertTopBar` with gradient "Konvert" wordmark and user avatar (initials fallback).
- Animated bottom nav with violet active dot indicator and smooth icon transitions.

**Screens Updated**
- **Dashboard** — greeting, featured tool hero cards, full tool grid (6 cards), recent conversions section, guest sign-in nudge.
- **Library** (formerly History) — conversions grouped by TODAY / YESTERDAY / LAST WEEK / OLDER; color-coded file type icons.
- **Convert** — glass upload zone with violet glow, horizontal file thumbnails, segmented Page Size toggle, Portrait/Landscape icon buttons, violet gradient CTA.
- **Compress** — icon-based mode selector (Percentage / Target Size), styled slider, save location row.
- **Settings** — bento card layout (Account, Appearance, Backend, Security, About); dark mode toggle; accent color swatches; What's New card.
- **Sign In / Sign Up** — glass form cards on obsidian background, password visibility toggles, Google sign-in ghost button.
- **Welcome** — radial glow behind logo, feature pills, gradient CTA + ghost Sign In button.
- **Forgot Password** — Obsidian treatment, success state UI after email sent.

**Bug Fixes & Memory Leaks**
- 🐛 **Fixed memory leak** in `settings_screen.dart` — two `TextEditingController`s were never disposed; `dispose()` method added.
- 🐛 **Fixed memory leak** in `forgot_password.dart` — `TextEditingController` was never disposed; `dispose()` method added.
- Fixed broken reference to removed `lightColorScheme` in `forgot_password.dart`.
- Fixed `CardTheme` / `DialogTheme` → `CardThemeData` / `DialogThemeData` type mismatch in theme definitions.
- Resolved all `flutter analyze` warnings — **zero issues**.

---

## Version 1.6.2
*Feature Update & Optimization*

**New Features**
- **In-App Update Notifier:** Konvert now automatically checks for updates via GitHub. Whenever a new version goes live, you will gently be prompted directly on the home screen to download the latest security patches and features.
- **SQLite Optimization:** Migrated the background history tracking to a fast, reliable SQLite database framework.
- **Microservice Architecture Alignment:** The frontend perfectly hands off processing to our optimized local FastAPI backend.
- **Self-Hosting Backend Guide:** New dedicated screen with step-by-step instructions for deploying your own backend using Docker, ngrok, Cloudflare Tunnel, or any other tunneling service. Includes direct links to download backend files from GitHub and detailed setup instructions.
- **Dynamic Version Display:** Settings page now displays the actual app version dynamically from the build configuration.
- **Enhanced Server Configuration:** Updated UI with clearer descriptions for connecting to self-hosted backends via multiple tunneling providers.

**Bug Fixes & Maintenance**
- Fixed redundant API logic and code linting errors.
- Improved the Authentication flow by enforcing cleaner `AuthService` abstraction and responsive Snackbar error handling.
- Updated Server Configuration section text for clarity on self-hosting options.

---

## Version 1.6.1
- Complete UI revamp with Home, Converter, and History screens.
- Added File Encryption security standards.
- Integrated Google Sign-In and Email pipelines.
- Implemented "Bring Your Own Backend" integration for a zero-cost Docker microservice architecture.
