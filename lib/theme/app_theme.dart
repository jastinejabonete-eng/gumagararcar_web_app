import 'package:flutter/material.dart';

abstract final class AppTheme {
  static const petrol = Color(0xFF13363B);
  static const blue = Color(0xFF245BDD);
  static const frost = Color(0xFFF2F5F5);

  static ThemeData theme(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    final scheme = ColorScheme.fromSeed(
      seedColor: blue,
      brightness: brightness,
      primary: dark ? const Color(0xFFABC4FF) : blue,
      surface: dark ? const Color(0xFF132125) : Colors.white,
      onSurface: dark ? const Color(0xFFECF2F3) : const Color(0xFF152B31),
      onSurfaceVariant: dark
          ? const Color(0xFFB5C5C9)
          : const Color(0xFF52666D),
      outlineVariant: dark ? const Color(0xFF35484F) : const Color(0xFFD7E0E3),
    );
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      fontFamily: 'Barlow',
    );
    return base.copyWith(
      scaffoldBackgroundColor: dark ? const Color(0xFF0C171B) : frost,
      textTheme: base.textTheme
          .copyWith(
            displayLarge: const TextStyle(
              fontFamily: 'BarlowCondensed',
              fontWeight: FontWeight.w600,
              fontSize: 76,
              height: 0.98,
            ),
            displayMedium: const TextStyle(
              fontFamily: 'BarlowCondensed',
              fontWeight: FontWeight.w600,
              fontSize: 56,
              height: 1.02,
            ),
            headlineLarge: const TextStyle(
              fontFamily: 'BarlowCondensed',
              fontWeight: FontWeight.w600,
              fontSize: 42,
              height: 1.1,
            ),
            headlineMedium: const TextStyle(
              fontFamily: 'BarlowCondensed',
              fontWeight: FontWeight.w600,
              fontSize: 32,
              height: 1.15,
            ),
            titleLarge: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 22,
              height: 1.2,
            ),
            bodyLarge: const TextStyle(fontSize: 16, height: 1.5),
            bodyMedium: const TextStyle(fontSize: 14, height: 1.45),
          )
          .apply(bodyColor: scheme.onSurface, displayColor: scheme.onSurface),
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 50),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          textStyle: const TextStyle(
            fontFamily: 'Barlow',
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(48, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(48, 48),
          textStyle: const TextStyle(
            fontFamily: 'Barlow',
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(minimumSize: const Size(48, 48)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surface,
        indicatorColor: dark
            ? const Color(0xFF263F54)
            : const Color(0xFFE0E9FC),
        height: 72,
        labelTextStyle: const WidgetStatePropertyAll(
          TextStyle(
            fontFamily: 'Barlow',
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: dark ? const Color(0xFFE5EFF2) : petrol,
        contentTextStyle: TextStyle(
          color: dark ? petrol : Colors.white,
          fontFamily: 'Barlow',
        ),
      ),
    );
  }
}
