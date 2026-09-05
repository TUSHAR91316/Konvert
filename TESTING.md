# Testing & Pipelines

This document outlines the testing strategy, continuous integration (CI) workflows, and local pipelines used in the Konvert project.

## 1. Local Pipeline (Git Hooks)

To prevent bad code from being committed or pushed to the repository, we use native Git hooks. These hooks automatically run checks on your local machine.

### pre-commit
Before any `git commit`, Git will automatically run:
```bash
flutter analyze --fatal-infos
```
If there are any linting errors or unused imports, the commit will be aborted. You must fix the issues to proceed.

### pre-push
Before any `git push`, Git will automatically run:
```bash
flutter test
```
If any unit or widget tests fail, the push will be aborted.

**Note:** These hooks are located in `.git/hooks/pre-commit` and `.git/hooks/pre-push`.

## 2. GitHub Actions (CI/CD)

Even with local hooks, we maintain a robust CI/CD pipeline on GitHub to ensure all merged code is fully verified in a clean environment.

**Workflow Files:**
* `.github/workflows/flutter_ci.yml`: Triggers on Push & PR to `main`.
  1. Checks out repository and sets up Java 17 + stable Flutter SDK.
  2. Resolves dependencies (`flutter pub get`).
  3. Executes strict static analysis (`flutter analyze --fatal-infos`).
  4. Runs the automated test suite (`flutter test`).
  5. Compiles production Release APK (`flutter build apk --release`).
* `.github/workflows/backend_ci.yml`: Triggers on backend changes or manual dispatch.
  1. Lints Python code with `flake8` for syntax and critical errors.
  2. Builds the Docker container stack.
  3. Verifies container health check endpoints.

## 3. Testing Suite

The `test/` directory contains 18 comprehensive tests covering all critical components.

### Unit Tests
Located in `test/services/`. We use `mocktail` to mock external network interfaces (`Dio`) and secure hardware keyrings (`FlutterSecureStorage`).
- `config_service_test.dart`: Verifies environment variables, backend URL storage, and emulator loopback detection.
- `conversion_service_test.dart`: Verifies on-device image-to-PDF generation and remote API error handling.
- `virus_total_service_test.dart`: Verifies API key storage, 32MB payload limit enforcement, and hash lookup.
- `update_service_test.dart`: Verifies semver parsing, build number handling, uppercase `V` tags, and update dialog triggers.

### Widget Tests
Located in `test/widgets/`. 
- `convert_screen_test.dart`: Verifies UI rendering across all responsive viewports, including Upload Zone, Document Setup, Quality Toggles, and Save Location selector.

### Integration & Smoke Tests
- `test/smoke_test.dart`: End-to-end smoke verification of app widget tree and theme provider.
- `test/integration/backend_connectivity_test.dart`: Live smoke check against `http://localhost:8080/health`. Automatically skipped cleanly in CI if local backend is offline.

## How to Run Tests Manually
```bash
# Run all tests (18 tests)
flutter test

# Run with full code coverage report
flutter test --coverage

# Run a specific test file
flutter test test/services/update_service_test.dart
flutter test test/widgets/convert_screen_test.dart
```
