import 'package:flutter/material.dart';

class AppTheme {
  static const brand      = Color(0xFFFF6B2B);
  static const dark       = Color(0xFF0A0A0F);
  static const dark2     = Color(0xFF13131A);
  static const dark3     = Color(0xFF242838);
  static const card       = Color(0xFF1C1C28);
  static const border     = Color(0xFF2A2A3A);
  static const textMuted  = Color(0xFF8B8BA0);
  static const green      = Color(0xFF22C55E);
  static const blue       = Color(0xFF3B82F6);
  static const yellow     = Color(0xFFF59E0B);

  static ThemeData advertiserTheme() => ThemeData(
    useMaterial3: true, brightness: Brightness.dark,
    scaffoldBackgroundColor: dark,
    colorScheme: const ColorScheme.dark(primary: brand, surface: dark2, onSurface: Colors.white),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: dark2,
      indicatorColor: const Color.fromRGBO(255, 107, 43, 0.2),
      iconTheme: WidgetStateProperty.resolveWith((s) =>
          IconThemeData(color: s.contains(WidgetState.selected) ? brand : textMuted)),
      labelTextStyle: WidgetStateProperty.resolveWith((s) =>
          TextStyle(color: s.contains(WidgetState.selected) ? brand : textMuted, fontSize: 11, fontWeight: FontWeight.w600)),
    ),
    cardTheme: const CardThemeData(
      color: card, elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16)), side: BorderSide(color: border)),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: dark2, elevation: 0, centerTitle: false,
      titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(style: ElevatedButton.styleFrom(
      backgroundColor: brand, foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
      textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
    )),
  );
}
