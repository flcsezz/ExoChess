import 'package:deep_pick/deep_pick.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/widgets.dart';
import 'package:exochess_mobile/src/styles/exochess_icons.dart';

enum TvChannel {
  best('Top Rated', ExoChessIcons.crown),
  bullet('Bullet', ExoChessIcons.bullet),
  blitz('Blitz', ExoChessIcons.blitz),
  rapid('Rapid', ExoChessIcons.rapid),
  classical('Classical', ExoChessIcons.classical),
  chess960('Chess960', ExoChessIcons.die_six),
  kingOfTheHill('King of the Hill', ExoChessIcons.flag),
  threeCheck('Three Check', ExoChessIcons.three_check),
  antichess('Antichess', ExoChessIcons.antichess),
  atomic('Atomic', ExoChessIcons.atom),
  horde('Horde', ExoChessIcons.horde),
  racingKings('Racing Kings', ExoChessIcons.racing_kings),
  crazyhouse('Crazyhouse', ExoChessIcons.h_square),
  ultraBullet('UltraBullet', ExoChessIcons.ultrabullet),
  bot('Bot', ExoChessIcons.cogs),
  computer('Computer', ExoChessIcons.cogs);

  const TvChannel(this.label, this.icon);

  final String label;
  final IconData icon;

  static final IMap<String, TvChannel> nameMap = IMap(TvChannel.values.asNameMap());
}

extension TvChannelExtension on Pick {
  TvChannel asTvChannelOrThrow() {
    final value = this.required().value;
    if (value is TvChannel) {
      return value;
    }
    if (value is String) {
      if (TvChannel.nameMap.containsKey(value)) {
        return TvChannel.nameMap[value]!;
      }
    }
    throw PickException("value $value at $debugParsingExit can't be casted to TvChannel");
  }

  TvChannel? asTvChannelOrNull() {
    if (value == null) return null;
    try {
      return asTvChannelOrThrow();
    } catch (_) {
      return null;
    }
  }
}
