import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../../providers/library_provider.dart';
import '../../providers/reader_provider.dart';
import '../../providers/theme_provider.dart';
import '../../models/book.dart';
import '../reader/reader_screen.dart';
import '../notes/notes_screen.dart';
import '../settings/settings_screen.dart';
import 'widgets/book_card.dart';

/// Main library screen showing the user's book collection.
class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LibraryProvider>().loadBooks();
    });
  }

  Future<void> _importBook() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['epub', 'pdf', 'mobi'],
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (file.bytes != null) {
          if (!mounted) return;
          await context.read<LibraryProvider>().importBook(
                fileName: file.name,
                fileBytes: file.bytes!,
              );
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Book imported successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error importing book: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _openBook(Book book) async {
    final libraryProvider = context.read<LibraryProvider>();
    final readerProvider = context.read<ReaderProvider>();

    final bytes = await libraryProvider.getBookBytes(book.id);
    if (bytes == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not load book data')),
      );
      return;
    }

    await readerProvider.openBook(book, bytes);
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ReaderScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.auto_stories, size: 28),
            SizedBox(width: 8),
            Text('Glyphet'),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(themeProvider.isDarkMode
                ? Icons.light_mode
                : Icons.dark_mode),
            onPressed: () => themeProvider.toggleTheme(),
            tooltip: 'Toggle theme',
          ),
          IconButton(
            icon: const Icon(Icons.note_alt_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NotesScreen()),
            ),
            tooltip: 'All Notes',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
            tooltip: 'Settings',
          ),
        ],
      ),
      body: Consumer<LibraryProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.books.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.library_books_outlined,
                    size: 80,
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Your library is empty',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap + to import an EPUB, PDF, or MOBI file',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.6),
                        ),
                  ),
                ],
              ),
            );
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth > 900
                  ? 4
                  : constraints.maxWidth > 600
                      ? 3
                      : 2;

              return GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  childAspectRatio: 0.65,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: provider.books.length,
                itemBuilder: (context, index) {
                  final book = provider.books[index];
                  return BookCard(
                    book: book,
                    onTap: () => _openBook(book),
                    onDelete: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Delete Book'),
                          content: Text(
                              'Remove "${book.title}" from your library?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              child: const Text('Delete',
                                  style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        provider.deleteBook(book.id);
                      }
                    },
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _importBook,
        icon: const Icon(Icons.add),
        label: const Text('Import Book'),
      ),
    );
  }
}
