import 'package:flutter/material.dart';

class AppTheme {
  static const driverGreen = Color(0xFF10B981);
  static const dark        = Color(0xFF0A0A0F);
  static const dark2       = Color(0xFF13131A);
  static const card        = Color(0xFF1C1C28);
  static const border      = Color(0xFF2A2A3A);
  static const textMuted   = Color(0xFF8B8BA0);

  static ThemeData driverTheme() => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: dark,
    colorScheme: const ColorScheme.dark(
      primary: driverGreen,
      surface: dark2,
      onSurface: Colors.white,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: dark2,
      indicatorColor: Color.fromRGBO(16, 185, 129, 0.2),
      iconTheme: WidgetStateProperty.resolveWith((s) =>
          IconThemeData(color: s.contains(WidgetState.selected) ? driverGreen : textMuted)),
      labelTextStyle: WidgetStateProperty.resolveWith((s) =>
          TextStyle(color: s.contains(WidgetState.selected) ? driverGreen : textMuted,
              fontSize: 11, fontWeight: FontWeight.w600)),
    ),
    cardTheme: const CardThemeData(
      color: card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16)),
          side: BorderSide(color: border)),
      elevation: 0,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: dark2,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white),
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white),
      headlineMedium: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white),
      bodyLarge: TextStyle(fontSize: 15, color: Colors.white),
      bodyMedium: TextStyle(fontSize: 13, color: textMuted),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: driverGreen,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
      ),
    ),
  );
}
