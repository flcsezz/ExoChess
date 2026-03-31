import 'package:deep_pick/deep_pick.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/widgets.dart';
import 'package:exochess_mobile/src/model/common/chess.dart';
import 'package:exochess_mobile/src/model/common/speed.dart';
import 'package:exochess_mobile/src/styles/exochess_icons.dart';

/// Represents a lichess rating perf item
enum Perf {
  ultraBullet('UltraBullet', 'Ultra', ExoChessIcons.ultrabullet),
  bullet('Bullet', 'Bullet', ExoChessIcons.bullet),
  blitz('Blitz', 'Blitz', ExoChessIcons.blitz),
  rapid('Rapid', 'Rapid', ExoChessIcons.rapid),
  classical('Classical', 'Classical', ExoChessIcons.classical),
  correspondence('Correspondence', 'Corresp.', ExoChessIcons.correspondence),
  fromPosition('From Position', 'From Pos.', ExoChessIcons.feather),
  chess960('Chess960', '960', ExoChessIcons.die_six),
  antichess('Antichess', 'Antichess', ExoChessIcons.antichess),
  kingOfTheHill('King of the Hill', 'KotH', ExoChessIcons.flag),
  threeCheck('Three-check', '3check', ExoChessIcons.three_check),
  atomic('Atomic', 'Atomic', ExoChessIcons.atom),
  horde('Horde', 'Horde', ExoChessIcons.horde),
  racingKings('Racing Kings', 'Racing', ExoChessIcons.racing_kings),
  crazyhouse('Crazyhouse', 'Crazy', ExoChessIcons.h_square),
  puzzle('Puzzle', 'Puzzle', ExoChessIcons.target),
  storm('Storm', 'Storm', ExoChessIcons.storm),
  streak('Streak', 'Streak', ExoChessIcons.streak);

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
