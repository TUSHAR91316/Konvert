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

**Workflow File:** `.github/workflows/flutter_ci.yml`

This workflow triggers on **Push** and **Pull Request** to the `main` branch. It performs the following steps:
1. Checks out the repository.
2. Sets up Java 17 and the stable Flutter SDK.
3. Installs dependencies (`flutter pub get`).
4. Runs strict static analysis (`flutter analyze --fatal-infos`).
5. Runs the full test suite (`flutter test`).
6. Builds a Release APK for Android and uploads it as an artifact.

## 3. Testing Suite

The `test/` directory contains tests for all critical parts of the application.

### Unit Tests
Located in `test/services/`. We use the `mocktail` package to mock external dependencies like `Dio` (HTTP) and `FlutterSecureStorage`.
- `config_service_test.dart`: Verifies environment variables and backend URL storage.
- `conversion_service_test.dart`: Verifies local image-to-PDF generation and remote API error handling.
- `virus_total_service_test.dart`: Verifies API key storage and file size limits (32MB).

### Widget Tests
Located in `test/widgets/`. 
- `convert_screen_test.dart`: Verifies the UI renders correctly, including the Upload Zone, Document Setup, Output Quality toggles, and the Save Location selector.

### Integration Tests
Located in `test/integration/`.
- `backend_connectivity_test.dart`: A smoke test that pings the local Docker backend. **Note:** This is intentionally skipped during GitHub Actions CI because the backend isn't spun up in the testing step.

## How to Run Tests Manually
```bash
# Run all tests
flutter test

# Run a specific test
flutter test test/widgets/convert_screen_test.dart
```
