import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import '../../providers/reader_provider.dart';
import '../../providers/reader_settings_provider.dart';

/// Renders EPUB chapter content with customizable reading themes.
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
    return Consumer2<ReaderProvider, ReaderSettingsProvider>(
      builder: (context, reader, settings, _) {
        final chapter = reader.currentChapterContent;
        if (chapter == null) {
          return Center(
            child: Text(
              'No content available',
              style: TextStyle(color: settings.theme.textColor),
            ),
          );
        }

        final styledHtml = _wrapWithStyles(
          chapter.htmlContent,
          settings,
        );

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          color: settings.theme.backgroundColor,
          child: SelectionArea(
            contextMenuBuilder: (context, selectableRegionState) {
              return _buildContextMenu(context, selectableRegionState);
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
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: settings.theme.textColor.withValues(alpha: 0.12),
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

  Widget _buildContextMenu(
      BuildContext context, SelectableRegionState selectableRegionState) {
    final actions = selectableRegionState.contextMenuButtonItems;
    return AdaptiveTextSelectionToolbar(
      anchors: selectableRegionState.contextMenuAnchors,
      children: [
        ...actions.map((item) => _buildToolbarButton(
              item.label ?? '',
              item.onPressed,
            )),
        _buildToolbarButton('Ask AI', () {
          final reader = context.read<ReaderProvider>();
          final text = reader.selectedText;
          if (text.isNotEmpty) onSendToChat(text);
          selectableRegionState.hideToolbar();
        }),
        _buildToolbarButton('Save Note', () {
          final reader = context.read<ReaderProvider>();
          final text = reader.selectedText;
          if (text.isNotEmpty) onSaveNote(text);
          selectableRegionState.hideToolbar();
        }),
      ],
    );
  }

  Widget _buildToolbarButton(String label, VoidCallback? onPressed) {
    return TextSelectionToolbarTextButton(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      onPressed: onPressed,
      child: Text(label),
    );
  }

  String _wrapWithStyles(String html, ReaderSettingsProvider settings) {
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
      ">$html</div>
    ''';
  }

  String _colorToHex(Color color) {
    final r = (color.r * 255).round();
    final g = (color.g * 255).round();
    final b = (color.b * 255).round();
    return '#${r.toRadixString(16).padLeft(2, '0')}${g.toRadixString(16).padLeft(2, '0')}${b.toRadixString(16).padLeft(2, '0')}';
  }
}
