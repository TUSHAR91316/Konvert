# Konvert Release Notes

## Version 1.6.2
*Feature Update & Optimization*

**New Features**
- **In-App Update Notifier:** Konvert now automatically checks for updates via GitHub. Whenever a new version goes live, you will gently be prompted directly on the home screen to download the latest security patches and features.
- **SQLite Optimization:** Migrated the background history tracking to a fast, reliable SQLite database framework.
- **Microservice Architecture Alignment:** The frontend perfectly hands off processing to our optimized local FastAPI backend.

**Bug Fixes & Maintenance**
- Fixed redundant API logic and code linting errors.
- Improved the Authentication flow by enforcing cleaner `AuthService` abstraction and responsive Snackbar error handling.

---

## Version 1.6.1
- Complete UI revamp with Home, Converter, and History screens.
- Added File Encryption security standards.
- Integrated Google Sign-In and Email pipelines.
- Implemented "Bring Your Own Backend" integration for a zero-cost Docker microservice architecture.
