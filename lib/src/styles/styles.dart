import 'package:dynamic_system_colors/dynamic_system_colors.dart';
import 'package:flutter/material.dart';
import 'package:chessigma_mobile/src/styles/chessigma_colors.dart';

// ignore: avoid_classes_with_only_static_members
abstract class Styles {
  // text
  static const bold = TextStyle(fontWeight: FontWeight.bold);
  static const title = TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold);
  static const subtitle = TextStyle(fontSize: 16, fontWeight: FontWeight.w500);
  static const callout = TextStyle(fontSize: 18, fontWeight: FontWeight.w600);
  static const mainListTileTitle = TextStyle(fontSize: 18, fontWeight: FontWeight.w500);
  static const sectionTitle = TextStyle(fontSize: 18, fontWeight: FontWeight.bold);
  static const boardPreviewTitle = TextStyle(fontSize: 16, fontWeight: FontWeight.bold);
  static const subtitleOpacity = 0.7;
  static const timeControl = TextStyle(letterSpacing: 1.2);
  static const formLabel = TextStyle(fontWeight: FontWeight.bold);
  static const formError = TextStyle(color: ChessigmaColors.red);
  static const formDescription = TextStyle(fontSize: 12);
  static const linkStyle = TextStyle(color: Color(0xFFE8B84B), decoration: TextDecoration.none);
  static const noResultTextStyle = TextStyle(color: Colors.grey, fontSize: 20.0);

  // padding
  static const bodyPadding = EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0);
  static const verticalBodyPadding = EdgeInsets.symmetric(vertical: 16.0);
  static const horizontalBodyPadding = EdgeInsets.symmetric(horizontal: 16.0);
  static const sectionBottomPadding = EdgeInsets.only(bottom: 16.0);
  static const sectionTopPadding = EdgeInsets.only(top: 16.0);
  static const bodySectionPadding = EdgeInsets.all(16.0);

  /// Horizontal and bottom padding for the body section.
  static const bodySectionBottomPadding = EdgeInsets.only(bottom: 16.0, left: 16.0, right: 16.0);

  // cards
  static const cardBorderRadius = BorderRadius.all(Radius.circular(12.0));

  // boards
  static const boardBorderRadius = BorderRadius.all(Radius.circular(5.0));

  static const thumbnailBorderRadius = BorderRadius.all(Radius.circular(5.0));

  static Color chartColor(BuildContext context) {
    return ColorScheme.of(context).tertiary;
  }
}

/// Retrieve the default text color and apply an opacity to it.
Color? textShade(BuildContext context, double opacity) =>
    DefaultTextStyle.of(context).style.color?.withValues(alpha: opacity);

Color darken(Color c, [double amount = .1]) {
  assert(amount >= 0 && amount <= 1);
  return Color.lerp(c, Colors.black, amount) ?? c;
}

Color lighten(Color c, [double amount = .1]) {
  assert(amount >= 0 && amount <= 1);
  return Color.lerp(c, Colors.white, amount) ?? c;
}

@immutable
class LichessCustomColors extends ThemeExtension<LichessCustomColors> {
  const LichessCustomColors({
    required this.cyan,
    required this.brag,
    required this.good,
    required this.error,
    required this.fancy,
    required this.purple,
    required this.primary,
    required this.neonBlue,
    required this.neonPurple,
    required this.neonPink,
    required this.neonGreen,
    required this.voidBlack,
    required this.voidIndigo,
    required this.voidBackgroundLighter,
  });

  final Color cyan;
  final Color brag;
  final Color good;
  final Color error;
  final Color fancy;
  final Color purple;
  final Color primary;
  final Color neonBlue;
  final Color neonPurple;
  final Color neonPink;
  final Color neonGreen;
  final Color voidBlack;
  final Color voidIndigo;
  final Color voidBackgroundLighter;

  @override
  LichessCustomColors copyWith({
    Color? cyan,
    Color? brag,
    Color? good,
    Color? error,
    Color? fancy,
    Color? purple,
    Color? primary,
    Color? neonBlue,
    Color? neonPurple,
    Color? neonPink,
    Color? neonGreen,
    Color? voidBlack,
    Color? voidIndigo,
    Color? voidBackgroundLighter,
  }) {
    return LichessCustomColors(
      cyan: cyan ?? this.cyan,
      brag: brag ?? this.brag,
      good: good ?? this.good,
      error: error ?? this.error,
      fancy: fancy ?? this.fancy,
      purple: purple ?? this.purple,
      primary: primary ?? this.primary,
      neonBlue: neonBlue ?? this.neonBlue,
      neonPurple: neonPurple ?? this.neonPurple,
      neonPink: neonPink ?? this.neonPink,
      neonGreen: neonGreen ?? this.neonGreen,
      voidBlack: voidBlack ?? this.voidBlack,
      voidIndigo: voidIndigo ?? this.voidIndigo,
      voidBackgroundLighter: voidBackgroundLighter ?? this.voidBackgroundLighter,
    );
  }

  @override
  LichessCustomColors lerp(ThemeExtension<LichessCustomColors>? other, double t) {
    if (other is! LichessCustomColors) {
      return this;
    }
    return LichessCustomColors(
      cyan: Color.lerp(cyan, other.cyan, t) ?? cyan,
      brag: Color.lerp(brag, other.brag, t) ?? brag,
      good: Color.lerp(good, other.good, t) ?? good,
      error: Color.lerp(error, other.error, t) ?? error,
      fancy: Color.lerp(fancy, other.fancy, t) ?? fancy,
      purple: Color.lerp(purple, other.purple, t) ?? purple,
      primary: Color.lerp(primary, other.primary, t) ?? primary,
      neonBlue: Color.lerp(neonBlue, other.neonBlue, t) ?? neonBlue,
      neonPurple: Color.lerp(neonPurple, other.neonPurple, t) ?? neonPurple,
      neonPink: Color.lerp(neonPink, other.neonPink, t) ?? neonPink,
      neonGreen: Color.lerp(neonGreen, other.neonGreen, t) ?? neonGreen,
      voidBlack: Color.lerp(voidBlack, other.voidBlack, t) ?? voidBlack,
      voidIndigo: Color.lerp(voidIndigo, other.voidIndigo, t) ?? voidIndigo,
      voidBackgroundLighter: Color.lerp(voidBackgroundLighter, other.voidBackgroundLighter, t) ?? voidBackgroundLighter,
    );
  }

  LichessCustomColors harmonized(ColorScheme colorScheme) {
    return copyWith(
      cyan: cyan.harmonizeWith(colorScheme.primary),
      brag: brag.harmonizeWith(colorScheme.primary),
      good: good.harmonizeWith(colorScheme.primary),
      error: error.harmonizeWith(colorScheme.primary),
      fancy: fancy.harmonizeWith(colorScheme.primary),
      purple: purple.harmonizeWith(colorScheme.primary),
      primary: primary.harmonizeWith(colorScheme.primary),
    );
  }
}

const lichessCustomColors = LichessCustomColors(
  cyan: ChessigmaColors.cyan,
  brag: ChessigmaColors.brag,
  good: ChessigmaColors.good,
  error: ChessigmaColors.error,
  fancy: ChessigmaColors.fancy,
  purple: ChessigmaColors.purple,
  primary: Color(0xFFE8B84B),
  neonBlue: ChessigmaColors.neonBlue,
  neonPurple: ChessigmaColors.neonPurple,
  neonPink: ChessigmaColors.neonPink,
  neonGreen: ChessigmaColors.neonGreen,
  voidBlack: ChessigmaColors.voidBlack,
  voidIndigo: ChessigmaColors.voidIndigo,
  voidBackgroundLighter: ChessigmaColors.voidBackgroundLighter,
);

extension CustomColorsBuildContext on BuildContext {
  LichessCustomColors get chessigmaColors =>
      Theme.of(this).extension<LichessCustomColors>() ?? lichessCustomColors;
}
