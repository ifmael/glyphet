import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/book.dart';
import '../../providers/reader_provider.dart';
import '../../providers/chat_provider.dart';
import '../../providers/notes_provider.dart';
import '../../providers/library_provider.dart';
import '../chat/chat_panel.dart';
import '../notes/notes_screen.dart';
import 'epub_reader_view.dart';
import 'pdf_reader_view.dart';

/// Main reader screen that displays book content with chat and notes panels.
class ReaderScreen extends StatefulWidget {
  const ReaderScreen({super.key});

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> {
  bool _showChat = false;
  bool _showChapters = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final reader = context.read<ReaderProvider>();
      if (reader.currentBook != null) {
        context.read<ChatProvider>().loadMessages(reader.currentBook!.id);
        context.read<NotesProvider>().loadNotes(bookId: reader.currentBook!.id);
      }
    });
  }

  void _sendToChat(String text) {
    final reader = context.read<ReaderProvider>();
    reader.setSelectedText(text);
    setState(() => _showChat = true);
  }

  void _saveNote(String text) {
    final reader = context.read<ReaderProvider>();
    if (reader.currentBook == null) return;

    showDialog(
      context: context,
      builder: (ctx) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text('Save Note'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.1),
                  border: const Border(
                    left: BorderSide(color: Colors.amber, width: 3),
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  text.length > 200 ? '${text.substring(0, 200)}...' : text,
                  style: const TextStyle(
                      fontStyle: FontStyle.italic, fontSize: 13),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  labelText: 'Your note',
                  hintText: 'Write your thoughts...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                context.read<NotesProvider>().addNote(
                      bookId: reader.currentBook!.id,
                      selectedText: text,
                      content: controller.text,
                      chapterIndex: reader.currentChapter,
                    );
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Note saved!'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ReaderProvider>(
      builder: (context, reader, _) {
        if (reader.isLoading) {
          return Scaffold(
            appBar: AppBar(title: const Text('Loading...')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        final book = reader.currentBook;
        if (book == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Reader')),
            body: const Center(child: Text('No book loaded')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(
              book.title,
              overflow: TextOverflow.ellipsis,
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                context.read<LibraryProvider>().updateProgress(
                      book.id,
                      reader.currentChapter / (reader.chapters.length.clamp(1, 999999)),
                      reader.currentChapter,
                    );
                reader.closeBook();
                Navigator.pop(context);
              },
            ),
            actions: [
              if (book.format == BookFormat.epub)
                IconButton(
                  icon: const Icon(Icons.list),
                  onPressed: () =>
                      setState(() => _showChapters = !_showChapters),
                  tooltip: 'Chapters',
                ),
              IconButton(
                icon: const Icon(Icons.note_alt_outlined),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => NotesScreen(bookId: book.id),
                  ),
                ),
                tooltip: 'Book Notes',
              ),
              IconButton(
                icon: Icon(
                  _showChat ? Icons.chat : Icons.chat_outlined,
                  color: _showChat
                      ? Theme.of(context).colorScheme.primary
                      : null,
                ),
                onPressed: () => setState(() => _showChat = !_showChat),
                tooltip: 'AI Chat',
              ),
              if (book.format == BookFormat.epub)
                PopupMenuButton<double>(
                  icon: const Icon(Icons.text_fields),
                  tooltip: 'Font Size',
                  onSelected: reader.setFontSize,
                  itemBuilder: (_) => [14.0, 16.0, 18.0, 20.0, 24.0, 28.0]
                      .map((s) => PopupMenuItem(
                            value: s,
                            child: Text('${s.toInt()}px',
                                style: TextStyle(
                                  fontWeight: s == reader.fontSize
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                )),
                          ))
                      .toList(),
                ),
            ],
          ),
          body: Row(
            children: [
              if (_showChapters && book.format == BookFormat.epub)
                SizedBox(
                  width: 280,
                  child: _buildChapterList(reader),
                ),
              Expanded(
                child: _buildReaderContent(book, reader),
              ),
              if (_showChat)
                SizedBox(
                  width: MediaQuery.of(context).size.width > 800 ? 380 : 320,
                  child: ChatPanel(
                    bookId: book.id,
                    chapterContext: reader.currentChapterText,
                    selectedText: reader.selectedText,
                    onClose: () => setState(() => _showChat = false),
                  ),
                ),
            ],
          ),
          bottomNavigationBar: book.format == BookFormat.epub
              ? _buildChapterNav(reader)
              : null,
        );
      },
    );
  }

  Widget _buildChapterList(ReaderProvider reader) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(
            color: Theme.of(context).dividerColor,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              'Chapters',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              itemCount: reader.chapters.length,
              itemBuilder: (context, index) {
                final isSelected = index == reader.currentChapter;
                return ListTile(
                  dense: true,
                  selected: isSelected,
                  selectedTileColor: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.1),
                  leading: Text(
                    '${index + 1}',
                    style: TextStyle(
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : null,
                    ),
                  ),
                  title: Text(
                    reader.chapters[index].title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  onTap: () => reader.goToChapter(index),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReaderContent(Book book, ReaderProvider reader) {
    if (book.format == BookFormat.epub) {
      return EpubReaderView(
        onTextSelected: (text) {
          reader.setSelectedText(text);
        },
        onSendToChat: _sendToChat,
        onSaveNote: _saveNote,
      );
    } else if (book.format == BookFormat.pdf) {
      return PdfReaderView(
        onSendToChat: _sendToChat,
        onSaveNote: _saveNote,
      );
    } else {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.warning_amber, size: 48, color: Colors.orange),
            SizedBox(height: 12),
            Text('MOBI format reader coming soon'),
            Text('Convert to EPUB for the best experience'),
          ],
        ),
      );
    }
  }

  Widget _buildChapterNav(ReaderProvider reader) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton.icon(
            onPressed:
                reader.currentChapter > 0 ? reader.previousChapter : null,
            icon: const Icon(Icons.chevron_left),
            label: const Text('Previous'),
          ),
          Text(
            'Chapter ${reader.currentChapter + 1} / ${reader.chapters.length}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          TextButton.icon(
            onPressed: reader.currentChapter < reader.chapters.length - 1
                ? reader.nextChapter
                : null,
            icon: const Icon(Icons.chevron_right),
            label: const Text('Next'),
          ),
        ],
      ),
    );
  }
}
