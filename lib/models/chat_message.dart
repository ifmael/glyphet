/// Represents a single message in the chat conversation.
class ChatMessage {
  final String id;
  final String bookId;
  final String role; // 'user' or 'assistant'
  final String content;
  final DateTime timestamp;
  final String? selectedText;

  ChatMessage({
    required this.id,
    required this.bookId,
    required this.role,
    required this.content,
    required this.timestamp,
    this.selectedText,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'bookId': bookId,
        'role': role,
        'content': content,
        'timestamp': timestamp.toIso8601String(),
        'selectedText': selectedText,
      };

  factory ChatMessage.fromMap(Map<dynamic, dynamic> map) => ChatMessage(
        id: map['id'] as String,
        bookId: map['bookId'] as String,
        role: map['role'] as String,
        content: map['content'] as String,
        timestamp: DateTime.parse(map['timestamp'] as String),
        selectedText: map['selectedText'] as String?,
      );

  Map<String, dynamic> toApiFormat() => {
        'role': role,
        'content': content,
      };
}
