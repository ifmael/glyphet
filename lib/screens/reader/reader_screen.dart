import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/book.dart';
import '../../providers/reader_provider.dart';
import '../../providers/reader_settings_provider.dart';
import '../../providers/chat_provider.dart';
import '../../providers/notes_provider.dart';
import '../../providers/library_provider.dart';
import '../chat/chat_panel.dart';
import '../notes/notes_screen.dart';
import 'epub_reader_view.dart';
import 'pdf_reader_view.dart';
import 'reader_settings_sheet.dart';

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
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(Icons.note_add_rounded,
                  color: Theme.of(context).colorScheme.primary, size: 22),
              const SizedBox(width: 8),
              const Text('Save Note'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.08),
                  border: const Border(
                    left: BorderSide(color: Colors.amber, width: 3),
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  text.length > 200 ? '${text.substring(0, 200)}...' : text,
                  style: const TextStyle(
                      fontStyle: FontStyle.italic, fontSize: 13, height: 1.5),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  labelText: 'Your note',
                  hintText: 'Write your thoughts...',
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

  void _openSettings() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.4,
        maxChildSize: 0.92,
        builder: (_, scrollController) =>
            const SingleChildScrollView(child: ReaderSettingsSheet()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ReaderProvider, ReaderSettingsProvider>(
      builder: (context, reader, settings, _) {
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
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () {
                context.read<LibraryProvider>().updateProgress(
                      book.id,
                      reader.currentChapter /
                          (reader.chapters.length.clamp(1, 999999)),
                      reader.currentChapter,
                    );
                reader.closeBook();
                Navigator.pop(context);
              },
            ),
            actions: [
              if (book.format == BookFormat.epub)
                IconButton(
                  icon: Icon(
                    _showChapters
                        ? Icons.view_list_rounded
                        : Icons.list_rounded,
                    color: _showChapters
                        ? Theme.of(context).colorScheme.primary
                        : null,
                  ),
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
                  _showChat
                      ? Icons.chat_rounded
                      : Icons.chat_bubble_outline_rounded,
                  color: _showChat
                      ? Theme.of(context).colorScheme.primary
                      : null,
                ),
                onPressed: () => setState(() => _showChat = !_showChat),
                tooltip: 'AI Chat',
              ),
              IconButton(
                icon: const Icon(Icons.tune_rounded),
                onPressed: _openSettings,
                tooltip: 'Reading Settings',
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
              ? _buildChapterNav(reader, settings)
              : null,
        );
      },
    );
  }

  Widget _buildChapterList(ReaderProvider reader) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          right: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Chapters',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 4),
              itemCount: reader.chapters.length,
              itemBuilder: (context, index) {
                final isSelected = index == reader.currentChapter;
                return ListTile(
                  dense: true,
                  selected: isSelected,
                  selectedTileColor: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.08),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                  leading: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isSelected
                              ? Colors.white
                              : Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  ),
                  title: Text(
                    reader.chapters[index].title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : null,
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
            Icon(Icons.warning_amber_rounded, size: 48, color: Colors.orange),
            SizedBox(height: 12),
            Text('MOBI format reader coming soon'),
            Text('Convert to EPUB for the best experience'),
          ],
        ),
      );
    }
  }

  Widget _buildChapterNav(
      ReaderProvider reader, ReaderSettingsProvider settings) {
    final theme = settings.theme;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: theme.navBarColor,
        border: Border(
          top: BorderSide(
            color: theme.textColor.withValues(alpha: 0.08),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton.icon(
            onPressed:
                reader.currentChapter > 0 ? reader.previousChapter : null,
            icon: Icon(Icons.chevron_left_rounded,
                color: reader.currentChapter > 0
                    ? theme.accentColor
                    : theme.navBarTextColor.withValues(alpha: 0.3)),
            label: Text('Previous',
                style: TextStyle(
                  color: reader.currentChapter > 0
                      ? theme.accentColor
                      : theme.navBarTextColor.withValues(alpha: 0.3),
                  fontWeight: FontWeight.w500,
                )),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: theme.accentColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${reader.currentChapter + 1} / ${reader.chapters.length}',
              style: TextStyle(
                color: theme.navBarTextColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton.icon(
            onPressed: reader.currentChapter < reader.chapters.length - 1
                ? reader.nextChapter
                : null,
            icon: Icon(Icons.chevron_right_rounded,
                color: reader.currentChapter < reader.chapters.length - 1
                    ? theme.accentColor
                    : theme.navBarTextColor.withValues(alpha: 0.3)),
            label: Text('Next',
                style: TextStyle(
                  color: reader.currentChapter < reader.chapters.length - 1
                      ? theme.accentColor
                      : theme.navBarTextColor.withValues(alpha: 0.3),
                  fontWeight: FontWeight.w500,
                )),
          ),
        ],
      ),
    );
  }
}
