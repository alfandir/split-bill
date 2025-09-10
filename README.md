Split Bill Proporsional - Minimal Flutter project
Supports Android and Web.
Run:
  flutter pub get
  flutter run -d chrome   # for web
  flutter run -d emulator # for android/emulator

Notes:
- Uses shared_preferences for offline storage.
- PDF export: uses printing + pdf; on web it triggers file download, on native it saves and opens share sheet.
