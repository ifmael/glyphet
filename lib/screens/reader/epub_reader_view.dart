import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import '../../providers/reader_provider.dart';

/// Renders EPUB chapter content as styled HTML with text selection support.
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
    return Consumer<ReaderProvider>(
      builder: (context, reader, _) {
        final chapter = reader.currentChapterContent;
        if (chapter == null) {
          return const Center(child: Text('No content available'));
        }

        final styledHtml = _wrapWithStyles(chapter.htmlContent, reader.fontSize, context);

        return SelectionArea(
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
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(bottom: 16),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey, width: 0.5),
                    ),
                  ),
                  child: Text(
                    chapter.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                const SizedBox(height: 20),
                HtmlWidget(
                  styledHtml,
                  textStyle: TextStyle(
                    fontSize: reader.fontSize,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 60),
              ],
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

  String _wrapWithStyles(String html, double fontSize, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? '#E0E0E0' : '#333333';
    final bgColor = isDark ? '#1E1E1E' : '#FFFFFF';

    return '''
      <div style="
        font-size: ${fontSize}px;
        line-height: 1.8;
        color: $textColor;
        background-color: $bgColor;
        max-width: 800px;
        margin: 0 auto;
      ">$html</div>
    ''';
  }
}
