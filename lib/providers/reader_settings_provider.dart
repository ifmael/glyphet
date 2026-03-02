import 'package:flutter/material.dart';
import '../models/reader_theme.dart';
import '../services/storage_service.dart';

/// Manages all reader appearance settings: theme, font, size, contrast.
class ReaderSettingsProvider extends ChangeNotifier {
  ReaderTheme _theme = ReaderThemes.paper;
  String _fontFamily = 'Literata';
  double _fontSize = 18.0;
  double _fontContrast = 1.0; // 0.5 = low, 1.0 = normal, 1.5 = high
  double _lineHeight = 1.7;

  ReaderTheme get theme => _theme;
  String get fontFamily => _fontFamily;
  double get fontSize => _fontSize;
  double get fontContrast => _fontContrast;
  double get lineHeight => _lineHeight;

  /// Effective text color adjusted by contrast level.
  Color get effectiveTextColor {
    final base = _theme.textColor;
    if (_fontContrast == 1.0) return base;

    if (_theme.brightness == Brightness.dark) {
      final factor = _fontContrast;
      final r = (base.r * factor).clamp(0.0, 1.0);
      final g = (base.g * factor).clamp(0.0, 1.0);
      final b = (base.b * factor).clamp(0.0, 1.0);
      return Color.from(alpha: 1.0, red: r, green: g, blue: b);
    } else {
      final inv = 2.0 - _fontContrast;
      final r = (base.r * inv).clamp(0.0, 1.0);
      final g = (base.g * inv).clamp(0.0, 1.0);
      final b = (base.b * inv).clamp(0.0, 1.0);
      return Color.from(alpha: 1.0, red: r, green: g, blue: b);
    }
  }

  void loadSettings() {
    _theme = ReaderThemes.getById(StorageService.getReaderThemeId());
    _fontFamily = StorageService.getReaderFontFamily();
    _fontSize = StorageService.getReaderFontSize();
    _fontContrast = StorageService.getReaderFontContrast();
    _lineHeight = StorageService.getReaderLineHeight();
    notifyListeners();
  }

  Future<void> setTheme(ReaderTheme theme) async {
    _theme = theme;
    await StorageService.setReaderThemeId(theme.id);
    notifyListeners();
  }

  Future<void> setFontFamily(String family) async {
    _fontFamily = family;
    await StorageService.setReaderFontFamily(family);
    notifyListeners();
  }

  Future<void> setFontSize(double size) async {
    _fontSize = size.clamp(12.0, 36.0);
    await StorageService.setReaderFontSize(_fontSize);
    notifyListeners();
  }

  Future<void> setFontContrast(double contrast) async {
    _fontContrast = contrast.clamp(0.4, 1.6);
    await StorageService.setReaderFontContrast(_fontContrast);
    notifyListeners();
  }

  Future<void> setLineHeight(double height) async {
    _lineHeight = height.clamp(1.2, 2.5);
    await StorageService.setReaderLineHeight(_lineHeight);
    notifyListeners();
  }
}
