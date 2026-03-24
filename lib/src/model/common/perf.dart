import 'package:deep_pick/deep_pick.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/widgets.dart';
import 'package:chessigma_mobile/src/model/common/chess.dart';
import 'package:chessigma_mobile/src/model/common/speed.dart';
import 'package:chessigma_mobile/src/styles/chessigma_icons.dart';

/// Represents a lichess rating perf item
enum Perf {
  ultraBullet('UltraBullet', 'Ultra', ChessigmaIcons.ultrabullet),
  bullet('Bullet', 'Bullet', ChessigmaIcons.bullet),
  blitz('Blitz', 'Blitz', ChessigmaIcons.blitz),
  rapid('Rapid', 'Rapid', ChessigmaIcons.rapid),
  classical('Classical', 'Classical', ChessigmaIcons.classical),
  correspondence('Correspondence', 'Corresp.', ChessigmaIcons.correspondence),
  fromPosition('From Position', 'From Pos.', ChessigmaIcons.feather),
  chess960('Chess960', '960', ChessigmaIcons.die_six),
  antichess('Antichess', 'Antichess', ChessigmaIcons.antichess),
  kingOfTheHill('King of the Hill', 'KotH', ChessigmaIcons.flag),
  threeCheck('Three-check', '3check', ChessigmaIcons.three_check),
  atomic('Atomic', 'Atomic', ChessigmaIcons.atom),
  horde('Horde', 'Horde', ChessigmaIcons.horde),
  racingKings('Racing Kings', 'Racing', ChessigmaIcons.racing_kings),
  crazyhouse('Crazyhouse', 'Crazy', ChessigmaIcons.h_square),
  puzzle('Puzzle', 'Puzzle', ChessigmaIcons.target),
  storm('Storm', 'Storm', ChessigmaIcons.storm),
  streak('Streak', 'Streak', ChessigmaIcons.streak);

  const Perf(this.title, this.shortTitle, this.icon);

  final String title;
  final String shortTitle;
  final IconData icon;

  factory Perf.fromVariantAndSpeed(Variant variant, Speed speed) {
    switch (variant) {
      case Variant.standard:
        switch (speed) {
          case Speed.ultraBullet:
            return Perf.ultraBullet;
          case Speed.bullet:
            return Perf.bullet;
          case Speed.blitz:
            return Perf.blitz;
          case Speed.rapid:
            return Perf.rapid;
          case Speed.classical:
            return Perf.classical;
          case Speed.correspondence:
            return Perf.correspondence;
        }
      case Variant.chess960:
        return Perf.chess960;
      case Variant.fromPosition:
        return Perf.fromPosition;
      case Variant.antichess:
        return Perf.antichess;
      case Variant.kingOfTheHill:
        return Perf.kingOfTheHill;
      case Variant.threeCheck:
        return Perf.threeCheck;
      case Variant.atomic:
        return Perf.atomic;
      case Variant.horde:
        return Perf.horde;
      case Variant.racingKings:
        return Perf.racingKings;
      case Variant.crazyhouse:
        return Perf.crazyhouse;
    }
  }

  static final IMap<String, Perf> nameMap = IMap(Perf.values.asNameMap());
}

String _titleKey(String title) => title.toLowerCase().replaceAll(RegExp('[ -_]'), '');

final IMap<String, Perf> _lowerCaseTitleMap = Perf.nameMap.map(
  (key, value) => MapEntry(_titleKey(value.title), value),
);

extension PerfExtension on Pick {
  Perf asPerfOrThrow() {
    final value = this.required().value;
    if (value is Perf) {
      return value;
    }
    if (value is String) {
      if (Perf.nameMap.containsKey(value)) {
        return Perf.nameMap[value]!;
      }
      // handle lichess api inconsistencies
      final valueKey = _titleKey(value);
      if (_lowerCaseTitleMap.containsKey(valueKey)) {
        return _lowerCaseTitleMap[valueKey]!;
      }
      switch (valueKey) {
        case 'puzzles':
          return Perf.puzzle;
      }
    } else if (value is Map<String, dynamic>) {
      final perf = Perf.nameMap[value['key'] as String];
      if (perf != null) {
        return perf;
      }
    }
    throw PickException("value $value at $debugParsingExit can't be casted to Perf");
  }

  Perf? asPerfOrNull() {
    if (value == null) return null;
    try {
      return asPerfOrThrow();
    } catch (_) {
      return null;
    }
  }
}
