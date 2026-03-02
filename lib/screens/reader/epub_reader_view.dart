import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import '../../models/text_markup.dart';
import '../../providers/reader_provider.dart';
import '../../providers/reader_settings_provider.dart';
import '../../providers/markup_provider.dart';

/// Renders EPUB chapter content with customizable reading themes
/// and a rich context menu for text interaction.
class EpubReaderView extends StatelessWidget {
  final ValueChanged<String> onTextSelected;
  final ValueChanged<String> onSendToChat;
  final ValueChanged<String> onSaveNote;

  const EpubReaderView({
    super.key,
    required this.onTextSelected,
    required this.onSendToChat,
    required this.onSaveNote,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer3<ReaderProvider, ReaderSettingsProvider, MarkupProvider>(
      builder: (context, reader, settings, markups, _) {
        final chapter = reader.currentChapterContent;
        if (chapter == null) {
          return Center(
            child: Text(
              'No content available',
              style: TextStyle(color: settings.theme.textColor),
            ),
          );
        }

        final chapterMarkups =
            markups.getChapterMarkups(reader.currentChapter);
        final styledHtml = _applyMarkupsToHtml(
          chapter.htmlContent,
          chapterMarkups,
          settings,
        );

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          color: settings.theme.backgroundColor,
          child: SelectionArea(
            contextMenuBuilder: (ctx, selectableRegionState) {
              return _CustomContextMenu(
                selectableRegionState: selectableRegionState,
                onCopy: () {
                  // Trigger the built-in copy action
                  final copyItem = selectableRegionState
                      .contextMenuButtonItems
                      .where((item) =>
                          item.type == ContextMenuButtonType.copy)
                      .firstOrNull;
                  copyItem?.onPressed?.call();
                  selectableRegionState.hideToolbar();
                },
                onHighlight: () {
                  final text = reader.selectedText;
                  if (text.isNotEmpty && reader.currentBook != null) {
                    markups.addMarkup(
                      bookId: reader.currentBook!.id,
                      chapterIndex: reader.currentChapter,
                      text: text,
                      type: MarkupType.highlight,
                    );
                  }
                  selectableRegionState.hideToolbar();
                },
                onUnderline: () {
                  final text = reader.selectedText;
                  if (text.isNotEmpty && reader.currentBook != null) {
                    markups.addMarkup(
                      bookId: reader.currentBook!.id,
                      chapterIndex: reader.currentChapter,
                      text: text,
                      type: MarkupType.underline,
                    );
                  }
                  selectableRegionState.hideToolbar();
                },
                onAskAI: () {
                  final text = reader.selectedText;
                  if (text.isNotEmpty) onSendToChat(text);
                  selectableRegionState.hideToolbar();
                },
                onSaveNote: () {
                  final text = reader.selectedText;
                  if (text.isNotEmpty) onSaveNote(text);
                  selectableRegionState.hideToolbar();
                },
              );
            },
            onSelectionChanged: (selection) {
              if (selection != null) {
                final text = selection.plainText;
                if (text.isNotEmpty) {
                  onTextSelected(text);
                }
              }
            },
            child: SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: settings.theme.textColor
                              .withValues(alpha: 0.12),
                          width: 0.5,
                        ),
                      ),
                    ),
                    child: Text(
                      chapter.title,
                      style: GoogleFonts.getFont(
                        settings.fontFamily,
                        fontSize: settings.fontSize * 1.4,
                        fontWeight: FontWeight.w700,
                        color: settings.theme.chapterTitleColor,
                        letterSpacing: -0.5,
                        height: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  HtmlWidget(
                    styledHtml,
                    textStyle: GoogleFonts.getFont(
                      settings.fontFamily,
                      fontSize: settings.fontSize,
                      height: settings.lineHeight,
                      color: settings.effectiveTextColor,
                    ),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Wraps HTML with inline styles and injects highlight/underline <mark> spans.
  String _applyMarkupsToHtml(
    String html,
    List<TextMarkup> markups,
    ReaderSettingsProvider settings,
  ) {
    var processed = html;

    for (final markup in markups) {
      final escaped = _escapeHtml(markup.text);
      if (escaped.isEmpty) continue;

      String replacement;
      if (markup.type == MarkupType.highlight) {
        replacement =
            '<mark style="background-color: rgba(255,213,79,0.35); color: inherit; padding: 1px 0;">$escaped</mark>';
      } else {
        replacement =
            '<mark style="text-decoration: underline; text-decoration-color: rgba(129,199,132,0.8); text-underline-offset: 3px; background: transparent; color: inherit;">$escaped</mark>';
      }

      processed = processed.replaceAll(escaped, replacement);
    }

    final textColor = _colorToHex(settings.effectiveTextColor);
    final bgColor = _colorToHex(settings.theme.backgroundColor);

    return '''
      <div style="
        font-size: ${settings.fontSize}px;
        line-height: ${settings.lineHeight};
        color: $textColor;
        background-color: $bgColor;
        max-width: 760px;
        margin: 0 auto;
        word-spacing: 0.5px;
        letter-spacing: 0.2px;
      ">$processed</div>
    ''';
  }

  String _escapeHtml(String text) {
    return text
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;');
  }

  String _colorToHex(Color color) {
    final r = (color.r * 255).round();
    final g = (color.g * 255).round();
    final b = (color.b * 255).round();
    return '#${r.toRadixString(16).padLeft(2, '0')}${g.toRadixString(16).padLeft(2, '0')}${b.toRadixString(16).padLeft(2, '0')}';
  }
}

/// A visually rich custom context menu that appears when text is selected.
class _CustomContextMenu extends StatelessWidget {
  final SelectableRegionState selectableRegionState;
  final VoidCallback onCopy;
  final VoidCallback onHighlight;
  final VoidCallback onUnderline;
  final VoidCallback onAskAI;
  final VoidCallback onSaveNote;

  const _CustomContextMenu({
    required this.selectableRegionState,
    required this.onCopy,
    required this.onHighlight,
    required this.onUnderline,
    required this.onAskAI,
    required this.onSaveNote,
  });

  @override
  Widget build(BuildContext context) {
    final anchor = selectableRegionState.contextMenuAnchors.primaryAnchor;

    return Stack(
      children: [
        Positioned(
          left: (anchor.dx - 170).clamp(8.0, MediaQuery.of(context).size.width - 348),
          top: (anchor.dy - 60).clamp(8.0, MediaQuery.of(context).size.height - 70),
          child: Material(
            elevation: 8,
            shadowColor: Colors.black26,
            borderRadius: BorderRadius.circular(14),
            color: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF2A2A3E)
                : Colors.white,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _MenuAction(
                    icon: Icons.copy_rounded,
                    label: 'Copy',
                    color: const Color(0xFF78909C),
                    onTap: onCopy,
                  ),
                  _separator(context),
                  _MenuAction(
                    icon: Icons.highlight_rounded,
                    label: 'Highlight',
                    color: const Color(0xFFFFC107),
                    onTap: onHighlight,
                  ),
                  _separator(context),
                  _MenuAction(
                    icon: Icons.format_underlined_rounded,
                    label: 'Underline',
                    color: const Color(0xFF66BB6A),
                    onTap: onUnderline,
                  ),
                  _separator(context),
                  _MenuAction(
                    icon: Icons.smart_toy_rounded,
                    label: 'Ask AI',
                    color: const Color(0xFF7C4DFF),
                    onTap: onAskAI,
                  ),
                  _separator(context),
                  _MenuAction(
                    icon: Icons.note_add_rounded,
                    label: 'Note',
                    color: const Color(0xFF42A5F5),
                    onTap: onSaveNote,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _separator(BuildContext context) {
    return Container(
      width: 1,
      height: 28,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
    );
  }
}

/// A single action button inside the context menu.
class _MenuAction extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _MenuAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  State<_MenuAction> createState() => _MenuActionState();
}

class _MenuActionState extends State<_MenuAction> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: _hovering
                ? widget.color.withValues(alpha: 0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, size: 20, color: widget.color),
              const SizedBox(height: 3),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
