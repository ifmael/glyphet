import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pdfrx/pdfrx.dart';
import '../../providers/reader_provider.dart';

/// Renders PDF documents with navigation controls.
class PdfReaderView extends StatefulWidget {
  final ValueChanged<String> onSendToChat;
  final ValueChanged<String> onSaveNote;

  const PdfReaderView({
    super.key,
    required this.onSendToChat,
    required this.onSaveNote,
  });

  @override
  State<PdfReaderView> createState() => _PdfReaderViewState();
}

class _PdfReaderViewState extends State<PdfReaderView> {
  final PdfViewerController _controller = PdfViewerController();
  final TextEditingController _textInput = TextEditingController();

  @override
  void dispose() {
    _textInput.dispose();
    super.dispose();
  }

  void _showTextActions() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Enter or paste text from the PDF',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _textInput,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText:
                      'Paste or type the text you want to interact with...',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        if (_textInput.text.isNotEmpty) {
                          widget.onSaveNote(_textInput.text);
                          Navigator.pop(ctx);
                        }
                      },
                      icon: const Icon(Icons.note_add),
                      label: const Text('Save Note'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () {
                        if (_textInput.text.isNotEmpty) {
                          widget.onSendToChat(_textInput.text);
                          Navigator.pop(ctx);
                        }
                      },
                      icon: const Icon(Icons.chat),
                      label: const Text('Ask AI'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ReaderProvider>(
      builder: (context, reader, _) {
        if (reader.pdfBytes == null) {
          return const Center(child: Text('No PDF data available'));
        }

        return Stack(
          children: [
            PdfViewer.data(
              reader.pdfBytes!,
              sourceName: 'book.pdf',
              controller: _controller,
              params: const PdfViewerParams(
                enableTextSelection: true,
                maxScale: 5.0,
              ),
            ),
            Positioned(
              bottom: 16,
              right: 16,
              child: FloatingActionButton(
                mini: true,
                onPressed: _showTextActions,
                tooltip: 'Text Actions',
                child: const Icon(Icons.text_snippet),
              ),
            ),
          ],
        );
      },
    );
  }
}
