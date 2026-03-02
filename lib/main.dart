import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/storage_service.dart';
import 'providers/library_provider.dart';
import 'providers/reader_provider.dart';
import 'providers/chat_provider.dart';
import 'providers/notes_provider.dart';
import 'providers/markup_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/reader_settings_provider.dart';
import 'config/theme.dart';
import 'screens/library/library_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.initialize();

  runApp(const GlyphetApp());
}

/// Root application widget with multi-provider state management.
class GlyphetApp extends StatelessWidget {
  const GlyphetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()..loadTheme()),
        ChangeNotifierProvider(
            create: (_) => ReaderSettingsProvider()..loadSettings()),
        ChangeNotifierProvider(create: (_) => LibraryProvider()),
        ChangeNotifierProvider(create: (_) => ReaderProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => NotesProvider()),
        ChangeNotifierProvider(create: (_) => MarkupProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'Glyphet',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode:
                themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: const LibraryScreen(),
          );
        },
      ),
    );
  }
}
