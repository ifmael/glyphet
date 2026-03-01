import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../models/book.dart';
import '../services/book_parser.dart';

/// Manages the ebook reader state (current chapter, content, selection).
class ReaderProvider extends ChangeNotifier {
  Book? _currentBook;
  ParsedBook? _parsedBook;
  int _currentChapter = 0;
  String _selectedText = '';
  bool _isLoading = false;
  Uint8List? _pdfBytes;
  double _fontSize = 18.0;

  Book? get currentBook => _currentBook;
  ParsedBook? get parsedBook => _parsedBook;
  int get currentChapter => _currentChapter;
  String get selectedText => _selectedText;
  bool get isLoading => _isLoading;
  Uint8List? get pdfBytes => _pdfBytes;
  double get fontSize => _fontSize;

  List<BookChapter> get chapters => _parsedBook?.chapters ?? [];
  BookChapter? get currentChapterContent =>
      chapters.isNotEmpty && _currentChapter < chapters.length
          ? chapters[_currentChapter]
          : null;

  String get currentChapterText => currentChapterContent?.plainText ?? '';

  /// Opens a book for reading.
  Future<void> openBook(Book book, Uint8List bytes) async {
    _isLoading = true;
    _currentBook = book;
    _currentChapter = book.lastChapterIndex;
    notifyListeners();

    try {
      if (book.format == BookFormat.epub) {
        _parsedBook = await BookParser.parseEpub(bytes);
        _pdfBytes = null;
      } else if (book.format == BookFormat.pdf) {
        _pdfBytes = bytes;
        _parsedBook = null;
      }
    } catch (e) {
      debugPrint('Error opening book: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  void goToChapter(int index) {
    if (index >= 0 && index < chapters.length) {
      _currentChapter = index;
      notifyListeners();
    }
  }

  void nextChapter() {
    if (_currentChapter < chapters.length - 1) {
      _currentChapter++;
      notifyListeners();
    }
  }

  void previousChapter() {
    if (_currentChapter > 0) {
      _currentChapter--;
      notifyListeners();
    }
  }

  void setSelectedText(String text) {
    _selectedText = text;
    notifyListeners();
  }

  void clearSelection() {
    _selectedText = '';
    notifyListeners();
  }

  void setFontSize(double size) {
    _fontSize = size.clamp(12.0, 32.0);
    notifyListeners();
  }

  void closeBook() {
    _currentBook = null;
    _parsedBook = null;
    _pdfBytes = null;
    _currentChapter = 0;
    _selectedText = '';
    notifyListeners();
  }
}
