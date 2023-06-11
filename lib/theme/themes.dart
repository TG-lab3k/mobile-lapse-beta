import 'package:flutter/material.dart';

class Themes {
  static const int _primaryValue = 0xFFFAFAFA;

  static const MaterialColor lapsePrimarySwatch = MaterialColor(
    _primaryValue,
    <int, Color>{
      50: Color(0xFFFAFAFA),
      100: Color(0xFFF5F5F5),
      200: Color(0xFFEEEEEE),
      300: Color(0xFFE0E0E0),
      350: Color(0xFFD6D6D6),
      // only for raised button while pressed in light theme
      400: Color(0xFFBDBDBD),
      500: Color(_primaryValue),
      600: Color(0xFF757575),
      700: Color(0xFF616161),
      800: Color(0xFF424242),
      850: Color(0xFF303030),
      // only for background color in dark theme
      900: Color(0xFF212121),
    },
  );

  static final ThemeData lapseTheme = ThemeData(
    primarySwatch: lapsePrimarySwatch,
    brightness: Brightness.light,
  );
}
