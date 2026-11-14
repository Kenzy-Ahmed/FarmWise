import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color lightBg = Color(0xFFF3F1EA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightInk = Color(0xFF1C2A22);
  static const Color lightMuted = Color(0xFF5D6B62);
  static const Color lightFg = Color(0xFF1F3D2C);
  static const Color lightSg2 = Color(0xFFE3EBDF);
  static const Color lightBorder = Color(0xFFDFDFD3);

  static const Color darkBg = Color(0xFF121A15);
  static const Color darkSurface = Color(0xFF1A251E);
  static const Color darkInk = Color(0xFFE8EEE9);
  static const Color darkMuted = Color(0xFF9AAB9F);
  static const Color darkFg = Color(0xFF8FC3A0);
  static const Color darkSg2 = Color(0xFF223028);
  static const Color darkBorder = Color(0xFF2E3D33);

  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: lightBg,
    cardColor: lightSurface,
    colorScheme: const ColorScheme.light(
      primary: lightFg,
      surface: lightSurface,
      onSurface: lightInk,
    ),
    textTheme: TextTheme(
      headlineMedium: GoogleFonts.bricolageGrotesque(fontSize: 26, fontWeight: FontWeight.bold, color: lightInk),
      bodyMedium: GoogleFonts.publicSans(fontSize: 15, color: lightInk),
      bodySmall: GoogleFonts.publicSans(fontSize: 13, color: lightMuted),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: darkBg,
    cardColor: darkSurface,
    colorScheme: const ColorScheme.dark(
      primary: darkFg,
      surface: darkSurface,
      onSurface: darkInk,
    ),
    textTheme: TextTheme(
      headlineMedium: GoogleFonts.bricolageGrotesque(fontSize: 26, fontWeight: FontWeight.bold, color: darkInk),
      bodyMedium: GoogleFonts.publicSans(fontSize: 15, color: darkInk),
      bodySmall: GoogleFonts.publicSans(fontSize: 13, color: darkInk),
    ),
  );
}