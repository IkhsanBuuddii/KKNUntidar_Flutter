# KKN Untidar — Flutter port (scaffold)

This folder contains a minimal Flutter scaffold to start porting the native Android app into Flutter for multi-platform targets (mobile + web).

Quick start

1. Install Flutter (stable) and ensure `flutter` is on PATH.
2. From a terminal run:

```cmd
cd d:\KKNUntidar-Flutter\flutter_app
flutter pub get
flutter run -d chrome   # run web
flutter run -d emulator-5554  # or an Android device
```

What I added

- `pubspec.yaml` — basic dependencies (`http`, `provider`), assets entry
- `lib/main.dart` — minimal app with a `HomeScreen` and routing placeholder
- `assets/` — assets folder placeholder

Next steps I can do for you

- Inventory the native Android code and list Activities/Fragments & important Kotlin classes to port.
- Create a per-screen widget scaffold and mapping (start with the main flows).
- Port Kotlin business logic to Dart, one module at a time, and add tests.

Tell me which package(s) or Kotlin files you want ported first (for example: authentication, network layer, local DB, or a specific Activity). 
