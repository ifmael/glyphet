import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF6C63FF);
  static const Color secondaryColor = Color(0xFF03DAC6);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.light,
      surface: const Color(0xFFFCFCFC),
    ),
    scaffoldBackgroundColor: const Color(0xFFF8F7FC),
    textTheme: GoogleFonts.interTextTheme(),
    appBarTheme: AppBarTheme(
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 0.5,
      backgroundColor: Colors.transparent,
      titleTextStyle: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF1A1A2E),
        letterSpacing: -0.3,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      surfaceTintColor: Colors.transparent,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFF0F0F5),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryColor, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    dividerTheme: const DividerThemeData(
      thickness: 0.5,
      color: Color(0xFFE8E8EE),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      showDragHandle: false,
      backgroundColor: Colors.transparent,
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.dark,
      surface: const Color(0xFF1A1A2E),
    ),
    scaffoldBackgroundColor: const Color(0xFF12121F),
    textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
    appBarTheme: AppBarTheme(
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 0.5,
      backgroundColor: Colors.transparent,
      titleTextStyle: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: const Color(0xFFE8E8F0),
        letterSpacing: -0.3,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: const Color(0xFF1E1E32),
      surfaceTintColor: Colors.transparent,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF252540),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: primaryColor.withValues(alpha: 0.7), width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    dividerTheme: const DividerThemeData(
      thickness: 0.5,
      color: Color(0xFF2A2A40),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      showDragHandle: false,
      backgroundColor: Colors.transparent,
    ),
  );
}
