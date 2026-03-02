import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/text_markup.dart';
import '../services/storage_service.dart';

/// Manages text highlights and underlines for the current book.
class MarkupProvider extends ChangeNotifier {
  List<TextMarkup> _markups = [];

  List<TextMarkup> get markups => _markups;

  /// Returns markups for a specific chapter.
  List<TextMarkup> getChapterMarkups(int chapterIndex) {
    return _markups.where((m) => m.chapterIndex == chapterIndex).toList();
  }

  void loadMarkups(String bookId) {
    _markups = StorageService.getMarkups(bookId: bookId);
    notifyListeners();
  }

  Future<void> addMarkup({
    required String bookId,
    required int chapterIndex,
    required String text,
    required MarkupType type,
  }) async {
    final existing = _markups.where(
        (m) => m.chapterIndex == chapterIndex && m.text == text && m.type == type);
    if (existing.isNotEmpty) return;

    final markup = TextMarkup(
      id: const Uuid().v4(),
      bookId: bookId,
      chapterIndex: chapterIndex,
      text: text,
      type: type,
      createdAt: DateTime.now(),
    );

    await StorageService.saveMarkup(markup);
    _markups.add(markup);
    notifyListeners();
  }

  Future<void> removeMarkup(String id) async {
    await StorageService.deleteMarkup(id);
    _markups.removeWhere((m) => m.id == id);
    notifyListeners();
  }

  Future<void> removeByText({
    required int chapterIndex,
    required String text,
    required MarkupType type,
  }) async {
    final toRemove = _markups.where(
        (m) => m.chapterIndex == chapterIndex && m.text == text && m.type == type).toList();
    for (final m in toRemove) {
      await StorageService.deleteMarkup(m.id);
      _markups.remove(m);
    }
    notifyListeners();
  }
}
