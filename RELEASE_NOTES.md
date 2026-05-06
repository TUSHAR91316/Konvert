# Konvert Release Notes

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
