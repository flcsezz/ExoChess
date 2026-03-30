# Current Task

**Status:** COMPLETED
**Task ID:** Opening Explorer & Startup FIX

## Description

Stabilized the application startup and restored the Opening Explorer functionality.

## Fixes Applied

1. **Splash Screen Recovery**: Deleted the crash-prone `ChessigmaSplashScreen` and transitioned to `flutter_native_splash`. Implemented a 500ms `FadeTransition` for smooth app entry.
2. **Branding Correction**: Replaced the white-box logo with a high-quality transparent version (`chessigma-logo-new.png`) in the app bar.
3. **Opening Explorer Restoration**: Integrated **ChessDB.cn** as an unauthenticated alternative to the restricted Lichess API.
   - Added support for engine evaluations (CP score).
   - Updated UI table for score visualization.
   - Defaulted to ChessDB for immediate functionality.

## Blockers

- None.
