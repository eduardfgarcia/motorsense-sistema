import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NeuroFitTheme {
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF050505),
    primaryColor: const Color(0xFF007AFF),
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF007AFF),
      secondary: Color(0xFF004080),
      surface: Colors.transparent,
    ),
    cardTheme: CardThemeData(
      // <-- Cambiado de CardTheme a CardThemeData
      color: Colors.white
          .withValues(alpha: 0.05), // <-- Actualizado para evitar el warning
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
            color: Colors.white
                .withValues(alpha: 0.1)), // Borde sutil para Glassmorphism
      ),
      elevation: 0,
    ),
    textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
      headlineLarge: const TextStyle(
          fontSize: 32, fontWeight: FontWeight.w800, color: Colors.white),
      bodyLarge: const TextStyle(color: Color(0xFFA0A0A0)),
    ),
  );
}
