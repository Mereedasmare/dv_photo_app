
# DV Photo App — Part 2 (Image pipeline + Checker)

This drop adds:
- Image picker (gallery/camera-ready base).
- Face detection (Google MLKit).
- Landmark-based **auto-crop** to 600×600 px.
- Compliance metrics: head %, eye-line band, dimensions, file size.
- **Adaptive JPEG** compression ≤ 240 KB.
- sRGB enforced via `image` package re-encode.
- Simple **Photo Checker** screen with pass/fail rows and export.

> Live camera overlay with auto-capture can be plugged in next using the `camera` package. Here we focus on processing + checking.

## pubspec updates
Make sure your root project uses this `pubspec.yaml` (merge with Part 1):
```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^2.5.1
  go_router: ^14.2.1
  image_picker: ^1.1.2
  image: ^4.1.7
  path_provider: ^2.1.4
  google_mlkit_face_detection: ^0.11.0
```

After merging:
```bash
flutter clean
flutter pub get
```

## Android & iOS permissions
Add to **AndroidManifest.xml** inside `<manifest>`:
```xml
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES"/>
<!-- For older Android -->
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
```

Add to **Info.plist**:
```xml
<key>NSCameraUsageDescription</key>
<string>Capture a DV-compliant photo.</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Pick a photo to prepare for DV.</string>
```

## Screens added
- **/checker** – pick photo → process → see report → export DV-ready JPEG.

## Notes
- Head % target = 50–69% of final 600px height. Eyes must fall within typical DV band (top-of-image to eye height band ~ between 336–378 px from top in the final 600px image; we approximate using MLKit eyes).
- If landmarks fail, we fall back to face bounding box center.

## Next (Part 3)
- Live camera overlay + auto-capture
- Print sheet generator (A4/Letter)
- Ethiopia flavor queue + payments + admin
