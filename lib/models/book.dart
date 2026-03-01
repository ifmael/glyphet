/// Supported book file formats.
enum BookFormat { epub, pdf, mobi }

/// Represents a book in the user's library.
class Book {
  final String id;
  final String title;
  final String author;
  final BookFormat format;
  final String filePath;
  final DateTime addedAt;
  final String? coverBase64;
  double readingProgress;
  int lastChapterIndex;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.format,
    required this.filePath,
    required this.addedAt,
    this.coverBase64,
    this.readingProgress = 0.0,
    this.lastChapterIndex = 0,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'author': author,
        'format': format.name,
        'filePath': filePath,
        'addedAt': addedAt.toIso8601String(),
        'coverBase64': coverBase64,
        'readingProgress': readingProgress,
        'lastChapterIndex': lastChapterIndex,
      };

  factory Book.fromMap(Map<dynamic, dynamic> map) => Book(
        id: map['id'] as String,
        title: map['title'] as String,
        author: map['author'] as String? ?? 'Unknown',
        format: BookFormat.values.firstWhere(
          (f) => f.name == (map['format'] as String),
          orElse: () => BookFormat.epub,
        ),
        filePath: map['filePath'] as String,
        addedAt: DateTime.parse(map['addedAt'] as String),
        coverBase64: map['coverBase64'] as String?,
        readingProgress: (map['readingProgress'] as num?)?.toDouble() ?? 0.0,
        lastChapterIndex: (map['lastChapterIndex'] as num?)?.toInt() ?? 0,
      );
}
