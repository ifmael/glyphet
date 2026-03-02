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
- **8 proveedores de IA** — OpenAI, Anthropic (Claude), Google Gemini, Mistral, DeepSeek, Groq, OpenRouter y Custom/Local (Ollama, LM Studio).
- **Menú contextual enriquecido** — Al seleccionar texto: Copiar, Destacar, Subrayar, Ask AI y Guardar Nota.
- **Highlights y subrayados** — Resalta texto en amarillo o subráyalo en verde, persistido por libro y capítulo.
- **Sistema de notas** — Guarda, edita y elimina notas asociadas a fragmentos de texto seleccionados.
- **Biblioteca personal** — Importa y organiza tus libros con portadas automáticas, progreso de lectura y metadatos.
- **6 temas de lectura** — Paper, Snow, Sepia, Dusk, Night y Midnight (del blanco puro al negro puro).
- **Personalización de tipografía** — 9 fuentes seleccionables, tamaño ajustable (12-36px), contraste e interlineado.
- **Tema claro/oscuro** — Cambia entre modo claro y oscuro para la interfaz de la app.
- **Almacenamiento local** — Todos los datos (libros, notas, conversaciones, configuración, highlights) se guardan localmente con Hive.

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
| **Android** | Android Studio + Android SDK (API 21+) + Java JDK 17 |
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

Si `flutter doctor` muestra problemas con Android toolchain, acepta las licencias:

```bash
flutter doctor --android-licenses
```

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

---

### Android

#### Opción A — Generar APK

```bash
# APK de debug (más rápido de compilar, ideal para pruebas)
flutter build apk --debug

# APK de release (optimizado, para distribuir)
flutter build apk --release
```

Los APK se generan en:

| Tipo | Ruta del archivo |
|------|-----------------|
| Debug | `build/app/outputs/flutter-apk/app-debug.apk` |
| Release | `build/app/outputs/flutter-apk/app-release.apk` |

Transfiere el APK a tu teléfono e instálalo directamente.

#### Opción B — Emulador de Android Studio

1. Abre **Android Studio**
2. Ve a **Tools → Device Manager** (o **More Actions → Virtual Device Manager**)
3. Pulsa **Create Virtual Device**
4. Elige un dispositivo (ej: **Pixel 8**)
5. Selecciona una imagen del sistema (ej: **API 34 - Android 14**)
6. Pulsa **Finish** y el botón ▶️ para arrancar el emulador
7. Ejecuta la app:

```bash
# Ver dispositivos disponibles (emuladores + físicos)
flutter devices

# Ejecutar en el emulador (se detecta automáticamente)
flutter run
```

> Flutter incluye **hot reload**: los cambios se aplican al instante al guardar un archivo (`r` en terminal para forzar, `R` para hot restart).

#### Opción C — Dispositivo físico Android (USB)

1. **Activa modo desarrollador** en tu teléfono:
   - Ve a **Ajustes → Acerca del teléfono**
   - Pulsa 7 veces sobre **Número de compilación**
   - Vuelve a **Ajustes → Opciones de desarrollador**
   - Activa **Depuración USB**
2. Conecta el teléfono por USB
3. Ejecuta:

```bash
flutter devices    # Verifica que detecta tu dispositivo
flutter run        # Lanza la app en el teléfono
```

#### Opción D — Wireless debugging (sin cable, Android 11+)

```bash
# 1. Activa "Depuración inalámbrica" en Opciones de desarrollador
# 2. Pulsa "Vincular dispositivo con código" para obtener IP y puerto

# Emparejar
adb pair <ip>:<puerto>

# Conectar
adb connect <ip>:<puerto>

# Ejecutar
flutter run
```

---

### iOS (solo macOS)

```bash
cd ios && pod install && cd ..
flutter run -d ios
```

Para generar un build de release:

```bash
flutter build ios --release
```

---

## Configuración

### Proveedores de IA (para el chatbot)

Glyphet soporta **8 proveedores de IA**. Para configurar uno:

1. Abre la app y ve a **Settings** (icono ⚙️ en la esquina superior derecha).
2. En la sección **AI Provider**, selecciona el proveedor que quieras usar.
3. Introduce tu **API Key** y selecciona el **modelo** preferido.
4. Pulsa **Save**.

| Proveedor | Modelos destacados | Obtener API Key | Ver precios |
|-----------|--------------------|----------------|-------------|
| **OpenAI** | GPT-5.2, GPT-5-Mini, o3, o4-mini, GPT-4o-mini, GPT-4.1-nano | [platform.openai.com](https://platform.openai.com/api-keys) | [Pricing](https://openai.com/api/pricing) |
| **Anthropic** | Claude Opus 4.6, Sonnet 4.5, Haiku 4.5 | [console.anthropic.com](https://console.anthropic.com/settings/keys) | [Pricing](https://docs.anthropic.com/en/docs/about-claude/pricing) |
| **Google Gemini** | Gemini 3.1 Pro, 2.5 Pro, 2.5 Flash | [aistudio.google.com](https://aistudio.google.com/apikey) | [Pricing](https://ai.google.dev/gemini-api/docs/pricing) |
| **Mistral AI** | Large 3, Medium 3, Codestral, Small 3.2 | [console.mistral.ai](https://console.mistral.ai/api-keys) | [Pricing](https://mistral.ai/pricing) |
| **DeepSeek** | V3.2 (chat), R1 (reasoner) | [platform.deepseek.com](https://platform.deepseek.com/api_keys) | [Pricing](https://api-docs.deepseek.com/quick_start/pricing) |
| **Groq** | Llama 3.3 70B, Qwen3 32B, GPT-OSS 120B | [console.groq.com](https://console.groq.com/keys) | [Pricing](https://groq.com/pricing) |
| **OpenRouter** | 400+ modelos de todos los proveedores | [openrouter.ai](https://openrouter.ai/keys) | [Pricing](https://openrouter.ai/pricing) |
| **Custom / Local** | Ollama, LM Studio — cualquier modelo local | — | — |

> Las claves se almacenan **únicamente en tu dispositivo** de forma local. Solo se envían al proveedor seleccionado cuando usas el chatbot.

### Tema claro/oscuro

- Desde la pantalla principal, pulsa el icono de luna/sol en la barra superior.
- O ve a **Settings → Appearance → Dark Mode**.

### Temas de lectura

Desde el lector, pulsa el icono de ajustes (🎛️) para abrir el panel de personalización:

| Tema | Descripción |
|------|-------------|
| **Paper** | Blanco cálido, ideal para lectura diurna |
| **Snow** | Blanco puro, máximo contraste |
| **Sepia** | Tono cálido beige, simula papel envejecido |
| **Dusk** | Gris azulado oscuro, lectura al atardecer |
| **Night** | Fondo gris oscuro, lectura nocturna |
| **Midnight** | Negro puro (AMOLED), máximo ahorro de batería |

Además puedes ajustar: **fuente** (9 tipografías), **tamaño** (12-36px), **contraste** y **interlineado**.

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
   - Pulsa el icono de lista para ver el índice de capítulos.
   - Pulsa el icono de ajustes (🎛️) para personalizar tema, fuente, tamaño, contraste e interlineado.
3. **Para PDF:**
   - Navega con scroll y pellizco para zoom.
   - Pulsa el botón flotante para escribir o pegar texto y enviarlo al chat o guardarlo como nota.

### Seleccionar texto y menú contextual

1. Mientras lees un EPUB, selecciona un fragmento de texto arrastrando sobre él.
2. Aparece un menú flotante con 5 acciones:
   - **Copy** — Copia el texto al portapapeles.
   - **Highlight** — Resalta el texto en amarillo (persistente).
   - **Underline** — Subraya el texto en verde (persistente).
   - **Ask AI** — Envía el texto al chatbot para hacerle preguntas.
   - **Note** — Guarda el fragmento como nota con tus comentarios.
3. Los highlights y subrayados se conservan al cerrar y reabrir el libro.

### Gestionar notas

1. Pulsa el icono de notas en la barra superior del lector para ver las notas del libro actual.
2. Desde la biblioteca, pulsa el icono de notas para ver **todas** las notas de todos los libros.
3. Cada nota muestra el texto seleccionado original y tu comentario.
4. Puedes **editar** o **eliminar** notas con los iconos correspondientes.

### Eliminar un libro

1. En la biblioteca, pulsa el icono de papelera en la tarjeta del libro.
2. Confirma la eliminación en el diálogo.

---

## Estructura del proyecto

```
lib/
├── main.dart                              # Punto de entrada
├── config/
│   └── theme.dart                         # Temas Material 3 (claro/oscuro)
├── models/
│   ├── book.dart                          # Modelo de libro
│   ├── note.dart                          # Modelo de nota
│   ├── chat_message.dart                  # Modelo de mensaje de chat
│   ├── ai_provider.dart                   # Modelo de proveedor de IA (8 proveedores)
│   ├── reader_theme.dart                  # Modelo de tema de lectura (6 temas)
│   └── text_markup.dart                   # Modelo de highlight/underline
├── services/
│   ├── storage_service.dart               # Persistencia local con Hive
│   ├── ai_service.dart                    # Servicio unificado multi-proveedor AI
│   └── book_parser.dart                   # Parser de archivos EPUB
├── providers/
│   ├── library_provider.dart              # Estado de la biblioteca
│   ├── reader_provider.dart               # Estado del lector
│   ├── reader_settings_provider.dart      # Estado de temas/fuente/contraste
│   ├── chat_provider.dart                 # Estado del chatbot (multi-proveedor)
│   ├── notes_provider.dart                # Estado de las notas
│   ├── markup_provider.dart               # Estado de highlights/underlines
│   └── theme_provider.dart                # Estado del tema de la app
├── screens/
│   ├── library/
│   │   ├── library_screen.dart            # Pantalla principal de biblioteca
│   │   └── widgets/
│   │       └── book_card.dart             # Tarjeta de libro con hover animation
│   ├── reader/
│   │   ├── reader_screen.dart             # Pantalla principal del lector
│   │   ├── epub_reader_view.dart          # Vista EPUB con menú contextual
│   │   ├── pdf_reader_view.dart           # Vista PDF
│   │   └── reader_settings_sheet.dart     # Panel de personalización de lectura
│   ├── chat/
│   │   └── chat_panel.dart                # Panel lateral del chatbot
│   ├── notes/
│   │   └── notes_screen.dart              # Pantalla de gestión de notas
│   └── settings/
│       └── settings_screen.dart           # Configuración multi-proveedor AI
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
| [`http`](https://pub.dev/packages/http) | Peticiones HTTP (APIs de IA) |
| [`google_fonts`](https://pub.dev/packages/google_fonts) | 9 tipografías para el lector |

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
| `flutter devices` | Listar dispositivos disponibles |
| `flutter run` | Ejecutar en el dispositivo detectado |
| `flutter run -d chrome` | Ejecutar en Chrome (web) |
| `flutter run -d android` | Ejecutar en Android |
| `flutter run -d ios` | Ejecutar en iOS |
| `flutter build web` | Build de producción para web |
| `flutter build apk --debug` | APK de debug para pruebas rápidas |
| `flutter build apk --release` | APK de release para distribuir |
| `flutter build ios` | Build de producción para iOS |
| `flutter doctor` | Verificar instalación de Flutter |
| `flutter doctor --android-licenses` | Aceptar licencias de Android SDK |

---

## Solución de problemas

### `flutter doctor` muestra error en Android toolchain

Ejecuta el siguiente comando y acepta todas las licencias:

```bash
flutter doctor --android-licenses
```

Si falta Java JDK 17:

```bash
# Linux
sudo apt install openjdk-17-jdk

# macOS
brew install openjdk@17
```

### "Box not found" al ejecutar tests

Los tests necesitan inicializar Hive manualmente. Asegúrate de que el `setUp` del test incluya:

```dart
final dir = Directory.systemTemp.createTempSync('hive_test');
Hive.init(dir.path);
await Hive.openBox('books');
await Hive.openBox('notes');
await Hive.openBox('chat_messages');
await Hive.openBox('settings');
await Hive.openBox('markups');
```

### El chatbot responde "Please configure your API key"

Ve a **Settings → AI Provider**, selecciona el proveedor que quieras usar, introduce tu API key y pulsa **Save**.

### El archivo MOBI no se abre

Actualmente el soporte de MOBI es limitado. Se recomienda convertir el archivo a EPUB usando herramientas como [Calibre](https://calibre-ebook.com/) para la mejor experiencia de lectura.

### Error al importar archivos en web

Asegúrate de que el archivo no exceda el límite de memoria del navegador. Para archivos grandes (>50 MB), se recomienda usar la versión nativa (Android/iOS).

### El emulador de Android no aparece en `flutter devices`

1. Asegúrate de que el emulador está arrancado en Android Studio.
2. Ejecuta `adb devices` para verificar la conexión.
3. Si usas un dispositivo físico, comprueba que **Depuración USB** esté activada.

---

## Licencia

Este proyecto está bajo la licencia MIT. Consulta el archivo [LICENSE](LICENSE) para más detalles.
