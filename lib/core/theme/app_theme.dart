import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Tema global. Las pantallas no definen colores ni tamaños de letra propios:
/// los toman de aquí con `Theme.of(context)`.
abstract final class AppTheme {
  static const String fontFamily = 'LibreFranklin';

  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.verdeUpc,
    ).copyWith(
      primary: AppColors.verdeUpc,
      onPrimary: Colors.white,
      secondary: AppColors.verdeHoja,
      onSecondary: Colors.white,
      error: AppColors.error,
      surface: AppColors.superficie,
      onSurface: AppColors.tinta,
      onSurfaceVariant: AppColors.tintaSuave,
      outline: AppColors.borde,
    );

    final base = ThemeData(
      colorScheme: colorScheme,
      fontFamily: fontFamily,
      scaffoldBackgroundColor: AppColors.superficie,
    );

    final buttonShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    );

    return base.copyWith(
      textTheme: _textTheme(base.textTheme),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: buttonShape,
          textStyle: const TextStyle(
            fontFamily: fontFamily,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: buttonShape,
          foregroundColor: AppColors.verdeUpc,
          side: const BorderSide(color: AppColors.borde),
          textStyle: const TextStyle(
            fontFamily: fontFamily,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.verdeUpc,
          textStyle: const TextStyle(
            fontFamily: fontFamily,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static TextTheme _textTheme(TextTheme base) {
    return base.copyWith(
      // Marca "UpcConecta" en la banda superior.
      displaySmall: base.displaySmall?.copyWith(
        fontSize: 42,
        fontWeight: FontWeight.w800,
        letterSpacing: -1.2,
        height: 1.0,
      ),
      // Título de cada pantalla ("Inicia sesión", "Crea tu cuenta").
      headlineSmall: base.headlineSmall?.copyWith(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.4,
        color: AppColors.tinta,
      ),
      titleMedium: base.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: AppColors.tinta,
      ),
      bodyLarge: base.bodyLarge?.copyWith(
        fontSize: 16,
        height: 1.45,
        color: AppColors.tinta,
      ),
      bodyMedium: base.bodyMedium?.copyWith(
        fontSize: 14,
        height: 1.45,
        color: AppColors.tintaSuave,
      ),
    );
  }
}
