import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/reader_theme.dart';
import '../../providers/reader_settings_provider.dart';

/// Bottom sheet for reader appearance customization.
class ReaderSettingsSheet extends StatelessWidget {
  const ReaderSettingsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ReaderSettingsProvider>(
      builder: (context, settings, _) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Reading Appearance',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
              ),
              const SizedBox(height: 20),
              _buildThemeSelector(context, settings),
              const SizedBox(height: 24),
              _buildFontSizeControl(context, settings),
              const SizedBox(height: 20),
              _buildFontSelector(context, settings),
              const SizedBox(height: 20),
              _buildContrastControl(context, settings),
              const SizedBox(height: 20),
              _buildLineHeightControl(context, settings),
              const SizedBox(height: 16),
              _buildPreview(context, settings),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _buildThemeSelector(
      BuildContext context, ReaderSettingsProvider settings) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.palette_outlined,
                  size: 18,
                  color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'Theme',
                style: Theme.of(context)
                    .textTheme
                    .labelLarge
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 80,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: ReaderThemes.all.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final theme = ReaderThemes.all[index];
                final isSelected = theme.id == settings.theme.id;
                return GestureDetector(
                  onTap: () => settings.setTheme(theme),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 70,
                    decoration: BoxDecoration(
                      color: theme.backgroundColor,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected
                            ? theme.accentColor
                            : Colors.grey.withValues(alpha: 0.25),
                        width: isSelected ? 2.5 : 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: theme.accentColor.withValues(alpha: 0.3),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ]
                          : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Aa',
                          style: TextStyle(
                            color: theme.textColor,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          theme.name,
                          style: TextStyle(
                            color: theme.textColor.withValues(alpha: 0.7),
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFontSizeControl(
      BuildContext context, ReaderSettingsProvider settings) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.format_size,
                  size: 18,
                  color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'Size',
                style: Theme.of(context)
                    .textTheme
                    .labelLarge
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${settings.fontSize.round()}',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text('A', style: TextStyle(fontSize: 12)),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 3,
                    thumbShape:
                        const RoundSliderThumbShape(enabledThumbRadius: 7),
                  ),
                  child: Slider(
                    value: settings.fontSize,
                    min: 12,
                    max: 36,
                    divisions: 24,
                    onChanged: (v) => settings.setFontSize(v),
                  ),
                ),
              ),
              const Text('A', style: TextStyle(fontSize: 24)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFontSelector(
      BuildContext context, ReaderSettingsProvider settings) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.font_download_outlined,
                  size: 18,
                  color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'Font',
                style: Theme.of(context)
                    .textTheme
                    .labelLarge
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 42,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: ReaderFonts.all.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final font = ReaderFonts.all[index];
                final isSelected = font == settings.fontFamily;
                return GestureDetector(
                  onTap: () => settings.setFontFamily(font),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      font,
                      style: GoogleFonts.getFont(
                        font,
                        fontSize: 13,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w400,
                        color: isSelected
                            ? Colors.white
                            : Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContrastControl(
      BuildContext context, ReaderSettingsProvider settings) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.contrast,
                  size: 18,
                  color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'Contrast',
                style: Theme.of(context)
                    .textTheme
                    .labelLarge
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _contrastLabel(settings.fontContrast),
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.brightness_low,
                  size: 18,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.4)),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 3,
                    thumbShape:
                        const RoundSliderThumbShape(enabledThumbRadius: 7),
                  ),
                  child: Slider(
                    value: settings.fontContrast,
                    min: 0.4,
                    max: 1.6,
                    divisions: 12,
                    onChanged: (v) => settings.setFontContrast(v),
                  ),
                ),
              ),
              Icon(Icons.brightness_high,
                  size: 18,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.7)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLineHeightControl(
      BuildContext context, ReaderSettingsProvider settings) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.format_line_spacing,
                  size: 18,
                  color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'Line Spacing',
                style: Theme.of(context)
                    .textTheme
                    .labelLarge
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  settings.lineHeight.toStringAsFixed(1),
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 3,
              thumbShape:
                  const RoundSliderThumbShape(enabledThumbRadius: 7),
            ),
            child: Slider(
              value: settings.lineHeight,
              min: 1.2,
              max: 2.5,
              divisions: 13,
              onChanged: (v) => settings.setLineHeight(v),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreview(
      BuildContext context, ReaderSettingsProvider settings) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: settings.theme.backgroundColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.grey.withValues(alpha: 0.2),
        ),
      ),
      child: Text(
        'The quick brown fox jumps over the lazy dog. Reading is a gateway to infinite worlds.',
        style: GoogleFonts.getFont(
          settings.fontFamily,
          fontSize: settings.fontSize * 0.8,
          height: settings.lineHeight,
          color: settings.effectiveTextColor,
        ),
      ),
    );
  }

  String _contrastLabel(double value) {
    if (value < 0.65) return 'Low';
    if (value < 0.85) return 'Soft';
    if (value < 1.15) return 'Normal';
    if (value < 1.35) return 'High';
    return 'Max';
  }
}
