import 'package:flutter/material.dart';

class AppColors {
  // Colores Base
  static const Color primary = Color(0xFF00BCD4);
  static const Color primaryColor = primary;
  static const Color secondary = Color(0xFF9C27B0);
  static const Color secondaryColor = secondary;

  // Colores de Estado (Los que pedía results_page)
  static const Color success = Color(0xFF4CAF50);
  static const Color successColor = success;
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFE53935);
  static const Color errorColor = error;
  static const Color accentColor = Color(0xFFFF6B6B); // El que pedía dashboard

  // Fondos y Superficies
  static const Color background = Color(0xFF0D1B2A);
  static const Color surface = Color(0xFF1a2332);
  static const Color surfaceLight = Color(0xFF252D3D);

  // Textos
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0BEC5);
  static const Color textMuted = Color(0xFF78909C);
  static const Color divider = Color(0xFF37474F);

  // Estados de Botones
  static const Color disabled = Color(0xFF616161);
  static const Color primaryDark = Color(0xFF0097A7);
  static const Color secondaryDark = Color(0xFF6A1B9A);
}

class AppStyles {
  // Espaciados (Los que pedía results_page)
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;

  // Radios de Borde
  static const double radiusMedium = 12.0;
  static const double radiusXL = 24.0;

  // Gradientes
  static const LinearGradient gradientPrimary = LinearGradient(
    colors: [AppColors.primary, Color(0xFF0097A7)],
  );
  static const LinearGradient gradientSecondary = LinearGradient(
    colors: [AppColors.secondary, Color(0xFF6A1B9A)],
  );
  static const LinearGradient gradientAccent = LinearGradient(
    colors: [AppColors.accentColor, Color(0xFFFF9800)],
  );

  // Sombras (Shadow Lists)
  static List<BoxShadow> shadowMediumList = [
    BoxShadow(
        color: Colors.black.withOpacity(0.2),
        blurRadius: 8,
        offset: const Offset(0, 4))
  ];
  static List<BoxShadow> shadowLargeList = [
    BoxShadow(
        color: Colors.black.withOpacity(0.4),
        blurRadius: 16,
        offset: const Offset(0, 8))
  ];
}

class AppTheme {
  // Puentes para compatibilidad
  static const LinearGradient primaryGradient = AppStyles.gradientPrimary;

  // Duraciones
  static const Duration durationFast = Duration(milliseconds: 150);
  static const Duration durationNormal = Duration(milliseconds: 300);
  static const Duration durationSlow = Duration(milliseconds: 500);

  // Sombras
  static const BoxShadow shadowSmall = BoxShadow(
    color: Color(0x1F000000),
    blurRadius: 4,
    offset: Offset(0, 2),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.background,
    primaryColor: AppColors.primary,
    // ... resto de tu configuración de tema
  );
}
