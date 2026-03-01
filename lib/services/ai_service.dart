import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/chat_message.dart';

/// Handles communication with OpenAI-compatible API for the chatbot feature.
class AiService {
  static const String _baseUrl = 'https://api.openai.com/v1/chat/completions';
  static const String _model = 'gpt-4o-mini';

  /// Sends a message to the AI along with conversation history and book context.
  static Future<String> sendMessage({
    required String apiKey,
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

    messages.add({
      'role': 'user',
      'content': userMessage,
    });

    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': _model,
          'messages': messages,
          'max_tokens': 1024,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final choices = data['choices'] as List;
        if (choices.isNotEmpty) {
          final message = choices[0]['message'] as Map<String, dynamic>;
          return message['content'] as String;
        }
        return 'No response received from AI.';
      } else {
        final error = jsonDecode(response.body);
        return 'Error: ${error['error']?['message'] ?? 'Unknown error (${response.statusCode})'}';
      }
    } catch (e) {
      return 'Connection error: $e';
    }
  }

  static String _buildSystemPrompt(String? bookContext, String? selectedText) {
    var prompt = StringBuffer();
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
