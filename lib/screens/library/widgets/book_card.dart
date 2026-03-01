import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../models/book.dart';

/// Card widget displaying a book in the library grid.
class BookCard extends StatelessWidget {
  final Book book;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const BookCard({
    super.key,
    required this.book,
    required this.onTap,
    required this.onDelete,
  });

  IconData _formatIcon(BookFormat format) {
    switch (format) {
      case BookFormat.epub:
        return Icons.menu_book;
      case BookFormat.pdf:
        return Icons.picture_as_pdf;
      case BookFormat.mobi:
        return Icons.phone_android;
    }
  }

  Color _formatColor(BookFormat format) {
    switch (format) {
      case BookFormat.epub:
        return Colors.teal;
      case BookFormat.pdf:
        return Colors.red;
      case BookFormat.mobi:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 3,
              child: _buildCover(context),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      book.author,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.6),
                          ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: _formatColor(book.format)
                                .withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            book.format.name.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: _formatColor(book.format),
                            ),
                          ),
                        ),
                        const Spacer(),
                        InkWell(
                          onTap: onDelete,
                          child: Icon(Icons.delete_outline,
                              size: 18,
                              color: Theme.of(context)
                                  .colorScheme
                                  .error
                                  .withValues(alpha: 0.7)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCover(BuildContext context) {
    if (book.coverBase64 != null && book.coverBase64!.isNotEmpty) {
      try {
        return Image.memory(
          base64Decode(book.coverBase64!),
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildPlaceholderCover(context),
        );
      } catch (_) {
        return _buildPlaceholderCover(context);
      }
    }
    return _buildPlaceholderCover(context);
  }

  Widget _buildPlaceholderCover(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _formatColor(book.format).withValues(alpha: 0.7),
            _formatColor(book.format).withValues(alpha: 0.3),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _formatIcon(book.format),
              size: 48,
              color: Colors.white.withValues(alpha: 0.9),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                book.title,
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
