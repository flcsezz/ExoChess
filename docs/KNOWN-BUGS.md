# Known Bugs and Technical Debt

## 1. WebSocket URI Construction Error (:0 Port)
- **Symptoms:** Logs showing `WebSocket connection failed: WebSocketException: Connection to 'https://socket.lichess.org:0/analysis/socket/v5#' was not upgraded to websocket`.
- **Cause:** Non-idiomatic manual string splitting of `kLichessWSHost` in `lib/src/network/socket.dart`. If the environment variable lacks a port or is malformed, it defaults to port 0 or causes a `RangeError`.
- **Fix:** Refactor `lichessWSUri` to use `Uri.parse` and provide sensible defaults for host and port.

## 2. Database Locking Warnings
- **Symptoms:** Repeated warnings `Warning database has been locked for 0:00:10.000000. Make sure you always use the transaction object for database operations during a transaction`.
- **Cause:** High-frequency logging of all HTTP requests, responses, and app events to a single SQLite database without using buffered transactions or a serialized write queue.
- **Fix:** Implement a buffered logging service that batches writes into transactions every few seconds and ensures a singleton pattern for database access.
