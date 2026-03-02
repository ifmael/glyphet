import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/ai_provider.dart';
import '../models/chat_message.dart';
import '../services/ai_service.dart';
import '../services/storage_service.dart';

/// Manages the chatbot conversation state with multi-provider support.
class ChatProvider extends ChangeNotifier {
  List<ChatMessage> _messages = [];
  bool _isLoading = false;
  String? _currentBookId;

  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;

  AiProvider get activeProvider =>
      AiProviders.getById(StorageService.getActiveProviderId());

  String get activeModel =>
      StorageService.getProviderModel(activeProvider.id) ??
      activeProvider.defaultModel;

  void loadMessages(String bookId) {
    _currentBookId = bookId;
    _messages = StorageService.getChatMessages(bookId);
    notifyListeners();
  }

  /// Sends a user message and gets an AI response from the active provider.
  Future<void> sendMessage({
    required String content,
    String? selectedText,
    String? chapterContext,
  }) async {
    if (_currentBookId == null) return;

    final provider = activeProvider;
    final model = activeModel;
    final apiKey = StorageService.getProviderApiKey(provider.id) ?? '';

    if (apiKey.isEmpty && provider.id != 'custom') {
      _addSystemMessage(
          'Please configure your ${provider.name} API key in Settings → AI Providers.');
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
        provider: provider,
        model: model,
        apiKey: apiKey,
        history: _messages,
        userMessage: content,
        bookContext: chapterContext,
        selectedText: selectedText,
        customBaseUrl:
            provider.id == 'custom' ? StorageService.getCustomBaseUrl() : null,
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
    notifyListeners();
  }

  Future<void> clearChat() async {
    if (_currentBookId != null) {
      await StorageService.clearChat(_currentBookId!);
      _messages.clear();
      notifyListeners();
    }
  }
}
