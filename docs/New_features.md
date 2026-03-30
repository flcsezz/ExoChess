# Feature Backlog

The canonical implementation plan for the first item lives in [docs/plans/2026-03-28-analysis-board-intelligence.md](/home/flcsezz/mobile/docs/plans/2026-03-28-analysis-board-intelligence.md).

## 1. Analysis Board Intelligence

When a user opens a game for review:

- Stockfish should start immediately or reuse a warm cache.
- The screen should show a loading state while the first engine pass is warming up.
- Each move should be labeled as best, great, good, inaccuracy, mistake, or blunder.
- The moved piece should show a relevant icon or badge, similar to Chess.com.
- The analysis result should be cached so reopening the same game feels instant.

Implementation notes:

- Use one source-agnostic analysis result contract for PGN import, external history, and future sources.
- Keep the board responsive while analysis is running in the background.
- Derive badges and labels from state, not from ad hoc widget flags.

## 2. Opening Trainer (Spaced Repetition)

Leverage the existing `assets/chess_openings.db` to create an active recall trainer where users can play against the engine specifically within a chosen opening line. This would help users learn opening theory through practice rather than just memorization.

## 3. PGN/FEN Share Extension

Implement a native iOS/Android share extension. This allows users to share PGN or FEN strings from external sources directly into the application's analysis board, making it easier to analyze games on the go.

## 6. Optional polish ideas

- Add an analysis summary panel with a best-line preview.
- Add a depth or cache-status indicator for the review screen.
- Add a user setting for how dense move annotations should be.
