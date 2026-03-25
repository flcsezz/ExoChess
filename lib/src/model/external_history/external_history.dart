import 'package:chessigma_mobile/src/model/common/chess.dart';
import 'package:chessigma_mobile/src/model/common/id.dart';
import 'package:chessigma_mobile/src/model/common/perf.dart';
import 'package:chessigma_mobile/src/model/common/speed.dart';
import 'package:chessigma_mobile/src/model/common/time_increment.dart';
import 'package:chessigma_mobile/src/model/game/game_status.dart';
import 'package:dartchess/dartchess.dart';

enum ExternalSource {
  lichess,
  chesscom;

  String get displayName {
    switch (this) {
      case ExternalSource.lichess:
        return 'Lichess';
      case ExternalSource.chesscom:
        return 'Chess.com';
    }
  }

  String get baseUrl {
    switch (this) {
      case ExternalSource.lichess:
        return 'https://lichess.org';
      case ExternalSource.chesscom:
        return 'https://www.chess.com';
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

  const ExternalGameHistoryItem({
    required this.source,
    required this.username,
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
  });

  String get gameUrl {
    switch (source) {
      case ExternalSource.lichess:
        return '${source.baseUrl}/game/$externalGameId';
      case ExternalSource.chesscom:
        return '${source.baseUrl}/game/live/$externalGameId';
    }
  }

  StringId get analysisId => StringId('${source.name}_${username}_$externalGameId');

  Side? orientationForUsername(String user) {
    final lowerUser = user.toLowerCase();
    if (players.white.name?.toLowerCase() == lowerUser ||
        players.white.name?.toLowerCase() == lowerUser.replaceAll(' ', '')) {
      return Side.white;
    }
    if (players.black.name?.toLowerCase() == lowerUser ||
        players.black.name?.toLowerCase() == lowerUser.replaceAll(' ', '')) {
      return Side.black;
    }
    return null;
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
}

class ExternalLightOpening {
  final String eco;
  final String name;

  const ExternalLightOpening({
    required this.eco,
    required this.name,
  });
}

class ExternalClockData {
  final Duration initial;
  final Duration increment;

  const ExternalClockData({
    required this.initial,
    required this.increment,
  });

  String display() {
    return TimeIncrement(initial.inSeconds, increment.inSeconds).display;
  }
}

class ExternalUserHistoryParams {
  final ExternalSource source;
  final String username;

  const ExternalUserHistoryParams({
    required this.source,
    required this.username,
  });

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

  const ExternalGameDetailsParams({
    required this.source,
    required this.externalGameId,
    required this.username,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExternalUserHistoryParams &&
          runtimeType == other.runtimeType &&
          source == other.source &&
          username == other.username;

  @override
  int get hashCode => source.hashCode ^ externalGameId.hashCode ^ username.hashCode;
}
