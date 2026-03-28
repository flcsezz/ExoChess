import 'dart:async';
import 'dart:convert';

import 'package:chessigma_mobile/src/model/common/chess.dart';
import 'package:chessigma_mobile/src/model/common/id.dart';
import 'package:chessigma_mobile/src/model/common/perf.dart';
import 'package:chessigma_mobile/src/model/common/speed.dart';
import 'package:chessigma_mobile/src/model/external_history/external_history.dart';
import 'package:chessigma_mobile/src/model/external_history/external_history_storage.dart';
import 'package:chessigma_mobile/src/model/game/game_status.dart';
import 'package:chessigma_mobile/src/model/game/exported_game.dart';
import 'package:chessigma_mobile/src/network/http.dart';
import 'package:chessigma_mobile/src/utils/riverpod.dart';
import 'package:dartchess/dartchess.dart' hide Variant;
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' show Client;

final allExternalRecentGamesProvider = FutureProvider.autoDispose<List<ExternalGameHistoryItem>>((
  ref,
) {
  final storage = ref.watch(externalHistoryStorageProvider);
  return storage.fetchAllRecent(limit: 10);
});

final lichessRecentGamesProvider = FutureProvider.autoDispose<List<ExternalGameHistoryItem>>((ref) {
  final storage = ref.watch(externalHistoryStorageProvider);
  return storage.fetchRecentBySource(ExternalSource.lichess, limit: 10);
});

final chesscomRecentGamesProvider = FutureProvider.autoDispose<List<ExternalGameHistoryItem>>((
  ref,
) {
  final storage = ref.watch(externalHistoryStorageProvider);
  return storage.fetchRecentBySource(ExternalSource.chesscom, limit: 10);
});

final lichessRecentConvertedProvider = FutureProvider.autoDispose<IList<LightExportedGameWithPov>>((
  ref,
) async {
  final games = await ref.watch(lichessRecentGamesProvider.future);
  return games.map((e) => e.toLightExportedGame()).toIList();
});

final chesscomRecentConvertedProvider = FutureProvider.autoDispose<IList<LightExportedGameWithPov>>(
  (ref) async {
    final games = await ref.watch(chesscomRecentGamesProvider.future);
    return games.map((e) => e.toLightExportedGame()).toIList();
  },
);

final externalGameHistoryLocalProvider = FutureProvider.autoDispose
    .family<List<ExternalGameHistoryItem>, ExternalUserHistoryParams>((ref, params) {
      final storage = ref.watch(externalHistoryStorageProvider);
      return storage.fetchHistory(params.source, params.username);
    });

final externalHistoryVersionProvider = StateProvider.family<int, ExternalSource>(
  (ref, source) => 0,
);

final externalGameHistorySourceLocalProvider = FutureProvider.autoDispose
    .family<List<ExternalGameHistoryItem>, ExternalSource>((ref, source) {
      ref.watch(externalHistoryVersionProvider(source));
      final storage = ref.watch(externalHistoryStorageProvider);
      return storage.fetchRecentBySource(source, limit: 15);
    });

ExternalGameHistoryItem _convertPgnGameToExternalItemStatic(
  PgnGame game,
  String searchedUsername,
  String fullPgnText,
  int gameIndex,
) {
  final headers = game.headers;

  final whiteName = headers['White'] ?? '?';
  final blackName = headers['Black'] ?? '?';

  final whiteRating = int.tryParse(headers['WhiteElo'] ?? '');
  final blackRating = int.tryParse(headers['BlackElo'] ?? '');

  final whiteRatingDiff = int.tryParse(headers['WhiteRatingDiff'] ?? '');
  final blackRatingDiff = int.tryParse(headers['BlackRatingDiff'] ?? '');

  final variantStr = headers['Variant'] ?? 'Standard';
  final variant = _parseVariantStatic(variantStr);

  final speedStr = headers['Speed'] ?? 'classical';
  final speed = _parseSpeedStatic(speedStr);

  final perfStr = headers['Perf'] ?? 'Classic';
  final perf = _parsePerfStatic(perfStr);

  final result = headers['Result'] ?? '*';
  final winner = _parseWinnerStatic(result);

  final ratedStr = headers['Rated'] ?? 'false';
  final rated = ratedStr.toLowerCase() == 'true';

  DateTime? createdAt;
  final dateStr = headers['UTCDate'];
  final timeStr = headers['UTCTime'];
  if (dateStr != null) {
    try {
      final dateParts = dateStr.split('.');
      if (dateParts.length == 3) {
        final timeParts = timeStr?.split(':') ?? ['00', '00', '00'];
        createdAt = DateTime.utc(
          int.parse(dateParts[0]), // Year
          int.parse(dateParts[1]), // Month
          int.parse(dateParts[2]), // Day
          timeParts.isNotEmpty ? int.parse(timeParts[0]) : 0,
          timeParts.length > 1 ? int.parse(timeParts[1]) : 0,
          timeParts.length > 2 ? int.parse(timeParts[2]) : 0,
        );
      }
    } catch (_) {}
  }

  ExternalClockData? clock;
  final clockStr = headers['Clock'];
  if (clockStr != null) {
    final clockParts = clockStr.split('+');
    if (clockParts.length == 2) {
      final initialSeconds = int.tryParse(clockParts[0]);
      final incrementSeconds = int.tryParse(clockParts[1]);
      if (initialSeconds != null && incrementSeconds != null) {
        clock = ExternalClockData(
          initial: Duration(seconds: initialSeconds),
          increment: Duration(seconds: incrementSeconds),
        );
      }
    }
  }

  final daysStr = headers['DaysPerTurn'];
  final daysPerTurn = daysStr != null ? int.tryParse(daysStr) : null;

  final eco = headers['ECO'] ?? '';
  final openingName = headers['Opening'] ?? '';
  ExternalLightOpening? opening;
  if (eco.isNotEmpty || openingName.isNotEmpty) {
    opening = ExternalLightOpening(eco: eco, name: openingName);
  }

  final gameId =
      headers['Site']?.replaceAll('https://lichess.org/', '') ??
      headers['Id'] ??
      DateTime.now().millisecondsSinceEpoch.toString();

  final pgn = _extractGamePgnStatic(fullPgnText, gameIndex);

  return ExternalGameHistoryItem(
    source: ExternalSource.lichess,
    username: searchedUsername,
    externalGameId: gameId,
    pgn: pgn,
    players: ExternalGamePlayers(
      white: ExternalPlayer(name: whiteName, rating: whiteRating, ratingDiff: whiteRatingDiff),
      black: ExternalPlayer(name: blackName, rating: blackRating, ratingDiff: blackRatingDiff),
    ),
    createdAt: createdAt ?? DateTime.now(),
    status: _parseGameStatusStatic(result),
    variant: variant,
    speed: speed,
    perf: perf,
    rated: rated,
    winner: winner,
    clock: clock,
    daysPerTurn: daysPerTurn,
    opening: opening,
  );
}

String _extractGamePgnStatic(String fullPgnText, int gameIndex) {
  final games = fullPgnText.split('\n\n[');
  if (gameIndex < games.length) {
    String gamePgn = games[gameIndex].trim();
    if (!gamePgn.startsWith('[') && gameIndex > 0) {
      gamePgn = '[$gamePgn';
    }
    return gamePgn;
  }
  return fullPgnText;
}

Variant _parseVariantStatic(String variantStr) {
  return switch (variantStr.toLowerCase()) {
    'standard' => Variant.standard,
    'chess960' => Variant.chess960,
    'fromposition' => Variant.fromPosition,
    'kingofthehill' => Variant.kingOfTheHill,
    'threecheck' => Variant.threeCheck,
    'antichess' => Variant.antichess,
    'atomic' => Variant.atomic,
    'horde' => Variant.horde,
    'racingkings' => Variant.racingKings,
    'crazyhouse' => Variant.crazyhouse,
    _ => Variant.standard,
  };
}

Speed _parseSpeedStatic(String speedStr) {
  return switch (speedStr.toLowerCase()) {
    'ultrabullet' => Speed.ultraBullet,
    'bullet' => Speed.bullet,
    'blitz' => Speed.blitz,
    'rapid' => Speed.rapid,
    'classical' => Speed.classical,
    'correspondence' => Speed.correspondence,
    _ => Speed.classical,
  };
}

Perf _parsePerfStatic(String perfStr) {
  return switch (perfStr.toLowerCase()) {
    'ultrabullet' => Perf.ultraBullet,
    'bullet' => Perf.bullet,
    'blitz' => Perf.blitz,
    'rapid' => Perf.rapid,
    'classical' => Perf.classical,
    'correspondence' => Perf.correspondence,
    'puzzle' => Perf.puzzle,
    _ => Perf.classical,
  };
}

Side? _parseWinnerStatic(String result) {
  return switch (result) {
    '1-0' => Side.white,
    '0-1' => Side.black,
    _ => null,
  };
}

GameStatus _parseGameStatusStatic(String result) {
  return switch (result) {
    '1-0' => GameStatus.mate,
    '0-1' => GameStatus.mate,
    '1/2-1/2' => GameStatus.draw,
    _ => GameStatus.unknownFinish,
  };
}

final externalUserHistoryProvider = AsyncNotifierProvider.autoDispose
    .family<ExternalUserHistoryNotifier, IList<ExternalGameHistoryItem>, ExternalUserHistoryParams>(
      ExternalUserHistoryNotifier.new,
      name: 'ExternalUserHistoryProvider',
    );

class ExternalUserHistoryNotifier extends AsyncNotifier<IList<ExternalGameHistoryItem>> {
  ExternalUserHistoryNotifier(this.params);

  final ExternalUserHistoryParams params;

  static const _nbPerPage = 20;

  final List<ExternalGameHistoryItem> _games = [];
  bool _hasMore = true;
  bool _hasError = false;

  static const _timeout = Duration(seconds: 6);

  @override
  Future<IList<ExternalGameHistoryItem>> build() async {
    ref.cacheFor(const Duration(minutes: 5));
    ref.onDispose(() {
      _games.clear();
      _hasMore = true;
      _hasError = false;
    });

    final storage = ref.read(externalHistoryStorageProvider);

    // Load local history first to show something immediately
    final localGames = await storage.fetchHistory(params.source, params.username);
    if (localGames.isNotEmpty) {
      _games.addAll(localGames);
      _games.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      // Start fetch in background to update history
      _fetchNewGamesInBackground();
      return _games.toIList();
    }

    // If no local history, we must fetch and wait for it
    return _fetchAndSave();
  }

  Future<void> _fetchNewGamesInBackground() async {
    try {
      final fetchedGames = await _fetchGames(max: _nbPerPage).timeout(_timeout);
      if (fetchedGames.isNotEmpty) {
        final existingIds = _games.map((e) => e.externalGameId).toSet();
        bool changed = false;
        for (final game in fetchedGames) {
          if (!existingIds.contains(game.externalGameId)) {
            _games.add(game);
            changed = true;
          }
        }

        // Always refresh DB for this source on a new fetch to satisfy requirement:
        // "on every fetch from a specific platform deletes that old history from that platform and place new fecthed data"
        _games.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        final storage = ref.read(externalHistoryStorageProvider);
        await storage.deleteAllBySource(params.source);
        for (final game in _games.take(20)) {
          await storage.save(game);
        }
        _invalidateRelatedProviders();

        if (changed) {
          state = AsyncData(_games.toIList());
        }
      }
    } catch (e) {
      debugPrint('Background fetch error: $e');
      final errorStr = e.toString().toLowerCase();
      if (errorStr.contains('user not found') ||
          errorStr.contains('404') ||
          errorStr.contains('not found') ||
          errorStr.contains('rate limit') ||
          errorStr.contains('429')) {
        state = AsyncError(e, StackTrace.current);
      }
    }
  }

  Future<IList<ExternalGameHistoryItem>> _fetchAndSave() async {
    try {
      final fetchedGames = await _fetchGames(max: _nbPerPage).timeout(_timeout);
      _games.addAll(fetchedGames);
      _games.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      _hasMore = fetchedGames.length == _nbPerPage;

      final storage = ref.read(externalHistoryStorageProvider);
      // Clear previous history for this source only
      await storage.deleteAllBySource(params.source);
      for (final game in _games.take(20)) {
        await storage.save(game);
      }
      _invalidateRelatedProviders();
      return _games.toIList();
    } catch (e) {
      _hasError = true;
      final errorStr = e.toString().toLowerCase();
      if (e is TimeoutException ||
          errorStr.contains('user not found') ||
          errorStr.contains('404') ||
          errorStr.contains('not found')) {
        throw Exception('User not found: ${params.username}');
      }
      rethrow;
    }
  }

  void _invalidateRelatedProviders() {
    ref.read(externalHistoryVersionProvider(params.source).notifier).update((s) => s + 1);
    ref.invalidate(externalGameHistoryLocalProvider(params));
    ref.invalidate(allExternalRecentGamesProvider);
    ref.invalidate(lichessRecentGamesProvider);
    ref.invalidate(chesscomRecentGamesProvider);
    // Also invalidate the converted providers used by Home Screen
    ref.invalidate(lichessRecentConvertedProvider);
    ref.invalidate(chesscomRecentConvertedProvider);
  }

  Future<List<ExternalGameHistoryItem>> _fetchGames({int? max, int? untilGameIndex}) async {
    switch (params.source) {
      case ExternalSource.lichess:
        return _fetchLichessGames(params.username, max: max, untilGameIndex: untilGameIndex);
      case ExternalSource.chesscom:
        return _fetchChessComGames(params.username, max: max, untilGameIndex: untilGameIndex);
      case ExternalSource.pgn:
        return []; // PGN games are local-only history, handled elsewhere
    }
  }

  Future<void> getNext() async {
    if (!state.hasValue) return;

    if (!_hasMore || _hasError) return;

    state = const AsyncLoading();

    try {
      final games = await _fetchGames(max: _nbPerPage, untilGameIndex: _games.length - 1);

      if (games.isEmpty) {
        _hasMore = false;
        state = AsyncData(_games.toIList());
        return;
      }

      final existingIds = _games.map((e) => e.externalGameId).toSet();
      for (final game in games) {
        if (!existingIds.contains(game.externalGameId)) {
          _games.add(game);
        }
      }
      _games.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      _hasMore = games.length == _nbPerPage;

      // Save top games to local history
      final storage = ref.read(externalHistoryStorageProvider);
      for (final game in games.take(20)) {
        await storage.save(game);
      }
      _invalidateRelatedProviders();

      state = AsyncData(_games.toIList());
    } catch (e, st) {
      _hasError = true;
      state = AsyncError(e, st);
    }
  }

  Future<List<ExternalGameHistoryItem>> _fetchLichessGames(
    String username, {
    int? max,
    int? untilGameIndex,
  }) async {
    final client = ref.read(defaultClientProvider);

    final queryParams = <String, String>{'max': (max ?? 20).toString()};

    if (untilGameIndex != null && _games.isNotEmpty) {
      // Lichess API 'until' expects a timestamp in milliseconds
      queryParams['until'] = _games.last.createdAt.millisecondsSinceEpoch.toString();
    }

    final uri = Uri.https('lichess.org', '/api/games/user/$username', queryParams);

    final response = await client.get(uri);

    if (response.statusCode == 404) {
      throw Exception('User not found: $username');
    }

    if (response.statusCode == 429) {
      throw Exception('Rate limited. Please try again later.');
    }

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch games: ${response.statusCode}');
    }

    final pgnText = response.body;
    if (pgnText.trim().isEmpty) {
      return [];
    }

    final pgnGames = PgnGame.parseMultiGamePgn(pgnText);

    return pgnGames.asMap().entries.map((entry) {
      final index = entry.key;
      final game = entry.value;
      return _convertPgnGameToExternalItemStatic(game, username, pgnText, index);
    }).toList();
  }

  Future<List<ExternalGameHistoryItem>> _fetchChessComGames(
    String username, {
    int? max,
    int? untilGameIndex,
  }) async {
    final client = ref.read(defaultClientProvider);

    // Chess.com archives API
    final archivesUri = Uri.https('api.chess.com', '/pub/player/$username/games/archives');
    final archivesResponse = await client.get(archivesUri);

    if (archivesResponse.statusCode == 404) {
      throw Exception('User not found: $username');
    }

    if (archivesResponse.statusCode != 200) {
      throw Exception('Failed to fetch archives: ${archivesResponse.statusCode}');
    }

    final archivesData = jsonDecode(archivesResponse.body) as Map<String, dynamic>;
    final archives = List<String>.from(archivesData['archives'] as Iterable? ?? []);

    if (archives.isEmpty) {
      return [];
    }

    // Fetch latest archive
    final latestArchiveUri = Uri.parse(archives.last);
    final gamesResponse = await client.get(latestArchiveUri);

    if (gamesResponse.statusCode != 200) {
      throw Exception('Failed to fetch games from archive: ${gamesResponse.statusCode}');
    }

    final gamesData = jsonDecode(gamesResponse.body) as Map<String, dynamic>;
    final games = List<Map<String, dynamic>>.from(gamesData['games'] as Iterable? ?? []);

    final List<ExternalGameHistoryItem> items = [];
    for (final gameData in games.reversed) {
      final pgn = gameData['pgn'] as String?;
      if (pgn == null) continue;

      final pgnGames = PgnGame.parseMultiGamePgn(pgn);
      if (pgnGames.isEmpty) continue;

      final game = pgnGames.first;
      final headers = game.headers;

      final whiteData = gameData['white'] as Map<String, dynamic>?;
      final blackData = gameData['black'] as Map<String, dynamic>?;
      final whiteName = whiteData?['username'] as String? ?? headers['White'] ?? '?';
      final blackName = blackData?['username'] as String? ?? headers['Black'] ?? '?';
      final result = headers['Result'] ?? '*';

      final whiteRating = whiteData?['rating'] as int? ?? int.tryParse(headers['WhiteElo'] ?? '');
      final blackRating = blackData?['rating'] as int? ?? int.tryParse(headers['BlackElo'] ?? '');

      DateTime? createdAt;
      final dateStr = headers['Date'];
      if (dateStr != null) {
        try {
          final parts = dateStr.split('.');
          if (parts.length == 3) {
            createdAt = DateTime.utc(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
          }
        } catch (_) {}
      }

      final gameId =
          (gameData['url'] as String?)?.split('/').last ??
          DateTime.now().millisecondsSinceEpoch.toString();

      items.add(
        ExternalGameHistoryItem(
          source: ExternalSource.chesscom,
          username: username,
          externalGameId: gameId,
          pgn: pgn,
          players: ExternalGamePlayers(
            white: ExternalPlayer(name: whiteName, rating: whiteRating),
            black: ExternalPlayer(name: blackName, rating: blackRating),
          ),
          createdAt: createdAt ?? DateTime.now(),
          status: _parseGameStatusStatic(result),
          variant: Variant.standard,
          speed: Speed.blitz,
          perf: Perf.blitz,
          rated: headers['Event']?.contains('Rated') ?? true,
          winner: _parseWinnerStatic(result),
        ),
      );

      if (max != null && items.length >= max) break;
    }

    return items;
  }
}

final externalGameDetailsProvider = FutureProvider.autoDispose
    .family<ExternalGameHistoryItem, ExternalGameDetailsParams>((ref, params) {
      final client = ref.read(defaultClientProvider);
      switch (params.source) {
        case ExternalSource.lichess:
          return _fetchLichessGameDetails(client, params.externalGameId);
        case ExternalSource.chesscom:
          return _fetchChessComGameDetails(client, params.externalGameId, params.username);
        case ExternalSource.pgn:
          throw UnimplementedError('Details for PGN games should be fetched from local storage');
      }
    });

Future<ExternalGameHistoryItem> _fetchLichessGameDetails(
  Client client,
  String externalGameId,
) async {
  final uri = Uri.https('lichess.org', '/game/export/$externalGameId');

  final response = await client.get(uri);

  if (response.statusCode == 404) {
    throw Exception('Game not found: $externalGameId');
  }

  if (response.statusCode != 200) {
    throw Exception('Failed to fetch game: ${response.statusCode}');
  }

  final pgnText = response.body;

  final pgnGames = PgnGame.parseMultiGamePgn(pgnText);

  if (pgnGames.isEmpty) {
    throw Exception('No game data found');
  }

  return _convertPgnGameToExternalItemStatic(pgnGames.first, '', pgnText, 0);
}

Future<ExternalGameHistoryItem> _fetchChessComGameDetails(
  Client client,
  String externalGameId,
  String username,
) {
  throw UnimplementedError('Chess.com individual game fetch not implemented. Use archive fetch.');
}

extension ExternalGameHistoryItemAnalysis on ExternalGameHistoryItem {
  PgnAnalysisOptions toAnalysisOptions() {
    final orientation = orientationForUsername(username) ?? Side.white;
    return PgnAnalysisOptions(
      id: analysisId,
      orientation: orientation,
      pgn: pgn,
      variant: variant,
      isComputerAnalysisAllowed: true,
    );
  }
}

class PgnAnalysisOptions {
  final StringId id;
  final Side orientation;
  final String pgn;
  final Variant variant;
  final bool isComputerAnalysisAllowed;

  const PgnAnalysisOptions({
    required this.id,
    required this.orientation,
    required this.pgn,
    required this.variant,
    required this.isComputerAnalysisAllowed,
  });
}
