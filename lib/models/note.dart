/// Represents a user note associated with a book.
class Note {
  final String id;
  final String bookId;
  final String selectedText;
  String content;
  final int chapterIndex;
  final DateTime createdAt;
  DateTime updatedAt;

  Note({
    required this.id,
    required this.bookId,
    required this.selectedText,
    required this.content,
    required this.chapterIndex,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'bookId': bookId,
        'selectedText': selectedText,
        'content': content,
        'chapterIndex': chapterIndex,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory Note.fromMap(Map<dynamic, dynamic> map) => Note(
        id: map['id'] as String,
        bookId: map['bookId'] as String,
        selectedText: map['selectedText'] as String? ?? '',
        content: map['content'] as String,
        chapterIndex: (map['chapterIndex'] as num?)?.toInt() ?? 0,
        createdAt: DateTime.parse(map['createdAt'] as String),
        updatedAt: DateTime.parse(map['updatedAt'] as String),
      );
}
