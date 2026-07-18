# Konvert Release Notes

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
