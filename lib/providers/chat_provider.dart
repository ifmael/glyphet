import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/chat_message.dart';
import '../services/ai_service.dart';
import '../services/storage_service.dart';

/// Manages the chatbot conversation state.
class ChatProvider extends ChangeNotifier {
  List<ChatMessage> _messages = [];
  bool _isLoading = false;
  String? _currentBookId;

  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;

  void loadMessages(String bookId) {
    _currentBookId = bookId;
    _messages = StorageService.getChatMessages(bookId);
    notifyListeners();
  }

  /// Sends a user message and gets an AI response.
  Future<void> sendMessage({
    required String content,
    String? selectedText,
    String? chapterContext,
  }) async {
    if (_currentBookId == null) return;

    final apiKey = StorageService.getApiKey();
    if (apiKey == null || apiKey.isEmpty) {
      _addSystemMessage('Please configure your OpenAI API key in Settings.');
      return;
    }

    final userMessage = ChatMessage(
      id: const Uuid().v4(),
      bookId: _currentBookId!,
      role: 'user',
      content: content,
      timestamp: DateTime.now(),
      selectedText: selectedText,
    );

    _messages.add(userMessage);
    await StorageService.saveChatMessage(userMessage);
    _isLoading = true;
    notifyListeners();

    try {
      final response = await AiService.sendMessage(
        apiKey: apiKey,
        history: _messages,
        userMessage: content,
        bookContext: chapterContext,
        selectedText: selectedText,
      );

      final assistantMessage = ChatMessage(
        id: const Uuid().v4(),
        bookId: _currentBookId!,
        role: 'assistant',
        content: response,
        timestamp: DateTime.now(),
      );

      _messages.add(assistantMessage);
      await StorageService.saveChatMessage(assistantMessage);
    } catch (e) {
      _addSystemMessage('Error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  void _addSystemMessage(String text) {
    _messages.add(ChatMessage(
      id: const Uuid().v4(),
      bookId: _currentBookId ?? '',
      role: 'assistant',
      content: text,
      timestamp: DateTime.now(),
    ));
  }

  Future<void> clearChat() async {
    if (_currentBookId != null) {
      await StorageService.clearChat(_currentBookId!);
      _messages.clear();
      notifyListeners();
    }
  }
}
