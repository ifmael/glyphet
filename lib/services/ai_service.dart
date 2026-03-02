import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/ai_provider.dart';
import '../models/chat_message.dart';

/// Unified service that routes requests to any supported AI provider.
class AiService {
  /// Sends a message using the specified provider configuration.
  static Future<String> sendMessage({
    required AiProvider provider,
    required String model,
    required String apiKey,
    required List<ChatMessage> history,
    required String userMessage,
    String? bookContext,
    String? selectedText,
    String? customBaseUrl,
  }) async {
    if (provider.id == 'anthropic') {
      return _sendAnthropic(
        apiKey: apiKey,
        model: model,
        history: history,
        userMessage: userMessage,
        bookContext: bookContext,
        selectedText: selectedText,
      );
    }

    if (provider.id == 'google') {
      return _sendGoogle(
        apiKey: apiKey,
        model: model,
        history: history,
        userMessage: userMessage,
        bookContext: bookContext,
        selectedText: selectedText,
      );
    }

    return _sendOpenAICompatible(
      baseUrl: customBaseUrl ?? provider.baseUrl,
      apiKey: apiKey,
      model: model,
      history: history,
      userMessage: userMessage,
      bookContext: bookContext,
      selectedText: selectedText,
    );
  }

  // ── OpenAI-compatible (OpenAI, Mistral, DeepSeek, Groq, OpenRouter, Custom) ──

  static Future<String> _sendOpenAICompatible({
    required String baseUrl,
    required String apiKey,
    required String model,
    required List<ChatMessage> history,
    required String userMessage,
    String? bookContext,
    String? selectedText,
  }) async {
    final messages = <Map<String, dynamic>>[];

    messages.add({
      'role': 'system',
      'content': _buildSystemPrompt(bookContext, selectedText),
    });
    for (final msg in history.take(20)) {
      messages.add(msg.toApiFormat());
    }
    messages.add({'role': 'user', 'content': userMessage});

    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': model,
          'messages': messages,
          'max_tokens': 1024,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final choices = data['choices'] as List;
        if (choices.isNotEmpty) {
          return (choices[0]['message'] as Map<String, dynamic>)['content']
              as String;
        }
        return 'No response received.';
      } else {
        return _parseError(response);
      }
    } catch (e) {
      return 'Connection error: $e';
    }
  }

  // ── Anthropic (Claude) — different API format ──

  static Future<String> _sendAnthropic({
    required String apiKey,
    required String model,
    required List<ChatMessage> history,
    required String userMessage,
    String? bookContext,
    String? selectedText,
  }) async {
    final messages = <Map<String, dynamic>>[];
    for (final msg in history.take(20)) {
      messages.add(msg.toApiFormat());
    }
    messages.add({'role': 'user', 'content': userMessage});

    try {
      final response = await http.post(
        Uri.parse('https://api.anthropic.com/v1/messages'),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': apiKey,
          'anthropic-version': '2023-06-01',
          'anthropic-dangerous-direct-browser-access': 'true',
        },
        body: jsonEncode({
          'model': model,
          'max_tokens': 1024,
          'system': _buildSystemPrompt(bookContext, selectedText),
          'messages': messages,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final content = data['content'] as List;
        if (content.isNotEmpty) {
          return (content[0] as Map<String, dynamic>)['text'] as String;
        }
        return 'No response received.';
      } else {
        return _parseError(response);
      }
    } catch (e) {
      return 'Connection error: $e';
    }
  }

  // ── Google Gemini — different API format ──

  static Future<String> _sendGoogle({
    required String apiKey,
    required String model,
    required List<ChatMessage> history,
    required String userMessage,
    String? bookContext,
    String? selectedText,
  }) async {
    final url =
        'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$apiKey';

    final contents = <Map<String, dynamic>>[];

    contents.add({
      'role': 'user',
      'parts': [
        {'text': _buildSystemPrompt(bookContext, selectedText)},
      ],
    });
    contents.add({
      'role': 'model',
      'parts': [
        {'text': 'Understood. I am ready to help you with the book.'},
      ],
    });

    for (final msg in history.take(20)) {
      contents.add({
        'role': msg.role == 'user' ? 'user' : 'model',
        'parts': [
          {'text': msg.content},
        ],
      });
    }

    contents.add({
      'role': 'user',
      'parts': [
        {'text': userMessage},
      ],
    });

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': contents,
          'generationConfig': {
            'maxOutputTokens': 1024,
            'temperature': 0.7,
          },
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final candidates = data['candidates'] as List?;
        if (candidates != null && candidates.isNotEmpty) {
          final parts =
              (candidates[0]['content'] as Map<String, dynamic>)['parts']
                  as List;
          if (parts.isNotEmpty) {
            return (parts[0] as Map<String, dynamic>)['text'] as String;
          }
        }
        return 'No response received.';
      } else {
        return _parseError(response);
      }
    } catch (e) {
      return 'Connection error: $e';
    }
  }

  // ── Helpers ──

  static String _parseError(http.Response response) {
    try {
      final error = jsonDecode(response.body);
      final msg = error['error']?['message'] ??
          error['error']?['msg'] ??
          error['message'] ??
          'Unknown error';
      return 'Error (${response.statusCode}): $msg';
    } catch (_) {
      return 'Error ${response.statusCode}: ${response.reasonPhrase}';
    }
  }

  static String _buildSystemPrompt(String? bookContext, String? selectedText) {
    final prompt = StringBuffer();
    prompt.writeln(
        'You are a helpful reading assistant integrated into an ebook reader app called Glyphet.');
    prompt.writeln(
        'Help the user understand the text they are reading. Answer questions clearly and concisely.');
    prompt.writeln(
        'If the user asks about something from the book, use the provided context to give accurate answers.');

    if (bookContext != null && bookContext.isNotEmpty) {
      prompt.writeln('\n--- Current Chapter Context ---');
      prompt.writeln(bookContext);
      prompt.writeln('--- End Context ---');
    }

    if (selectedText != null && selectedText.isNotEmpty) {
      prompt.writeln('\n--- User Selected Text ---');
      prompt.writeln(selectedText);
      prompt.writeln('--- End Selected Text ---');
    }

    return prompt.toString();
  }
}
