/// Types of visual markup that can be applied to selected text.
enum MarkupType { highlight, underline }

/// A persistent text markup (highlight or underline) tied to a book chapter.
class TextMarkup {
  final String id;
  final String bookId;
  final int chapterIndex;
  final String text;
  final MarkupType type;
  final DateTime createdAt;

  TextMarkup({
    required this.id,
    required this.bookId,
    required this.chapterIndex,
    required this.text,
    required this.type,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'bookId': bookId,
        'chapterIndex': chapterIndex,
        'text': text,
        'type': type.name,
        'createdAt': createdAt.toIso8601String(),
      };

  factory TextMarkup.fromMap(Map<dynamic, dynamic> map) => TextMarkup(
        id: map['id'] as String,
        bookId: map['bookId'] as String,
        chapterIndex: (map['chapterIndex'] as num).toInt(),
        text: map['text'] as String,
        type: MarkupType.values.firstWhere(
          (t) => t.name == (map['type'] as String),
          orElse: () => MarkupType.highlight,
        ),
        createdAt: DateTime.parse(map['createdAt'] as String),
      );
}
