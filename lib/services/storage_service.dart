import 'package:hive_flutter/hive_flutter.dart';
import '../models/book.dart';
import '../models/note.dart';
import '../models/chat_message.dart';
import '../models/text_markup.dart';

/// Manages local persistence using Hive (works on all platforms including web).
class StorageService {
  static const String _booksBox = 'books';
  static const String _notesBox = 'notes';
  static const String _chatBox = 'chat_messages';
  static const String _settingsBox = 'settings';
  static const String _markupsBox = 'markups';

  static Future<void> initialize() async {
    await Hive.initFlutter();
    await Hive.openBox(_booksBox);
    await Hive.openBox(_notesBox);
    await Hive.openBox(_chatBox);
    await Hive.openBox(_settingsBox);
    await Hive.openBox(_markupsBox);
  }

  // ── Books ──

  static List<Book> getBooks() {
    final box = Hive.box(_booksBox);
    return box.values
        .map((v) => Book.fromMap(Map<dynamic, dynamic>.from(v as Map)))
        .toList()
      ..sort((a, b) => b.addedAt.compareTo(a.addedAt));
  }

  static Future<void> saveBook(Book book) async {
    final box = Hive.box(_booksBox);
    await box.put(book.id, book.toMap());
  }

  static Future<void> deleteBook(String id) async {
    final box = Hive.box(_booksBox);
    await box.delete(id);
  }

  // ── Notes ──

  static List<Note> getNotes({String? bookId}) {
    final box = Hive.box(_notesBox);
    var notes = box.values
        .map((v) => Note.fromMap(Map<dynamic, dynamic>.from(v as Map)))
        .toList();
    if (bookId != null) {
      notes = notes.where((n) => n.bookId == bookId).toList();
    }
    notes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return notes;
  }

  static Future<void> saveNote(Note note) async {
    final box = Hive.box(_notesBox);
    await box.put(note.id, note.toMap());
  }

  static Future<void> deleteNote(String id) async {
    final box = Hive.box(_notesBox);
    await box.delete(id);
  }

  // ── Chat Messages ──

  static List<ChatMessage> getChatMessages(String bookId) {
    final box = Hive.box(_chatBox);
    return box.values
        .map((v) => ChatMessage.fromMap(Map<dynamic, dynamic>.from(v as Map)))
        .where((m) => m.bookId == bookId)
        .toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }

  static Future<void> saveChatMessage(ChatMessage message) async {
    final box = Hive.box(_chatBox);
    await box.put(message.id, message.toMap());
  }

  static Future<void> clearChat(String bookId) async {
    final box = Hive.box(_chatBox);
    final keysToDelete = box.keys.where((key) {
      final val = box.get(key) as Map?;
      return val != null && val['bookId'] == bookId;
    }).toList();
    for (final key in keysToDelete) {
      await box.delete(key);
    }
  }

  // ── Settings ──

  /// Legacy single-key getter (kept for backward compat).
  static String? getApiKey() {
    final box = Hive.box(_settingsBox);
    return box.get('openai_api_key') as String?;
  }

  static Future<void> setApiKey(String key) async {
    final box = Hive.box(_settingsBox);
    await box.put('openai_api_key', key);
  }

  // ── AI Provider Settings ──

  static String getActiveProviderId() {
    final box = Hive.box(_settingsBox);
    return box.get('ai_provider_id', defaultValue: 'openai') as String;
  }

  static Future<void> setActiveProviderId(String id) async {
    final box = Hive.box(_settingsBox);
    await box.put('ai_provider_id', id);
  }

  static String? getProviderApiKey(String providerId) {
    final box = Hive.box(_settingsBox);
    return box.get('api_key_$providerId') as String?;
  }

  static Future<void> setProviderApiKey(String providerId, String key) async {
    final box = Hive.box(_settingsBox);
    await box.put('api_key_$providerId', key);
  }

  static String? getProviderModel(String providerId) {
    final box = Hive.box(_settingsBox);
    return box.get('model_$providerId') as String?;
  }

  static Future<void> setProviderModel(String providerId, String model) async {
    final box = Hive.box(_settingsBox);
    await box.put('model_$providerId', model);
  }

  static String? getCustomBaseUrl() {
    final box = Hive.box(_settingsBox);
    return box.get('custom_base_url') as String?;
  }

  static Future<void> setCustomBaseUrl(String url) async {
    final box = Hive.box(_settingsBox);
    await box.put('custom_base_url', url);
  }

  static bool getDarkMode() {
    final box = Hive.box(_settingsBox);
    return box.get('dark_mode', defaultValue: false) as bool;
  }

  static Future<void> setDarkMode(bool value) async {
    final box = Hive.box(_settingsBox);
    await box.put('dark_mode', value);
  }

  // ── Reader Settings ──

  static String getReaderThemeId() {
    final box = Hive.box(_settingsBox);
    return box.get('reader_theme_id', defaultValue: 'paper') as String;
  }

  static Future<void> setReaderThemeId(String id) async {
    final box = Hive.box(_settingsBox);
    await box.put('reader_theme_id', id);
  }

  static String getReaderFontFamily() {
    final box = Hive.box(_settingsBox);
    return box.get('reader_font_family', defaultValue: 'Literata') as String;
  }

  static Future<void> setReaderFontFamily(String family) async {
    final box = Hive.box(_settingsBox);
    await box.put('reader_font_family', family);
  }

  static double getReaderFontSize() {
    final box = Hive.box(_settingsBox);
    return (box.get('reader_font_size', defaultValue: 18.0) as num).toDouble();
  }

  static Future<void> setReaderFontSize(double size) async {
    final box = Hive.box(_settingsBox);
    await box.put('reader_font_size', size);
  }

  static double getReaderFontContrast() {
    final box = Hive.box(_settingsBox);
    return (box.get('reader_font_contrast', defaultValue: 1.0) as num).toDouble();
  }

  static Future<void> setReaderFontContrast(double contrast) async {
    final box = Hive.box(_settingsBox);
    await box.put('reader_font_contrast', contrast);
  }

  static double getReaderLineHeight() {
    final box = Hive.box(_settingsBox);
    return (box.get('reader_line_height', defaultValue: 1.7) as num).toDouble();
  }

  static Future<void> setReaderLineHeight(double height) async {
    final box = Hive.box(_settingsBox);
    await box.put('reader_line_height', height);
  }

  // ── Text Markups ──

  static List<TextMarkup> getMarkups({required String bookId}) {
    final box = Hive.box(_markupsBox);
    return box.values
        .map((v) => TextMarkup.fromMap(Map<dynamic, dynamic>.from(v as Map)))
        .where((m) => m.bookId == bookId)
        .toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  static Future<void> saveMarkup(TextMarkup markup) async {
    final box = Hive.box(_markupsBox);
    await box.put(markup.id, markup.toMap());
  }

  static Future<void> deleteMarkup(String id) async {
    final box = Hive.box(_markupsBox);
    await box.delete(id);
  }
}
