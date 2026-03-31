import 'package:flutter/material.dart';

class ExoChessColors {
  ExoChessColors._();

  static const Color brandRed = Color(0xFFD71921);

  // primary: red based
  static const MaterialColor primary = MaterialColor(0xFFD71921, <int, Color>{
    50: Color(0xFFF9E7E7),
    100: Color(0xFFF0C2C2),
    200: Color(0xFFE69999),
    300: Color(0xFFDB7070),
    400: Color(0xFFD45252),
    500: Color(0xFFD71921),
    600: Color(0xFFC72E2E),
    700: Color(0xFFC02727),
    800: Color(0xFFB92020),
    900: Color(0xFFAD1414),
  });

  // secondary: grey based for Nothing aesthetic
  static const MaterialColor secondary = MaterialColor(0xFF1B1B1D, <int, Color>{
    50: Color(0xFFF5F5F5),
    100: Color(0xFFE0E0E0),
    200: Color(0xFFBDBDBD),
    300: Color(0xFF9E9E9E),
    400: Color(0xFF757575),
    500: Color(0xFF1B1B1D),
    600: Color(0xFF151517),
    700: Color(0xFF101012),
    800: Color(0xFF0A0A0C),
    900: Color(0xFF000000),
  });

  static const brag = brandRed;
  static const fancy = brandRed;
  static const red = primary;
  static const error = brandRed;
  static const grey = Color(0xCCCCCCCC);
  static const green = Colors.green; // Keep green for success if needed but brandRed is primary
  static const good = Colors.green;

  static const warn = brandRed;

  static const cyan = brandRed;
  static const blue = brandRed;
  static const purple = brandRed;

  // Cyberpunk / Neon Accents
  static const neonBlue = brandRed;
  static const neonPurple = brandRed;
  static const neonPink = brandRed;
  static const neonGreen = brandRed;
  static const neonGold = brandRed;

  // Void Backgrounds
  static const voidBlack = Color(0xFF000000);
  static const voidIndigo = Color(0xFF010206);
  static const voidBackgroundLighter = Color(0xFF0A0E1A);
}
