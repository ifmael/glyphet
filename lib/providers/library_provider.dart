import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/book.dart';
import '../services/storage_service.dart';
import '../services/book_parser.dart';

/// Manages the book library state.
class LibraryProvider extends ChangeNotifier {
  List<Book> _books = [];
  bool _isLoading = false;

  List<Book> get books => _books;
  bool get isLoading => _isLoading;

  void loadBooks() {
    _books = StorageService.getBooks();
    notifyListeners();
  }

  /// Imports a book from raw file bytes.
  Future<Book?> importBook({
    required String fileName,
    required Uint8List fileBytes,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final format = _detectFormat(fileName);
      String title = fileName.replaceAll(RegExp(r'\.[^.]+$'), '');
      String author = 'Unknown Author';
      String? coverBase64;

      if (format == BookFormat.epub) {
        try {
          final parsed = await BookParser.parseEpub(fileBytes);
          title = parsed.title;
          author = parsed.author;
          if (parsed.coverImage != null) {
            coverBase64 = base64Encode(parsed.coverImage!);
          }
        } catch (_) {
          // Use filename as title if parsing fails
        }
      }

      final book = Book(
        id: const Uuid().v4(),
        title: title,
        author: author,
        format: format,
        filePath: fileName,
        addedAt: DateTime.now(),
        coverBase64: coverBase64,
      );

      await StorageService.saveBook(book);

      // Store file bytes in Hive for web compatibility
      final dataBox = await _getDataBox();
      await dataBox.put(book.id, fileBytes);

      _books.insert(0, book);
      _isLoading = false;
      notifyListeners();
      return book;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteBook(String bookId) async {
    await StorageService.deleteBook(bookId);
    final dataBox = await _getDataBox();
    await dataBox.delete(bookId);
    _books.removeWhere((b) => b.id == bookId);
    notifyListeners();
  }

  Future<void> updateProgress(String bookId, double progress, int chapter) async {
    final index = _books.indexWhere((b) => b.id == bookId);
    if (index >= 0) {
      _books[index].readingProgress = progress;
      _books[index].lastChapterIndex = chapter;
      await StorageService.saveBook(_books[index]);
      notifyListeners();
    }
  }

  /// Retrieves stored file bytes for a book.
  Future<Uint8List?> getBookBytes(String bookId) async {
    final dataBox = await _getDataBox();
    final data = dataBox.get(bookId);
    if (data is Uint8List) return data;
    if (data is List) return Uint8List.fromList(List<int>.from(data));
    return null;
  }

  static Future<dynamic> _getDataBox() async {
    const boxName = 'book_data';
    if (Hive.isBoxOpen(boxName)) {
      return Hive.box(boxName);
    }
    return await Hive.openBox(boxName);
  }

  BookFormat _detectFormat(String fileName) {
    final lower = fileName.toLowerCase();
    if (lower.endsWith('.epub')) return BookFormat.epub;
    if (lower.endsWith('.pdf')) return BookFormat.pdf;
    if (lower.endsWith('.mobi')) return BookFormat.mobi;
    return BookFormat.pdf;
  }
}
