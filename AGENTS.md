# AGENTS.md

## Cursor Cloud specific instructions

- **Stack**: Flutter 3.41+ (Dart 3.11+) cross-platform app targeting Android, iOS, and Web.
- **Flutter SDK**: Installed at `/home/ubuntu/flutter/bin`. Must be on `PATH` (`export PATH="$PATH:/home/ubuntu/flutter/bin"`).
- **Package manager**: `flutter pub get` from workspace root.
- **Lint**: `flutter analyze` — zero issues expected.
- **Test**: `flutter test` — Hive boxes must be initialized with `Hive.init(tmpDir)` in test setUp (see `test/widget_test.dart`).
- **Build web**: `flutter build web --release` — output goes to `build/web/`.
- **Run web locally**: `cd build/web && python3 -m http.server 8080` then open `http://localhost:8080/`.
- **Key dependencies**: `epubx` (EPUB parsing), `pdfrx` (PDF viewing), `hive_flutter` (local storage), `provider` (state management), `http` (OpenAI API).
- The AI chatbot requires an OpenAI API key configured via Settings screen in the app. Without it, chat replies prompt the user to add a key.
- `epubx` 4.0.0 still uses PascalCase properties (`.Title`, `.HtmlContent`, etc.). The local `BookChapter` class avoids naming conflict with `epubx.EpubChapter`.
