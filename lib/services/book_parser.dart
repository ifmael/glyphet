import 'dart:typed_data';
import 'package:epubx/epubx.dart' as epubx;
import 'package:image/image.dart' as img;

/// Parsed chapter content from an EPUB file.
class BookChapter {
  final String title;
  final String htmlContent;
  final String plainText;

  BookChapter({
    required this.title,
    required this.htmlContent,
    required this.plainText,
  });
}

/// Parsed book metadata and content.
class ParsedBook {
  final String title;
  final String author;
  final List<BookChapter> chapters;
  final Uint8List? coverImage;

  ParsedBook({
    required this.title,
    required this.author,
    required this.chapters,
    this.coverImage,
  });
}

/// Parses EPUB files into structured content.
class BookParser {
  /// Parses an EPUB file from raw bytes.
  static Future<ParsedBook> parseEpub(Uint8List bytes) async {
    final book = await epubx.EpubReader.readBook(bytes);

    final title = book.Title ?? 'Untitled';
    final author = book.Author ?? 'Unknown Author';

    Uint8List? coverImage;
    if (book.CoverImage != null) {
      coverImage = Uint8List.fromList(img.encodePng(book.CoverImage!));
    }

    final chapters = <BookChapter>[];

    if (book.Chapters != null) {
      for (final chapter in book.Chapters!) {
        _extractChapters(chapter, chapters);
      }
    }

    if (chapters.isEmpty && book.Content?.Html != null) {
      var index = 1;
      for (final entry in book.Content!.Html!.entries) {
        final html = entry.value.Content ?? '';
        chapters.add(BookChapter(
          title: 'Section $index',
          htmlContent: html,
          plainText: _stripHtml(html),
        ));
        index++;
      }
    }

    return ParsedBook(
      title: title,
      author: author,
      chapters: chapters,
      coverImage: coverImage,
    );
  }

  static void _extractChapters(
      epubx.EpubChapter source, List<BookChapter> result) {
    final html = source.HtmlContent ?? '';
    if (html.isNotEmpty) {
      result.add(BookChapter(
        title: source.Title ?? 'Chapter ${result.length + 1}',
        htmlContent: html,
        plainText: _stripHtml(html),
      ));
    }
    if (source.SubChapters != null) {
      for (final sub in source.SubChapters!) {
        _extractChapters(sub, result);
      }
    }
  }

  /// Strips HTML tags to produce plain text.
  static String _stripHtml(String html) {
    return html
        .replaceAll(RegExp(r'<style[^>]*>.*?</style>', dotAll: true), '')
        .replaceAll(RegExp(r'<script[^>]*>.*?</script>', dotAll: true), '')
        .replaceAll(RegExp(r'<[^>]+>'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}
