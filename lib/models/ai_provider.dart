import 'package:flutter/material.dart';

/// Represents a supported AI provider with its API configuration.
class AiProvider {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final String baseUrl;
  final String defaultModel;
  final List<String> models;
  final String keyPrefix;
  final String docsUrl;
  final String pricingUrl;

  const AiProvider({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.baseUrl,
    required this.defaultModel,
    required this.models,
    required this.keyPrefix,
    required this.docsUrl,
    required this.pricingUrl,
  });
}

/// Registry of all supported AI providers (models updated March 2026).
class AiProviders {
  static const openai = AiProvider(
    id: 'openai',
    name: 'OpenAI',
    description: 'GPT-5.2, o4-mini, GPT-4.1-nano and more',
    icon: Icons.auto_awesome,
    color: Color(0xFF10A37F),
    baseUrl: 'https://api.openai.com/v1/chat/completions',
    defaultModel: 'gpt-4o-mini',
    models: [
      'gpt-5.2',
      'gpt-5.1',
      'gpt-5-mini',
      'o3',
      'o3-mini',
      'o4-mini',
      'gpt-4o',
      'gpt-4o-mini',
      'gpt-4.1-nano',
    ],
    keyPrefix: 'sk-',
    docsUrl: 'https://platform.openai.com/api-keys',
    pricingUrl: 'https://openai.com/api/pricing',
  );

  static const anthropic = AiProvider(
    id: 'anthropic',
    name: 'Anthropic',
    description: 'Claude Opus 4.6, Sonnet 4.5, Haiku 4.5',
    icon: Icons.psychology,
    color: Color(0xFFD97706),
    baseUrl: 'https://api.anthropic.com/v1/messages',
    defaultModel: 'claude-sonnet-4-5-20250514',
    models: [
      'claude-opus-4-6-20260205',
      'claude-sonnet-4-5-20250514',
      'claude-haiku-4-5-20250514',
    ],
    keyPrefix: 'sk-ant-',
    docsUrl: 'https://console.anthropic.com/settings/keys',
    pricingUrl: 'https://docs.anthropic.com/en/docs/about-claude/pricing',
  );

  static const google = AiProvider(
    id: 'google',
    name: 'Google Gemini',
    description: 'Gemini 3.1 Pro, 2.5 Pro/Flash and more',
    icon: Icons.diamond_outlined,
    color: Color(0xFF4285F4),
    baseUrl: 'https://generativelanguage.googleapis.com/v1beta/models/{model}:generateContent',
    defaultModel: 'gemini-2.5-flash',
    models: [
      'gemini-3.1-pro',
      'gemini-2.5-pro',
      'gemini-2.5-flash',
      'gemini-2.0-flash',
    ],
    keyPrefix: 'AI',
    docsUrl: 'https://aistudio.google.com/apikey',
    pricingUrl: 'https://ai.google.dev/gemini-api/docs/pricing',
  );

  static const mistral = AiProvider(
    id: 'mistral',
    name: 'Mistral AI',
    description: 'Mistral Large 3, Medium 3, Codestral',
    icon: Icons.air,
    color: Color(0xFFFF7000),
    baseUrl: 'https://api.mistral.ai/v1/chat/completions',
    defaultModel: 'mistral-small-latest',
    models: [
      'mistral-large-latest',
      'mistral-medium-3',
      'mistral-small-latest',
      'mistral-small-3.2-24b',
      'codestral-latest',
      'open-mistral-nemo',
    ],
    keyPrefix: '',
    docsUrl: 'https://console.mistral.ai/api-keys',
    pricingUrl: 'https://mistral.ai/pricing',
  );

  static const deepseek = AiProvider(
    id: 'deepseek',
    name: 'DeepSeek',
    description: 'DeepSeek V3.2, R1 — ultra low cost',
    icon: Icons.explore,
    color: Color(0xFF536DFE),
    baseUrl: 'https://api.deepseek.com/chat/completions',
    defaultModel: 'deepseek-chat',
    models: [
      'deepseek-chat',
      'deepseek-reasoner',
    ],
    keyPrefix: 'sk-',
    docsUrl: 'https://platform.deepseek.com/api_keys',
    pricingUrl: 'https://api-docs.deepseek.com/quick_start/pricing',
  );

  static const groq = AiProvider(
    id: 'groq',
    name: 'Groq',
    description: 'Llama 3.3, Qwen3, GPT-OSS — ultra-fast',
    icon: Icons.bolt,
    color: Color(0xFFF55036),
    baseUrl: 'https://api.groq.com/openai/v1/chat/completions',
    defaultModel: 'llama-3.3-70b-versatile',
    models: [
      'llama-3.3-70b-versatile',
      'llama-3.1-8b-instant',
      'qwen3-32b',
      'gpt-oss-120b',
      'gpt-oss-20b',
    ],
    keyPrefix: 'gsk_',
    docsUrl: 'https://console.groq.com/keys',
    pricingUrl: 'https://groq.com/pricing',
  );

  static const openrouter = AiProvider(
    id: 'openrouter',
    name: 'OpenRouter',
    description: 'Access 400+ models from one API',
    icon: Icons.hub,
    color: Color(0xFF6366F1),
    baseUrl: 'https://openrouter.ai/api/v1/chat/completions',
    defaultModel: 'anthropic/claude-sonnet-4.5',
    models: [
      'anthropic/claude-opus-4.6',
      'anthropic/claude-sonnet-4.5',
      'openai/gpt-5.2',
      'openai/gpt-5-mini',
      'google/gemini-2.5-pro',
      'google/gemini-2.5-flash',
      'deepseek/deepseek-chat',
      'meta-llama/llama-3.3-70b-instruct',
    ],
    keyPrefix: 'sk-or-',
    docsUrl: 'https://openrouter.ai/keys',
    pricingUrl: 'https://openrouter.ai/pricing',
  );

  static const custom = AiProvider(
    id: 'custom',
    name: 'Custom / Local',
    description: 'Ollama, LM Studio, or any OpenAI-compatible API',
    icon: Icons.dns_outlined,
    color: Color(0xFF78909C),
    baseUrl: 'http://localhost:11434/v1/chat/completions',
    defaultModel: 'llama3.3',
    models: ['llama3.3', 'qwen3', 'mistral', 'phi4', 'gemma3', 'deepseek-r1'],
    keyPrefix: '',
    docsUrl: '',
    pricingUrl: '',
  );

  static const List<AiProvider> all = [
    openai,
    anthropic,
    google,
    mistral,
    deepseek,
    groq,
    openrouter,
    custom,
  ];

  static AiProvider getById(String id) {
    return all.firstWhere((p) => p.id == id, orElse: () => openai);
  }
}
