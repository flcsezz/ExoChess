import 'dart:convert';
import 'package:chessigma_mobile/src/db/database.dart';
import 'package:chessigma_mobile/src/model/external_history/external_history.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';

final externalHistoryStorageProvider = Provider<ExternalHistoryStorage>((ref) {
  return ExternalHistoryStorage(ref);
});

class ExternalHistoryStorage {
  ExternalHistoryStorage(this._ref);

  final Ref _ref;

  Future<Database> get _db => _ref.read(databaseProvider.future);

  Future<void> save(ExternalGameHistoryItem game) async {
    final db = await _db;
    await db.insert(
      'external_game_history',
      {
        'id': game.externalGameId,
        'source': game.source.name,
        'username': game.username.toLowerCase(),
        'lastModified': game.createdAt.toIso8601String(),
        'data': jsonEncode(game.toJson()),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<ExternalGameHistoryItem>> fetchHistory(ExternalSource source, String username) async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.query(
      'external_game_history',
      where: 'source = ? AND username = ?',
      whereArgs: [source.name, username.toLowerCase()],
      orderBy: 'lastModified DESC',
      limit: 20,
    );

    return maps.map((map) {
      return ExternalGameHistoryItem.fromJson(
        jsonDecode(map['data'] as String) as Map<String, dynamic>,
      );
    }).toList();
  }

  Future<ExternalGameHistoryItem?> fetch(String id) async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.query(
      'external_game_history',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;

    final data = jsonDecode(maps.first['data'] as String) as Map<String, dynamic>;
    return ExternalGameHistoryItem.fromJson(data);
  }

  Future<List<ExternalGameHistoryItem>> fetchAllRecent({int limit = 20}) async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.query(
      'external_game_history',
      orderBy: 'lastModified DESC',
      limit: limit,
    );

    return maps.map((map) {
      return ExternalGameHistoryItem.fromJson(
        jsonDecode(map['data'] as String) as Map<String, dynamic>,
      );
    }).toList();
  }

  Future<List<ExternalGameHistoryItem>> fetchRecentBySource(ExternalSource source, {int limit = 20}) async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.query(
      'external_game_history',
      where: 'source = ?',
      whereArgs: [source.name],
      orderBy: 'lastModified DESC',
      limit: limit,
    );

    return maps.map((map) {
      return ExternalGameHistoryItem.fromJson(
        jsonDecode(map['data'] as String) as Map<String, dynamic>,
      );
    }).toList();
  }

  Future<void> deleteAllBySource(ExternalSource source) async {
    final db = await _db;
    await db.delete(
      'external_game_history',
      where: 'source = ?',
      whereArgs: [source.name],
    );
  }
}
