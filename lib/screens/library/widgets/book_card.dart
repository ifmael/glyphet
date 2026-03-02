import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../../models/book.dart';

/// Modern card widget displaying a book in the library grid.
class BookCard extends StatefulWidget {
  final Book book;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const BookCard({
    super.key,
    required this.book,
    required this.onTap,
    required this.onDelete,
  });

  @override
  State<BookCard> createState() => _BookCardState();
}

class _BookCardState extends State<BookCard> {
  bool _hovering = false;

  static const _coverGradients = [
    [Color(0xFF667EEA), Color(0xFF764BA2)],
    [Color(0xFF2193B0), Color(0xFF6DD5ED)],
    [Color(0xFFCC2B5E), Color(0xFF753A88)],
    [Color(0xFF56AB2F), Color(0xFFA8E063)],
    [Color(0xFFDE6262), Color(0xFFFFB88C)],
    [Color(0xFF4568DC), Color(0xFFB06AB3)],
    [Color(0xFF0F2027), Color(0xFF2C5364)],
    [Color(0xFFEB5757), Color(0xFF000000)],
  ];

  List<Color> _gradientForBook() {
    final hash = widget.book.title.hashCode.abs();
    return _coverGradients[hash % _coverGradients.length];
  }

  IconData _formatIcon(BookFormat format) {
    switch (format) {
      case BookFormat.epub:
        return Icons.menu_book_rounded;
      case BookFormat.pdf:
        return Icons.picture_as_pdf_rounded;
      case BookFormat.mobi:
        return Icons.phone_android_rounded;
    }
  }

  Color _formatColor(BookFormat format) {
    switch (format) {
      case BookFormat.epub:
        return const Color(0xFF26A69A);
      case BookFormat.pdf:
        return const Color(0xFFEF5350);
      case BookFormat.mobi:
        return const Color(0xFFFFA726);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: _hovering ? (Matrix4.identity()..setEntry(0, 0, 1.03)..setEntry(1, 1, 1.03)..setEntry(2, 2, 1.03)) : Matrix4.identity(),
        transformAlignment: Alignment.center,
        child: Card(
          clipBehavior: Clip.antiAlias,
          elevation: _hovering ? 8 : 0,
          shadowColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(flex: 3, child: _buildCover(context)),
                _buildInfo(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfo(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.book.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  letterSpacing: -0.2,
                ),
          ),
          const SizedBox(height: 3),
          Text(
            widget.book.author,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.5),
                  fontSize: 11,
                ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _formatColor(widget.book.format)
                      .withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  widget.book.format.name.toUpperCase(),
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: _formatColor(widget.book.format),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: 28,
                height: 28,
                child: IconButton(
                  onPressed: widget.onDelete,
                  icon: Icon(Icons.delete_outline_rounded, size: 15,
                    color: Theme.of(context).colorScheme.error.withValues(alpha: 0.6),
                  ),
                  padding: EdgeInsets.zero,
                  style: IconButton.styleFrom(
                    backgroundColor: Theme.of(context)
                        .colorScheme
                        .error
                        .withValues(alpha: 0.08),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCover(BuildContext context) {
    if (widget.book.coverBase64 != null && widget.book.coverBase64!.isNotEmpty) {
      try {
        return Stack(
          fit: StackFit.expand,
          children: [
            Image.memory(
              base64Decode(widget.book.coverBase64!),
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _buildPlaceholderCover(context),
            ),
            _buildCoverOverlay(),
          ],
        );
      } catch (_) {
        return _buildPlaceholderCover(context);
      }
    }
    return _buildPlaceholderCover(context);
  }

  Widget _buildCoverOverlay() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      height: 40,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, Colors.black.withValues(alpha: 0.3)],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderCover(BuildContext context) {
    final colors = _gradientForBook();
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -20,
            right: -20,
            child: Transform.rotate(
              angle: pi / 6,
              child: Icon(
                _formatIcon(widget.book.format),
                size: 80,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _formatIcon(widget.book.format),
                  size: 36,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    widget.book.title,
                    maxLines: 3,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      letterSpacing: -0.2,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
