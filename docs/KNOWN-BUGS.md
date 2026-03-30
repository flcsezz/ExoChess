# Known Bugs and Technical Debt

## 1. WebSocket URI Construction Error (:0 Port) [FIXED]
- **Symptoms:** Logs showing `WebSocket connection failed: WebSocketException: Connection to 'https://socket.lichess.org:0/analysis/socket/v5#' was not upgraded to websocket`.
- **Cause:** Dart's `Uri.port` defaults to 0 for `ws` and `wss` schemes, which caused connection failures.
- **Fix:** Refactored `lichessWSUri` in `lib/src/network/socket.dart` to explicitly set ports to 443 (wss) or 80 (ws) and ensured fragments are stripped.

## 2. Database Locking Warnings [FIXED]
- **Symptoms:** Repeated warnings `Warning database has been locked for 0:00:10.000000. Make sure you always use the transaction object for database operations during a transaction`.
- **Cause:** Concurrent database transactions from multiple `BufferedWriter` instances and potential re-entrant flushes.
- **Fix:** 
    - Improved `BufferedWriter` in `lib/src/db/buffered_writer.dart` with an `_isFlushing` flag and robust scheduling.
    - Centralized `BufferedWriter` via a shared `bufferedWriterProvider` in `lib/src/db/database.dart`.
    - Refactored `AppLogStorage` and `HttpLogStorage` to use the shared writer.

## 3. Analysis Board Performance Risks
- **Symptoms:** Review opens slowly, move feedback appears late, or loading states flicker when a game is large.
- **Cause:** Engine analysis, board annotations, and cache warmup can all compete for the first render if they are not separated cleanly.
- **Guardrails:** Key the analysis cache by game identity, source, variant, and engine depth; keep board rendering independent from the first Stockfish pass; and make loading / retry states explicit.
