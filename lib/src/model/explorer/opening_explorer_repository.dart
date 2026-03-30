import 'dart:async';

import 'package:dartchess/dartchess.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart';
import 'package:chessigma_mobile/src/constants.dart';
import 'package:chessigma_mobile/src/model/common/speed.dart';
import 'package:chessigma_mobile/src/model/explorer/opening_explorer.dart';
import 'package:chessigma_mobile/src/model/explorer/opening_explorer_preferences.dart';
import 'package:chessigma_mobile/src/model/explorer/chessdb_client.dart';
import 'package:chessigma_mobile/src/network/http.dart';
import 'package:chessigma_mobile/src/utils/riverpod.dart';

final openingExplorerProvider = AsyncNotifierProvider.autoDispose
    .family<OpeningExplorer, ({OpeningExplorerEntry entry, bool isIndexing})?, String>(
      OpeningExplorer.new,
      name: 'OpeningExplorerProvider',
    );

final chessDBClientProvider = Provider<ChessDBClient>((ref) => ChessDBClient());

class OpeningExplorer extends AsyncNotifier<({OpeningExplorerEntry entry, bool isIndexing})?> {
  OpeningExplorer(this.fen);
  final String fen;

  StreamSubscription<OpeningExplorerEntry>? _openingExplorerSubscription;

  @override
  Future<({OpeningExplorerEntry entry, bool isIndexing})?> build() async {
    ref.onDispose(() {
      _openingExplorerSubscription?.cancel();
    });

    await ref.debounce(const Duration(milliseconds: 300));

    final prefs = ref.watch(openingExplorerPreferencesProvider);
    final repository = ref.read(openingExplorerRepositoryProvider);
    switch (prefs.db) {
      case OpeningDatabase.master:
        final openingExplorer = await repository.getMasterDatabase(
          fen,
          since: prefs.masterDb.sinceYear,
        );
        return (entry: openingExplorer, isIndexing: false);
      case OpeningDatabase.lichess:
        final openingExplorer = await repository.getLichessDatabase(
          fen,
          speeds: prefs.lichessDb.speeds,
          ratings: prefs.lichessDb.ratings,
          since: prefs.lichessDb.since,
        );
        return (entry: openingExplorer, isIndexing: false);
      case OpeningDatabase.player:
        final openingExplorerStream = await repository.getPlayerDatabase(
          fen,
          // null check handled by widget
          usernameOrId: prefs.playerDb.username!,
          color: prefs.playerDb.side,
          speeds: prefs.playerDb.speeds,
          gameModes: prefs.playerDb.gameModes,
          since: prefs.playerDb.since,
        );

        _openingExplorerSubscription = openingExplorerStream.listen(
          (openingExplorer) => state = AsyncValue.data((entry: openingExplorer, isIndexing: true)),
          onDone: () => state.value != null
              ? state = AsyncValue.data((entry: state.value!.entry, isIndexing: false))
              : state = AsyncValue.error(
                  'No opening explorer data returned for player ${prefs.playerDb.username}',
                  StackTrace.current,
                ),
        );
        return null;
      case OpeningDatabase.chessdb:
        final openingExplorer = await repository.getChessDB(fen);
        return (entry: openingExplorer, isIndexing: false);
    }
  }
}

/// A provider for [OpeningExplorerRepository].
final openingExplorerRepositoryProvider = Provider<OpeningExplorerRepository>((Ref ref) {
  return OpeningExplorerRepository(
    ref.watch(lichessClientProvider),
    ref.watch(chessDBClientProvider),
  );
}, name: 'OpeningExplorerRepositoryProvider');

class OpeningExplorerRepository {
  const OpeningExplorerRepository(this.client, this.chessDBClient);

  final Client client;
  final ChessDBClient chessDBClient;

  Future<OpeningExplorerEntry> getMasterDatabase(String fen, {int? since}) {
    return client.readJson(
      Uri.https(kLichessOpeningExplorerHost, '/masters', {
        'source': 'mobile',
        'fen': fen,
        if (since != null) 'since': since.toString(),
      }),
      mapper: OpeningExplorerEntry.fromJson,
    );
  }

  Future<OpeningExplorerEntry> getLichessDatabase(
    String fen, {
    required ISet<Speed> speeds,
    required ISet<int> ratings,
    DateTime? since,
  }) {
    return client.readJson(
      Uri.https(kLichessOpeningExplorerHost, '/lichess', {
        'source': 'mobile',
        'fen': fen,
        if (speeds.isNotEmpty) 'speeds': speeds.map((speed) => speed.name).join(','),
        if (ratings.isNotEmpty) 'ratings': ratings.join(','),
        if (since != null) 'since': '${since.year}-${since.month}',
      }),
      mapper: OpeningExplorerEntry.fromJson,
    );
  }

  Future<Stream<OpeningExplorerEntry>> getPlayerDatabase(
    String fen, {
    required String usernameOrId,
    required Side color,
    required ISet<Speed> speeds,
    required ISet<GameMode> gameModes,
    DateTime? since,
  }) {
    return client.readNdJsonStream(
      Uri.https(kLichessOpeningExplorerHost, '/player', {
        'source': 'mobile',
        'fen': fen,
        'player': usernameOrId,
        'color': color.name,
        if (speeds.isNotEmpty) 'speeds': speeds.map((speed) => speed.name).join(','),
        if (gameModes.isNotEmpty) 'modes': gameModes.map((gameMode) => gameMode.name).join(','),
        if (since != null) 'since': '${since.year}-${since.month}',
      }),
      mapper: OpeningExplorerEntry.fromJson,
    );
  }

  Future<OpeningExplorerEntry> getChessDB(String fen) async {
    final response = await chessDBClient.queryAll(fen);

    if (response.startsWith('unknown')) {
      return OpeningExplorerEntry.empty();
    }

    final moves = response.split('|').map((moveStr) {
      // move:e2e4,score:31,rank:0,winrate:50.0,count:14972,note:?
      final parts = moveStr.split(',');
      final data = <String, String>{};
      for (final part in parts) {
        final kv = part.split(':');
        if (kv.length == 2) {
          data[kv[0]] = kv[1];
        }
      }

      final uci = data['move'] ?? '';
      // Remove piece prefix if present (e.g. Pe2e4 -> e2e4)
      final cleanUci = uci.length > 4 ? uci.substring(uci.length - 4) : uci;
      final score = int.tryParse(data['score'] ?? '');
      int.tryParse(data['count'] ?? '') ?? 0;

      return OpeningMove(
        uci: cleanUci,
        san: cleanUci, // Will be updated by chessground/dartchess later if needed
        white: 0,
        draws: 0,
        black: 0,
        score: score,
        // We use winrate/count to fake the stats bar if needed, 
        // but ChessDB is more for evaluation than statistics.
      );
    }).toIList();

    return OpeningExplorerEntry(
      white: 0,
      draws: 0,
      black: 0,
      moves: moves,
    );
  }
}
