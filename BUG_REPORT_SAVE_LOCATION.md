# Bug Report: Missing Save Location Selection in Convert Screen

## Issue Description
Following the migration to the **Obsidian UI (v1.6.3)**, the "Save Location" (Output Directory) selection card has disappeared from the **Convert Screen**. While the backend logic still supports custom output paths, users currently have no UI element to view or change the directory, defaulting it to the system Downloads folder.

## Affected Version
- **App Version:** 1.6.3+8 (Obsidian UI)
- **Module:** `lib/screens/convert_screen.dart`

## Steps to Reproduce
1. Open the app and navigate to the **Dashboard**.
2. Select any conversion tool (e.g., "Images → PDF").
3. Observe the conversion options area.
4. **Actual Result:** Only Page Size, Orientation, and Quality toggles are visible. The "Save Location" card is missing.
5. **Expected Result:** A card should be visible (similar to the Compress screen) allowing users to pick a custom output directory via `FilePicker.platform.getDirectoryPath()`.

## Technical Details
- The variable `_outputDirectory` exists in `_ConvertScreenState`.
- The `ConversionService` methods (`imagesToPdf`, `convertRemote`) correctly accept `outputDirPath`.
- **Regression:** The `_pickDirectory()` method and the corresponding `GestureDetector` + `_BentoSection` UI block were omitted during the restyling of the `build` method in `convert_screen.dart`.

## Comparison with Compress Screen
In `compress_image_screen.dart`, the feature is working as expected:
```dart
// Working implementation in Compress Screen
GestureDetector(
  onTap: _pickDirectory,
  child: Container(
    // ... UI decorations ...
    child: Row(
      children: [
        Icon(Icons.folder_outlined, ...),
        Text('Save Location'),
        // ...
      ],
    ),
  ),
)
```

## Recommended Fix
Restore the `_pickDirectory` method and insert the "Save Location" Bento section before the "Status Message" in `convert_screen.dart`.
