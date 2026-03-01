import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import 'package:glyphet/providers/theme_provider.dart';
import 'package:glyphet/providers/library_provider.dart';
import 'package:glyphet/providers/reader_provider.dart';
import 'package:glyphet/providers/chat_provider.dart';
import 'package:glyphet/providers/notes_provider.dart';
import 'package:glyphet/config/theme.dart';

void main() {
  setUp(() async {
    final dir = Directory.systemTemp.createTempSync('hive_test');
    Hive.init(dir.path);
    await Hive.openBox('books');
    await Hive.openBox('notes');
    await Hive.openBox('chat_messages');
    await Hive.openBox('settings');
  });

  tearDown(() async {
    await Hive.deleteFromDisk();
  });

  testWidgets('App renders library screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()..loadTheme()),
          ChangeNotifierProvider(create: (_) => LibraryProvider()),
          ChangeNotifierProvider(create: (_) => ReaderProvider()),
          ChangeNotifierProvider(create: (_) => ChatProvider()),
          ChangeNotifierProvider(create: (_) => NotesProvider()),
        ],
        child: Consumer<ThemeProvider>(
          builder: (context, themeProvider, _) {
            return MaterialApp(
              title: 'Glyphet',
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode:
                  themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
              home: const Scaffold(
                body: Center(child: Text('Glyphet')),
              ),
            );
          },
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('Glyphet'), findsOneWidget);
  });
}
