
# DV Photo App — Part 1 (Flutter scaffold)

This is the **Part 1** drop: project scaffold, dependencies, routing, theming, flavors (global / ethiopia), and Riverpod setup.
No image processing yet — that comes in Part 2.

## Structure
```
lib/
  main.dart
  app.dart
  routing/app_router.dart
  config/app_config.dart
  features/
    splash/splash_screen.dart
    home/home_screen.dart
  shared/
    theme/app_theme.dart
    providers/global_providers.dart
    widgets/app_scaffold.dart
analysis_options.yaml
pubspec.yaml
```

## Flavors
We use a single codebase with a compile-time flag:

- `APP_FLAVOR=global` (default)
- `APP_FLAVOR=ethiopia`

### Run
```bash
# Global (default)
flutter run --dart-define=APP_FLAVOR=global

# Ethiopia
flutter run --dart-define=APP_FLAVOR=ethiopia
```

You can also set the flag in your IDE Run Configurations.

## What’s included here
- **Flutter + Riverpod + GoRouter** basics
- **App theme** (light/dark) and simple typography
- **Splash → Home** navigation flow
- **AppConfig** reads flavor and exposes `isLocalService` boolean for later

## Next (Part 2)
- Face detection + landmark-based auto-crop
- Compliance metrics (head %, eye line, dimensions, size ≤240KB, sRGB)
- Export & print-sheet generator
- Web checker starter (Next.js) + Supabase schema

---

If anything doesn’t open, just create a new empty Flutter project and **copy/overwrite** the `lib/`, `pubspec.yaml`, and `analysis_options.yaml` from this package.
```bash
flutter clean && flutter pub get
```
