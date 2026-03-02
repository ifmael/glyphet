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
  });
}

/// Registry of all supported AI providers.
class AiProviders {
  static const openai = AiProvider(
    id: 'openai',
    name: 'OpenAI',
    description: 'GPT-4o, GPT-4o mini and more',
    icon: Icons.auto_awesome,
    color: Color(0xFF10A37F),
    baseUrl: 'https://api.openai.com/v1/chat/completions',
    defaultModel: 'gpt-4o-mini',
    models: ['gpt-4o', 'gpt-4o-mini', 'gpt-4-turbo', 'gpt-3.5-turbo'],
    keyPrefix: 'sk-',
    docsUrl: 'https://platform.openai.com/api-keys',
  );

  static const anthropic = AiProvider(
    id: 'anthropic',
    name: 'Anthropic',
    description: 'Claude 4, Claude 3.5 Sonnet and more',
    icon: Icons.psychology,
    color: Color(0xFFD97706),
    baseUrl: 'https://api.anthropic.com/v1/messages',
    defaultModel: 'claude-sonnet-4-20250514',
    models: [
      'claude-sonnet-4-20250514',
      'claude-3-5-sonnet-20241022',
      'claude-3-5-haiku-20241022',
      'claude-3-haiku-20240307',
    ],
    keyPrefix: 'sk-ant-',
    docsUrl: 'https://console.anthropic.com/settings/keys',
  );

  static const google = AiProvider(
    id: 'google',
    name: 'Google Gemini',
    description: 'Gemini 2.0, Gemini 1.5 Pro and more',
    icon: Icons.diamond_outlined,
    color: Color(0xFF4285F4),
    baseUrl: 'https://generativelanguage.googleapis.com/v1beta/models/{model}:generateContent',
    defaultModel: 'gemini-2.0-flash',
    models: [
      'gemini-2.0-flash',
      'gemini-1.5-pro',
      'gemini-1.5-flash',
    ],
    keyPrefix: 'AI',
    docsUrl: 'https://aistudio.google.com/apikey',
  );

  static const mistral = AiProvider(
    id: 'mistral',
    name: 'Mistral AI',
    description: 'Mistral Large, Medium, Small',
    icon: Icons.air,
    color: Color(0xFFFF7000),
    baseUrl: 'https://api.mistral.ai/v1/chat/completions',
    defaultModel: 'mistral-small-latest',
    models: [
      'mistral-large-latest',
      'mistral-medium-latest',
      'mistral-small-latest',
      'open-mistral-nemo',
    ],
    keyPrefix: '',
    docsUrl: 'https://console.mistral.ai/api-keys',
  );

  static const deepseek = AiProvider(
    id: 'deepseek',
    name: 'DeepSeek',
    description: 'DeepSeek V3, DeepSeek R1',
    icon: Icons.explore,
    color: Color(0xFF536DFE),
    baseUrl: 'https://api.deepseek.com/chat/completions',
    defaultModel: 'deepseek-chat',
    models: ['deepseek-chat', 'deepseek-reasoner'],
    keyPrefix: 'sk-',
    docsUrl: 'https://platform.deepseek.com/api_keys',
  );

  static const groq = AiProvider(
    id: 'groq',
    name: 'Groq',
    description: 'Llama 3, Mixtral — ultra-fast inference',
    icon: Icons.bolt,
    color: Color(0xFFF55036),
    baseUrl: 'https://api.groq.com/openai/v1/chat/completions',
    defaultModel: 'llama-3.3-70b-versatile',
    models: [
      'llama-3.3-70b-versatile',
      'llama-3.1-8b-instant',
      'mixtral-8x7b-32768',
      'gemma2-9b-it',
    ],
    keyPrefix: 'gsk_',
    docsUrl: 'https://console.groq.com/keys',
  );

  static const openrouter = AiProvider(
    id: 'openrouter',
    name: 'OpenRouter',
    description: 'Access 100+ models from one API',
    icon: Icons.hub,
    color: Color(0xFF6366F1),
    baseUrl: 'https://openrouter.ai/api/v1/chat/completions',
    defaultModel: 'meta-llama/llama-3.3-70b-instruct',
    models: [
      'meta-llama/llama-3.3-70b-instruct',
      'google/gemini-2.0-flash-exp:free',
      'anthropic/claude-3.5-sonnet',
      'openai/gpt-4o-mini',
      'mistralai/mistral-large-latest',
    ],
    keyPrefix: 'sk-or-',
    docsUrl: 'https://openrouter.ai/keys',
  );

  static const custom = AiProvider(
    id: 'custom',
    name: 'Custom / Local',
    description: 'Ollama, LM Studio, or any OpenAI-compatible API',
    icon: Icons.dns_outlined,
    color: Color(0xFF78909C),
    baseUrl: 'http://localhost:11434/v1/chat/completions',
    defaultModel: 'llama3',
    models: ['llama3', 'mistral', 'phi3', 'gemma'],
    keyPrefix: '',
    docsUrl: '',
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
