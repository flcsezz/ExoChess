import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import 'package:chessigma_mobile/src/db/database.dart';
import 'package:chessigma_mobile/src/model/game/over_the_board_game.dart';

final otbHistoryStorageProvider = Provider<OtbHistoryStorage>((ref) {
  return OtbHistoryStorage(ref);
});

class OtbHistoryStorage {
  OtbHistoryStorage(this._ref);

  final Ref _ref;

  Future<Database> get _db => _ref.read(databaseProvider.future);

  Future<void> save(OverTheBoardGame game) async {
    final db = await _db;
    await db.insert(
      'otb_game_history',
      {
        'id': game.id.value,
        'lastModified': DateTime.now().toIso8601String(),
        'data': jsonEncode(game.toJson()),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<OverTheBoardGame>> fetchHistory() async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.query(
      'otb_game_history',
      orderBy: 'lastModified DESC',
      limit: 10,
    );

    return List.generate(maps.length, (i) {
      return OverTheBoardGame.fromJson(
        jsonDecode(maps[i]['data'] as String) as Map<String, dynamic>,
      );
    });
  }
}
