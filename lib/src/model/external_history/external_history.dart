import 'package:chessigma_mobile/src/model/common/chess.dart';
import 'package:chessigma_mobile/src/model/common/id.dart';
import 'package:chessigma_mobile/src/model/common/perf.dart';
import 'package:chessigma_mobile/src/model/common/speed.dart';
import 'package:chessigma_mobile/src/model/common/time_increment.dart';
import 'package:chessigma_mobile/src/model/game/game_status.dart';
import 'package:chessigma_mobile/src/model/game/exported_game.dart';
import 'package:chessigma_mobile/src/model/game/game.dart';
import 'package:chessigma_mobile/src/model/game/player.dart';
import 'package:dartchess/dartchess.dart' hide Variant;

enum ExternalSource {
  lichess,
  chesscom,
  pgn;

  String get displayName {
    switch (this) {
      case ExternalSource.lichess:
        return 'Lichess';
      case ExternalSource.chesscom:
        return 'Chess.com';
      case ExternalSource.pgn:
        return 'PGN';
    }
  }

  String get baseUrl {
    switch (this) {
      case ExternalSource.lichess:
        return 'https://lichess.org';
      case ExternalSource.chesscom:
        return 'https://www.chess.com';
      case ExternalSource.pgn:
        return '';
    }
  }
}

class ExternalGameHistoryItem {
  final ExternalSource source;
  final String username;
  final String externalGameId;
  final String pgn;
  final ExternalGamePlayers players;
  final DateTime createdAt;
  final GameStatus status;
  final Variant variant;
  final Speed speed;
  final Perf perf;
  final bool rated;
  final Side? winner;
  final ExternalClockData? clock;
  final int? daysPerTurn;
  final String? initialFen;
  final ExternalLightOpening? opening;

  ExternalGameHistoryItem({
    required this.source,
    required String username,
    required this.externalGameId,
    required this.pgn,
    required this.players,
    required this.createdAt,
    required this.status,
    required this.variant,
    required this.speed,
    required this.perf,
    required this.rated,
    this.winner,
    this.clock,
    this.daysPerTurn,
    this.initialFen,
    this.opening,
  }) : username = username.trim().toLowerCase();

  Map<String, dynamic> toJson() {
    return {
      'source': source.name,
      'username': username,
      'externalGameId': externalGameId,
      'pgn': pgn,
      'players': players.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'status': status.name,
      'variant': variant.name,
      'speed': speed.name,
      'perf': perf.name,
      'rated': rated,
      'winner': winner?.name,
      'clock': clock?.toJson(),
      'daysPerTurn': daysPerTurn,
      'initialFen': initialFen,
      'opening': opening?.toJson(),
    };
  }

  factory ExternalGameHistoryItem.fromJson(Map<String, dynamic> json) {
    return ExternalGameHistoryItem(
      source: ExternalSource.values.byName(json['source'] as String),
      username: json['username'] as String,
      externalGameId: json['externalGameId'] as String,
      pgn: json['pgn'] as String,
      players: ExternalGamePlayers.fromJson(json['players'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['createdAt'] as String),
      status: GameStatus.values.byName(json['status'] as String),
      variant: Variant.values.byName(json['variant'] as String),
      speed: Speed.values.byName(json['speed'] as String),
      perf: Perf.values.byName(json['perf'] as String),
      rated: json['rated'] as bool,
      winner: json['winner'] != null ? Side.values.byName(json['winner'] as String) : null,
      clock: json['clock'] != null ? ExternalClockData.fromJson(json['clock'] as Map<String, dynamic>) : null,
      daysPerTurn: json['daysPerTurn'] as int?,
      initialFen: json['initialFen'] as String?,
      opening: json['opening'] != null ? ExternalLightOpening.fromJson(json['opening'] as Map<String, dynamic>) : null,
    );
  }

  LightExportedGameWithPov toLightExportedGame() {
    final pov = orientationForUsername(username) ?? Side.white;
    return (
      game: LightExportedGame(
        id: GameId(externalGameId),
        rated: rated,
        speed: speed,
        perf: perf,
        createdAt: createdAt,
        lastMoveAt: createdAt,
        status: status,
        white: Player(
          name: players.white.name,
          rating: players.white.rating,
          ratingDiff: players.white.ratingDiff,
        ),
        black: Player(
          name: players.black.name,
          rating: players.black.rating,
          ratingDiff: players.black.ratingDiff,
        ),
        variant: variant,
        winner: winner,
        source: source == ExternalSource.lichess ? GameSource.api : GameSource.unknown,
      ),
      pov: pov,
    );
  }

  StringId get analysisId => StringId('${source.name}_${username}_$externalGameId');

  Side? orientationForUsername(String? user) {
    if (user == null || user.isEmpty || user.toLowerCase() == 'anonymous') {
      // If we don't have a specific user, try to find "Me" or a common username
      // For now, return null to let the caller decide or default to white
      return null;
    }

    String normalize(String s) => s.toLowerCase().replaceAll(RegExp('[^a-z0-9]'), '');
    
    final normalizedUser = normalize(user);
    if (normalizedUser.isEmpty) return null;

    final whiteName = normalize(players.white.name ?? '');
    final blackName = normalize(players.black.name ?? '');

    // 1. Exact normalized match
    if (whiteName == normalizedUser) return Side.white;
    if (blackName == normalizedUser) return Side.black;

    // 2. Substring match (user in player name)
    if (normalizedUser.length >= 3) {
      if (whiteName.contains(normalizedUser)) return Side.white;
      if (blackName.contains(normalizedUser)) return Side.black;
    }

    // 3. Reverse substring match (player name in user)
    if (whiteName.length >= 3 && normalizedUser.contains(whiteName)) return Side.white;
    if (blackName.length >= 3 && normalizedUser.contains(blackName)) return Side.black;

    return null;
  }

  static ({GameStatus status, Side? winner}) parseChessComResult(
    String? whiteResult,
    String? blackResult,
  ) {
    if (whiteResult == 'win') return (status: GameStatus.mate, winner: Side.white);
    if (blackResult == 'win') return (status: GameStatus.mate, winner: Side.black);

    final isDraw = const {
      'agreed',
      'stalemate',
      'repetition',
      'insufficient',
      '50move',
      'timeback'
    }.contains(whiteResult) ||
        const {
          'agreed',
          'stalemate',
          'repetition',
          'insufficient',
          '50move',
          'timeback'
        }.contains(blackResult);

    if (isDraw) return (status: GameStatus.draw, winner: null);

    return (status: GameStatus.unknown, winner: null);
  }

  ExternalGameHistoryItem copyWith({
    ExternalSource? source,
    String? username,
    String? externalGameId,
    String? pgn,
    ExternalGamePlayers? players,
    DateTime? createdAt,
    GameStatus? status,
    Variant? variant,
    Speed? speed,
    Perf? perf,
    bool? rated,
    Side? winner,
    ExternalClockData? clock,
    int? daysPerTurn,
    String? initialFen,
    ExternalLightOpening? opening,
  }) {
    return ExternalGameHistoryItem(
      source: source ?? this.source,
      username: username ?? this.username,
      externalGameId: externalGameId ?? this.externalGameId,
      pgn: pgn ?? this.pgn,
      players: players ?? this.players,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      variant: variant ?? this.variant,
      speed: speed ?? this.speed,
      perf: perf ?? this.perf,
      rated: rated ?? this.rated,
      winner: winner ?? this.winner,
      clock: clock ?? this.clock,
      daysPerTurn: daysPerTurn ?? this.daysPerTurn,
      initialFen: initialFen ?? this.initialFen,
      opening: opening ?? this.opening,
    );
  }
}

class ExternalGamePlayers {
  final ExternalPlayer white;
  final ExternalPlayer black;

  const ExternalGamePlayers({
    required this.white,
    required this.black,
  });

  Map<String, dynamic> toJson() => {
    'white': white.toJson(),
    'black': black.toJson(),
  };

  factory ExternalGamePlayers.fromJson(Map<String, dynamic> json) => ExternalGamePlayers(
    white: ExternalPlayer.fromJson(json['white'] as Map<String, dynamic>),
    black: ExternalPlayer.fromJson(json['black'] as Map<String, dynamic>),
  );
}

class ExternalPlayer {
  final String? name;
  final int? rating;
  final int? ratingDiff;

  const ExternalPlayer({
    this.name,
    this.rating,
    this.ratingDiff,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'rating': rating,
    'ratingDiff': ratingDiff,
  };

  factory ExternalPlayer.fromJson(Map<String, dynamic> json) => ExternalPlayer(
    name: json['name'] as String?,
    rating: json['rating'] as int?,
    ratingDiff: json['ratingDiff'] as int?,
  );
}

class ExternalLightOpening {
  final String eco;
  final String name;

  const ExternalLightOpening({
    required this.eco,
    required this.name,
  });

  Map<String, dynamic> toJson() => {
    'eco': eco,
    'name': name,
  };

  factory ExternalLightOpening.fromJson(Map<String, dynamic> json) => ExternalLightOpening(
    eco: json['eco'] as String,
    name: json['name'] as String,
  );
}

class ExternalClockData {
  final Duration initial;
  final Duration increment;

  const ExternalClockData({
    required this.initial,
    required this.increment,
  });

  Map<String, dynamic> toJson() => {
    'initial': initial.inSeconds,
    'increment': increment.inSeconds,
  };

  factory ExternalClockData.fromJson(Map<String, dynamic> json) => ExternalClockData(
    initial: Duration(seconds: json['initial'] as int),
    increment: Duration(seconds: json['increment'] as int),
  );

  String display() {
    return TimeIncrement(initial.inSeconds, increment.inSeconds).display;
  }
}

class ExternalUserHistoryParams {
  final ExternalSource source;
  final String username;

  ExternalUserHistoryParams({
    required this.source,
    required String username,
  }) : username = username.trim().toLowerCase();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExternalUserHistoryParams &&
          runtimeType == other.runtimeType &&
          source == other.source &&
          username == other.username;

  @override
  int get hashCode => source.hashCode ^ username.hashCode;
}

class ExternalGameDetailsParams {
  final ExternalSource source;
  final String externalGameId;
  final String username;

  ExternalGameDetailsParams({
    required this.source,
    required this.externalGameId,
    required String username,
  }) : username = username.trim().toLowerCase();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExternalGameDetailsParams &&
          runtimeType == other.runtimeType &&
          source == other.source &&
          externalGameId == other.externalGameId &&
          username == other.username;

  @override
  int get hashCode => source.hashCode ^ externalGameId.hashCode ^ username.hashCode;
}
