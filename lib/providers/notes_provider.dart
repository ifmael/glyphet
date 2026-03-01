import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/note.dart';
import '../services/storage_service.dart';

/// Manages user notes state.
class NotesProvider extends ChangeNotifier {
  List<Note> _notes = [];

  List<Note> get notes => _notes;

  void loadNotes({String? bookId}) {
    _notes = StorageService.getNotes(bookId: bookId);
    notifyListeners();
  }

  Future<Note> addNote({
    required String bookId,
    required String selectedText,
    required String content,
    required int chapterIndex,
  }) async {
    final now = DateTime.now();
    final note = Note(
      id: const Uuid().v4(),
      bookId: bookId,
      selectedText: selectedText,
      content: content,
      chapterIndex: chapterIndex,
      createdAt: now,
      updatedAt: now,
    );

    await StorageService.saveNote(note);
    _notes.insert(0, note);
    notifyListeners();
    return note;
  }

  Future<void> updateNote(String id, String content) async {
    final index = _notes.indexWhere((n) => n.id == id);
    if (index >= 0) {
      _notes[index].content = content;
      _notes[index].updatedAt = DateTime.now();
      await StorageService.saveNote(_notes[index]);
      notifyListeners();
    }
  }

  Future<void> deleteNote(String id) async {
    await StorageService.deleteNote(id);
    _notes.removeWhere((n) => n.id == id);
    notifyListeners();
  }
}
