# Current Task: PGN/FEN Share Extension

**Status:** IN_PROGRESS
**Task ID:** SHARE-EXTENSION
**Agent:** Antigravity (Gemini 3 Flash)

## Description

Implementing a native iOS/Android share extension for ExoChess to handle incoming PGN and FEN strings/files.

## Tasks

- [ ] `SHR-01`: Update `AnalysisOptions` in `analysis_controller.dart` to support FEN.
- [ ] `SHR-02`: Handle `AnalysisOptions.fen` in `AnalysisController.build`.
- [ ] `SHR-03`: Run `dart run build_runner build` to regenerate freezed files.
- [ ] `SHR-04`: Update `AndroidManifest.xml` with `SEND` intent filters for text and PGN.
- [ ] `SHR-05`: Update `Info.plist` with PGN/FEN document types.
- [ ] `SHR-06`: Refactor `ImportPgnScreen.handlePgnText` to `handleIncomingChessData`.
- [ ] `SHR-07`: Implement text sharing intent handling in `lib/src/app.dart`.
- [ ] `SHR-08`: Verify with `flutter analyze` and existing tests.

## Files to Change

- `lib/src/model/analysis/analysis_controller.dart`
- `android/app/src/main/AndroidManifest.xml`
- `ios/Runner/Info.plist`
- `lib/src/view/more/import_pgn_screen.dart`
- `lib/src/app.dart`

