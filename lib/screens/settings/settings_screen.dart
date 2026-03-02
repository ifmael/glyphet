import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/ai_provider.dart';
import '../../providers/theme_provider.dart';
import '../../services/storage_service.dart';

/// Settings screen with multi-provider AI configuration.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late String _activeProviderId;

  @override
  void initState() {
    super.initState();
    _activeProviderId = StorageService.getActiveProviderId();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader(context, Icons.smart_toy_rounded, 'AI Provider'),
          const SizedBox(height: 8),
          _buildProviderSelector(context),
          const SizedBox(height: 12),
          _buildProviderConfig(context),
          const SizedBox(height: 24),
          _buildSectionHeader(context, Icons.palette_outlined, 'Appearance'),
          const SizedBox(height: 8),
          _buildAppearanceCard(context),
          const SizedBox(height: 24),
          _buildSectionHeader(context, Icons.info_outline, 'About'),
          const SizedBox(height: 8),
          _buildAboutCard(context),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
      BuildContext context, IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
        ),
      ],
    );
  }

  // ── Provider Selector ──

  Widget _buildProviderSelector(BuildContext context) {
    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: AiProviders.all.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final provider = AiProviders.all[index];
          final isActive = provider.id == _activeProviderId;
          final hasKey = (StorageService.getProviderApiKey(provider.id) ?? '')
              .isNotEmpty;

          return GestureDetector(
            onTap: () async {
              await StorageService.setActiveProviderId(provider.id);
              setState(() => _activeProviderId = provider.id);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 100,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isActive
                    ? provider.color.withValues(alpha: 0.12)
                    : Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color:
                      isActive ? provider.color : Colors.grey.withValues(alpha: 0.2),
                  width: isActive ? 2 : 1,
                ),
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: provider.color.withValues(alpha: 0.2),
                          blurRadius: 8,
                        ),
                      ]
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    children: [
                      Icon(provider.icon, size: 26, color: provider.color),
                      if (hasKey)
                        Positioned(
                          right: -4,
                          bottom: -2,
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    provider.name,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight:
                          isActive ? FontWeight.w700 : FontWeight.w500,
                      color: isActive ? provider.color : null,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Provider Configuration Card ──

  Widget _buildProviderConfig(BuildContext context) {
    final provider = AiProviders.getById(_activeProviderId);
    return _ProviderConfigCard(
      key: ValueKey(provider.id),
      provider: provider,
    );
  }

  // ── Appearance ──

  Widget _buildAppearanceCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Consumer<ThemeProvider>(
          builder: (context, themeProvider, _) {
            return SwitchListTile(
              title: const Text('Dark Mode'),
              subtitle: const Text('Use dark theme for the app shell'),
              value: themeProvider.isDarkMode,
              onChanged: (_) => themeProvider.toggleTheme(),
              contentPadding: EdgeInsets.zero,
            );
          },
        ),
      ),
    );
  }

  // ── About ──

  Widget _buildAboutCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Glyphet v1.0.0',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(
              'Cross-platform ebook reader with AI-powered reading assistant and note-taking.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.6),
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              'Supported formats: EPUB, PDF, MOBI\nAI providers: OpenAI, Anthropic, Google Gemini, Mistral, DeepSeek, Groq, OpenRouter, Custom/Local',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.5),
                    height: 1.5,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Configuration card for a single AI provider (API key, model, URL).
class _ProviderConfigCard extends StatefulWidget {
  final AiProvider provider;
  const _ProviderConfigCard({super.key, required this.provider});

  @override
  State<_ProviderConfigCard> createState() => _ProviderConfigCardState();
}

class _ProviderConfigCardState extends State<_ProviderConfigCard> {
  late TextEditingController _keyController;
  late TextEditingController _urlController;
  late String _selectedModel;
  bool _obscureKey = true;

  @override
  void initState() {
    super.initState();
    _keyController = TextEditingController(
      text: StorageService.getProviderApiKey(widget.provider.id) ?? '',
    );
    _urlController = TextEditingController(
      text: widget.provider.id == 'custom'
          ? (StorageService.getCustomBaseUrl() ?? widget.provider.baseUrl)
          : '',
    );
    _selectedModel = StorageService.getProviderModel(widget.provider.id) ??
        widget.provider.defaultModel;
  }

  @override
  void dispose() {
    _keyController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    await StorageService.setProviderApiKey(
        widget.provider.id, _keyController.text.trim());
    await StorageService.setProviderModel(widget.provider.id, _selectedModel);
    if (widget.provider.id == 'custom') {
      await StorageService.setCustomBaseUrl(_urlController.text.trim());
    }
    // Migrate legacy key if saving OpenAI
    if (widget.provider.id == 'openai') {
      await StorageService.setApiKey(_keyController.text.trim());
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${widget.provider.name} settings saved!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.provider;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(p.icon, color: p.color, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p.name,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      Text(
                        p.description,
                        style:
                            Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withValues(alpha: 0.5),
                                ),
                      ),
                    ],
                  ),
                ),
                if (p.docsUrl.isNotEmpty)
                  Tooltip(
                    message: 'Get API key',
                    child: IconButton(
                      icon: const Icon(Icons.open_in_new, size: 18),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Visit: ${p.docsUrl}')),
                        );
                      },
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // API Key
            Text('API Key',
                style: Theme.of(context)
                    .textTheme
                    .labelMedium
                    ?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            TextField(
              controller: _keyController,
              obscureText: _obscureKey,
              decoration: InputDecoration(
                hintText: p.keyPrefix.isNotEmpty
                    ? '${p.keyPrefix}...'
                    : 'Enter API key (optional for local)',
                suffixIcon: IconButton(
                  icon: Icon(
                      _obscureKey ? Icons.visibility : Icons.visibility_off,
                      size: 18),
                  onPressed: () =>
                      setState(() => _obscureKey = !_obscureKey),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Model selector
            Text('Model',
                style: Theme.of(context)
                    .textTheme
                    .labelMedium
                    ?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              initialValue: p.models.contains(_selectedModel)
                  ? _selectedModel
                  : p.defaultModel,
              decoration: const InputDecoration(),
              isExpanded: true,
              items: p.models
                  .map((m) => DropdownMenuItem(
                        value: m,
                        child: Text(m,
                            style: const TextStyle(fontSize: 13),
                            overflow: TextOverflow.ellipsis),
                      ))
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _selectedModel = v);
              },
            ),

            // Custom URL for local provider
            if (p.id == 'custom') ...[
              const SizedBox(height: 14),
              Text('Base URL',
                  style: Theme.of(context)
                      .textTheme
                      .labelMedium
                      ?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              TextField(
                controller: _urlController,
                decoration: const InputDecoration(
                  hintText: 'http://localhost:11434/v1/chat/completions',
                ),
              ),
            ],

            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save_rounded, size: 18),
                label: const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
