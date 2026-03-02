# Glyphet

Lector de ebooks multiplataforma (Android, iOS y Web) con chatbot de inteligencia artificial integrado y sistema de notas.

Glyphet te permite leer archivos **EPUB**, **PDF** y **MOBI**, seleccionar fragmentos de texto para hacerle preguntas a un asistente AI y guardar notas personales sobre lo que lees.

![Flutter](https://img.shields.io/badge/Flutter-3.41+-blue?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.11+-blue?logo=dart)
![License](https://img.shields.io/badge/License-MIT-green)
![Platforms](https://img.shields.io/badge/Platforms-Android%20%7C%20iOS%20%7C%20Web-orange)

---

## Características

- **Lector EPUB** — Renderizado HTML con navegación por capítulos, selección de texto y tamaño de fuente ajustable.
- **Lector PDF** — Visualización con zoom, desplazamiento libre y selección de texto.
- **Soporte MOBI** — Importación de archivos (conversión a EPUB recomendada para mejor experiencia).
- **Chatbot AI** — Panel lateral integrado donde puedes seleccionar texto o capítulos completos y hacerle preguntas al asistente (usa la API de OpenAI).
- **Sistema de notas** — Guarda, edita y elimina notas asociadas a fragmentos de texto seleccionados.
- **Biblioteca personal** — Importa y organiza tus libros con portadas automáticas, progreso de lectura y metadatos.
- **Tema claro/oscuro** — Cambia entre modo claro y oscuro según tu preferencia.
- **Almacenamiento local** — Todos los datos (libros, notas, conversaciones, configuración) se guardan localmente con Hive.

---

## Requisitos previos

| Herramienta | Versión mínima | Instalación |
|-------------|---------------|-------------|
| **Flutter SDK** | 3.41+ | [flutter.dev/docs/get-started/install](https://docs.flutter.dev/get-started/install) |
| **Dart SDK** | 3.11+ | Incluido con Flutter |
| **Git** | cualquiera | [git-scm.com](https://git-scm.com/) |

### Requisitos adicionales por plataforma

| Plataforma | Requisitos |
|------------|-----------|
| **Android** | Android Studio + Android SDK (API 21+) |
| **iOS** | macOS + Xcode 15+ + CocoaPods |
| **Web** | Google Chrome (o cualquier navegador moderno) |

> **Nota:** Para verificar que Flutter está correctamente instalado, ejecuta `flutter doctor` y asegúrate de que no haya errores críticos para la plataforma que deseas usar.

---

## Instalación

### 1. Clonar el repositorio

```bash
git clone https://github.com/ifmael/glyphet.git
cd glyphet
```

### 2. Instalar dependencias

```bash
flutter pub get
```

### 3. Verificar que todo está correcto

```bash
flutter doctor
flutter analyze
```

Si `flutter analyze` muestra **"No issues found!"**, estás listo para ejecutar la app.

---

## Ejecución

### Web (la forma más rápida de probar)

```bash
flutter run -d chrome
```

O si prefieres generar un build y servirlo manualmente:

```bash
flutter build web --release
cd build/web
python3 -m http.server 8080
```

Luego abre [http://localhost:8080](http://localhost:8080) en tu navegador.

### Android

```bash
# Con un emulador o dispositivo conectado
flutter run -d android
```

Para generar un APK:

```bash
flutter build apk --release
# El APK estará en build/app/outputs/flutter-apk/app-release.apk
```

### iOS (solo macOS)

```bash
cd ios && pod install && cd ..
flutter run -d ios
```

---

## Configuración

### Clave de API de OpenAI (para el chatbot)

El chatbot AI necesita una clave de API de OpenAI para funcionar. Para configurarla:

1. Obtén una clave en [platform.openai.com/api-keys](https://platform.openai.com/api-keys).
2. Abre la app y ve a **Settings** (icono de engranaje ⚙️ en la esquina superior derecha).
3. En la sección **OpenAI API Key**, pega tu clave (comienza con `sk-...`).
4. Pulsa el icono de guardar 💾.

> La clave se almacena **únicamente en tu dispositivo** de forma local. Nunca se envía a ningún servidor excepto a la API de OpenAI cuando usas el chatbot.

### Tema claro/oscuro

- Desde la pantalla principal, pulsa el icono de luna/sol 🌙 en la barra superior.
- O ve a **Settings → Appearance → Dark Mode** y activa/desactiva el interruptor.

---

## Uso

### Importar un libro

1. En la pantalla de **Biblioteca**, pulsa el botón **"+ Import Book"** (esquina inferior derecha).
2. Selecciona un archivo `.epub`, `.pdf` o `.mobi` desde tu dispositivo.
3. El libro aparecerá en la biblioteca con su título, autor y formato detectados automáticamente.

### Leer un libro

1. Pulsa sobre la portada del libro en la biblioteca.
2. **Para EPUB:**
   - Usa los botones **Previous / Next** en la barra inferior para cambiar de capítulo.
   - Pulsa el icono de lista 📋 para ver el índice de capítulos.
   - Pulsa el icono **Tt** para cambiar el tamaño de fuente.
3. **Para PDF:**
   - Navega con scroll y pellizco para zoom.
   - Pulsa el botón flotante 📝 para escribir o pegar texto y enviarlo al chat o guardarlo como nota.

### Seleccionar texto y usar el chatbot

1. Mientras lees un EPUB, selecciona un fragmento de texto arrastrando sobre él.
2. En el menú contextual que aparece, elige:
   - **"Ask AI"** — Envía el texto seleccionado al chatbot para hacerle preguntas.
   - **"Save Note"** — Guarda el fragmento como una nota con tus comentarios.
3. El panel de chat se abre a la derecha. Escribe tu pregunta y pulsa enviar.
4. El asistente AI responderá usando el contexto del capítulo actual y el texto seleccionado.

### Gestionar notas

1. Pulsa el icono de notas 📝 en la barra superior del lector para ver las notas del libro actual.
2. Desde la biblioteca, pulsa el icono de notas para ver **todas** las notas de todos los libros.
3. Cada nota muestra el texto seleccionado original y tu comentario.
4. Puedes **editar** o **eliminar** notas con los iconos correspondientes.

### Eliminar un libro

1. En la biblioteca, pulsa el icono de papelera 🗑️ en la tarjeta del libro.
2. Confirma la eliminación en el diálogo.

---

## Estructura del proyecto

```
lib/
├── main.dart                       # Punto de entrada de la aplicación
├── config/
│   └── theme.dart                  # Tema claro/oscuro (Material 3)
├── models/
│   ├── book.dart                   # Modelo de libro
│   ├── note.dart                   # Modelo de nota
│   └── chat_message.dart           # Modelo de mensaje de chat
├── services/
│   ├── storage_service.dart        # Persistencia local con Hive
│   ├── ai_service.dart             # Comunicación con API de OpenAI
│   └── book_parser.dart            # Parser de archivos EPUB
├── providers/
│   ├── library_provider.dart       # Estado de la biblioteca
│   ├── reader_provider.dart        # Estado del lector
│   ├── chat_provider.dart          # Estado del chatbot
│   ├── notes_provider.dart         # Estado de las notas
│   └── theme_provider.dart         # Estado del tema
├── screens/
│   ├── library/
│   │   ├── library_screen.dart     # Pantalla principal de biblioteca
│   │   └── widgets/
│   │       └── book_card.dart      # Tarjeta de libro en el grid
│   ├── reader/
│   │   ├── reader_screen.dart      # Pantalla principal del lector
│   │   ├── epub_reader_view.dart   # Vista de lectura EPUB
│   │   └── pdf_reader_view.dart    # Vista de lectura PDF
│   ├── chat/
│   │   └── chat_panel.dart         # Panel lateral del chatbot
│   ├── notes/
│   │   └── notes_screen.dart       # Pantalla de gestión de notas
│   └── settings/
│       └── settings_screen.dart    # Pantalla de configuración
```

---

## Dependencias principales

| Paquete | Uso |
|---------|-----|
| [`provider`](https://pub.dev/packages/provider) | Gestión de estado reactiva |
| [`epubx`](https://pub.dev/packages/epubx) | Parsing de archivos EPUB |
| [`pdfrx`](https://pub.dev/packages/pdfrx) | Visualización de archivos PDF |
| [`flutter_widget_from_html_core`](https://pub.dev/packages/flutter_widget_from_html_core) | Renderizado de HTML (contenido EPUB) |
| [`hive_flutter`](https://pub.dev/packages/hive_flutter) | Base de datos local (funciona en web) |
| [`file_picker`](https://pub.dev/packages/file_picker) | Selector de archivos nativo |
| [`http`](https://pub.dev/packages/http) | Peticiones HTTP (API de OpenAI) |
| [`google_fonts`](https://pub.dev/packages/google_fonts) | Tipografías (Nunito) |

---

## Tests

```bash
# Ejecutar todos los tests
flutter test

# Análisis estático (linting)
flutter analyze
```

---

## Comandos útiles

| Comando | Descripción |
|---------|-------------|
| `flutter pub get` | Instalar dependencias |
| `flutter analyze` | Análisis estático del código |
| `flutter test` | Ejecutar tests |
| `flutter run -d chrome` | Ejecutar en Chrome (web) |
| `flutter run -d android` | Ejecutar en Android |
| `flutter run -d ios` | Ejecutar en iOS |
| `flutter build web` | Build de producción para web |
| `flutter build apk` | Build de producción para Android |
| `flutter build ios` | Build de producción para iOS |

---

## Solución de problemas

### "Box not found" al ejecutar tests

Los tests necesitan inicializar Hive manualmente. Asegúrate de que el `setUp` del test incluya:

```dart
final dir = Directory.systemTemp.createTempSync('hive_test');
Hive.init(dir.path);
await Hive.openBox('books');
await Hive.openBox('notes');
await Hive.openBox('chat_messages');
await Hive.openBox('settings');
```

### El chatbot responde "Please configure your OpenAI API key"

Ve a **Settings** y configura tu clave de API de OpenAI. Consulta la sección [Configuración](#configuración).

### El archivo MOBI no se abre

Actualmente el soporte de MOBI es limitado. Se recomienda convertir el archivo a EPUB usando herramientas como [Calibre](https://calibre-ebook.com/) para la mejor experiencia de lectura.

### Error al importar archivos en web

Asegúrate de que el archivo no exceda el límite de memoria del navegador. Para archivos grandes (>50 MB), se recomienda usar la versión nativa (Android/iOS).

---

## Licencia

Este proyecto está bajo la licencia MIT. Consulta el archivo [LICENSE](LICENSE) para más detalles.
