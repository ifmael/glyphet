import 'package:flutter/material.dart';

/// A reading theme with background, text color and name.
class ReaderTheme {
  final String id;
  final String name;
  final IconData icon;
  final Color backgroundColor;
  final Color textColor;
  final Color accentColor;
  final Color chapterTitleColor;
  final Color navBarColor;
  final Color navBarTextColor;
  final Brightness brightness;

  const ReaderTheme({
    required this.id,
    required this.name,
    required this.icon,
    required this.backgroundColor,
    required this.textColor,
    required this.accentColor,
    required this.chapterTitleColor,
    required this.navBarColor,
    required this.navBarTextColor,
    required this.brightness,
  });
}

/// All available reading themes.
class ReaderThemes {
  static const paper = ReaderTheme(
    id: 'paper',
    name: 'Paper',
    icon: Icons.article_outlined,
    backgroundColor: Color(0xFFFAF9F6),
    textColor: Color(0xFF2C2C2C),
    accentColor: Color(0xFF6C63FF),
    chapterTitleColor: Color(0xFF1A1A1A),
    navBarColor: Color(0xFFF0EFEC),
    navBarTextColor: Color(0xFF555555),
    brightness: Brightness.light,
  );

  static const snow = ReaderTheme(
    id: 'snow',
    name: 'Snow',
    icon: Icons.wb_sunny_outlined,
    backgroundColor: Color(0xFFFFFFFF),
    textColor: Color(0xFF000000),
    accentColor: Color(0xFF1565C0),
    chapterTitleColor: Color(0xFF000000),
    navBarColor: Color(0xFFF5F5F5),
    navBarTextColor: Color(0xFF333333),
    brightness: Brightness.light,
  );

  static const sepia = ReaderTheme(
    id: 'sepia',
    name: 'Sepia',
    icon: Icons.auto_stories,
    backgroundColor: Color(0xFFF4ECD8),
    textColor: Color(0xFF5B4636),
    accentColor: Color(0xFF8B6914),
    chapterTitleColor: Color(0xFF3E2723),
    navBarColor: Color(0xFFE8DCC8),
    navBarTextColor: Color(0xFF5B4636),
    brightness: Brightness.light,
  );

  static const dusk = ReaderTheme(
    id: 'dusk',
    name: 'Dusk',
    icon: Icons.nights_stay_outlined,
    backgroundColor: Color(0xFF2B2B3D),
    textColor: Color(0xFFCDCDE0),
    accentColor: Color(0xFF9FA8DA),
    chapterTitleColor: Color(0xFFE8E8F0),
    navBarColor: Color(0xFF232336),
    navBarTextColor: Color(0xFFAAAAAA),
    brightness: Brightness.dark,
  );

  static const night = ReaderTheme(
    id: 'night',
    name: 'Night',
    icon: Icons.dark_mode_outlined,
    backgroundColor: Color(0xFF1E1E1E),
    textColor: Color(0xFFCCCCCC),
    accentColor: Color(0xFF82B1FF),
    chapterTitleColor: Color(0xFFE0E0E0),
    navBarColor: Color(0xFF161616),
    navBarTextColor: Color(0xFF999999),
    brightness: Brightness.dark,
  );

  static const midnight = ReaderTheme(
    id: 'midnight',
    name: 'Midnight',
    icon: Icons.brightness_2_outlined,
    backgroundColor: Color(0xFF000000),
    textColor: Color(0xFFB0B0B0),
    accentColor: Color(0xFF64B5F6),
    chapterTitleColor: Color(0xFFD0D0D0),
    navBarColor: Color(0xFF0A0A0A),
    navBarTextColor: Color(0xFF888888),
    brightness: Brightness.dark,
  );

  static const List<ReaderTheme> all = [
    paper,
    snow,
    sepia,
    dusk,
    night,
    midnight,
  ];

  static ReaderTheme getById(String id) {
    return all.firstWhere((t) => t.id == id, orElse: () => paper);
  }
}

/// Available reading fonts.
class ReaderFonts {
  static const List<String> all = [
    'Literata',
    'Merriweather',
    'Lora',
    'Source Serif 4',
    'Nunito',
    'Open Sans',
    'Roboto',
    'Inter',
    'Atkinson Hyperlegible',
  ];
}
