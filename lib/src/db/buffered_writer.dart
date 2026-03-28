import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:logging/logging.dart';

typedef DbOperation = void Function(Batch batch);

/// Buffers database operations and executes them in batches to reduce locking.
class BufferedWriter {
  BufferedWriter(this._db, {this.interval = const Duration(seconds: 2)});

  final Database _db;
  final Duration interval;
  final List<DbOperation> _queue = [];
  Timer? _timer;
  final _logger = Logger('BufferedWriter');

  /// Adds an operation to the buffer.
  void add(DbOperation op) {
    _queue.add(op);
    _timer ??= Timer(interval, _flush);
  }

  /// Flushes all buffered operations in a single transaction.
  Future<void> _flush() async {
    if (_queue.isEmpty) {
      _timer = null;
      return;
    }

    final ops = List<DbOperation>.from(_queue);
    _queue.clear();
    _timer = null;

    try {
      await _db.transaction((txn) async {
        final batch = txn.batch();
        for (final op in ops) {
          op(batch);
        }
        await batch.commit(noResult: true);
      });
    } catch (e, st) {
      _logger.severe('Failed to flush buffered database operations', e, st);
    }
  }

  /// Immediately flushes any pending operations.
  Future<void> dispose() async {
    _timer?.cancel();
    await _flush();
  }
}
