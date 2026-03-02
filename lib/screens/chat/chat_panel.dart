import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/ai_provider.dart';
import '../../providers/chat_provider.dart';
import '../../models/chat_message.dart';
import '../../services/storage_service.dart';

/// Slide-in panel for AI chatbot with inline model selector.
class ChatPanel extends StatefulWidget {
  final String bookId;
  final String? chapterContext;
  final String? selectedText;
  final VoidCallback onClose;

  const ChatPanel({
    super.key,
    required this.bookId,
    this.chapterContext,
    this.selectedText,
    required this.onClose,
  });

  @override
  State<ChatPanel> createState() => _ChatPanelState();
}

class _ChatPanelState extends State<ChatPanel> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;

    context.read<ChatProvider>().sendMessage(
          content: text,
          selectedText: widget.selectedText,
          chapterContext: widget.chapterContext,
        );

    _inputController.clear();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 200), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _openModelSelector() {
    final chat = context.read<ChatProvider>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ModelSelectorSheet(
        currentProviderId: chat.activeProvider.id,
        currentModel: chat.activeModel,
        onSelected: (providerId, model) {
          chat.switchModel(providerId, model);
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(color: Theme.of(context).dividerColor),
        ),
        color: Theme.of(context).colorScheme.surface,
      ),
      child: Column(
        children: [
          _buildHeader(),
          _buildModelChip(),
          if (widget.selectedText != null && widget.selectedText!.isNotEmpty)
            _buildSelectedTextBanner(),
          Expanded(child: _buildMessageList()),
          _buildInput(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.smart_toy_rounded,
              size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            'AI Assistant',
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.delete_sweep_rounded, size: 18),
            onPressed: () => context.read<ChatProvider>().clearChat(),
            tooltip: 'Clear chat',
          ),
          IconButton(
            icon: const Icon(Icons.close_rounded, size: 18),
            onPressed: widget.onClose,
            tooltip: 'Close chat',
          ),
        ],
      ),
    );
  }

  /// Tappable chip showing the active provider + model.
  Widget _buildModelChip() {
    return Consumer<ChatProvider>(
      builder: (context, chat, _) {
        final provider = chat.activeProvider;
        final model = chat.activeModel;
        final shortModel = _shortenModel(model);

        return GestureDetector(
          onTap: _openModelSelector,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: provider.color.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
              border:
                  Border.all(color: provider.color.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                Icon(provider.icon, size: 15, color: provider.color),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '${provider.name} · $shortModel',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: provider.color,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(Icons.unfold_more_rounded,
                    size: 14, color: provider.color),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSelectedTextBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color:
              Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.format_quote,
              size: 14, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              widget.selectedText!.length > 100
                  ? '${widget.selectedText!.substring(0, 100)}...'
                  : widget.selectedText!,
              style: TextStyle(
                fontSize: 11,
                fontStyle: FontStyle.italic,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.8),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    return Consumer<ChatProvider>(
      builder: (context, chat, _) {
        if (chat.messages.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_outline,
                      size: 48,
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.4)),
                  const SizedBox(height: 12),
                  Text(
                    'Ask questions about the text',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.6),
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Select text and tap "Ask AI" or type a question below',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.4),
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        WidgetsBinding.instance
            .addPostFrameCallback((_) => _scrollToBottom());

        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(12),
          itemCount: chat.messages.length + (chat.isLoading ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == chat.messages.length && chat.isLoading) {
              return _buildTypingIndicator();
            }
            return _buildMessageBubble(chat.messages[index]);
          },
        );
      },
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isUser = message.role == 'user';
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
        decoration: BoxDecoration(
          color: isUser
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(12),
            topRight: const Radius.circular(12),
            bottomLeft: Radius.circular(isUser ? 12 : 0),
            bottomRight: Radius.circular(isUser ? 0 : 12),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (message.selectedText != null &&
                message.selectedText!.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '"${message.selectedText!.length > 80 ? '${message.selectedText!.substring(0, 80)}...' : message.selectedText!}"',
                  style: TextStyle(
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                    color: isUser ? Colors.white70 : null,
                  ),
                ),
              ),
            SelectableText(
              message.content,
              style: TextStyle(
                fontSize: 14,
                color: isUser ? Colors.white : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Consumer<ChatProvider>(
      builder: (context, chat, _) {
        final provider = chat.activeProvider;
        return Align(
          alignment: Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: provider.color,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${provider.name} is thinking...',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInput() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _inputController,
              decoration: InputDecoration(
                hintText: 'Ask about the text...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              onSubmitted: (_) => _sendMessage(),
              maxLines: null,
            ),
          ),
          const SizedBox(width: 8),
          IconButton.filled(
            onPressed: _sendMessage,
            icon: const Icon(Icons.send_rounded, size: 18),
          ),
        ],
      ),
    );
  }

  String _shortenModel(String model) {
    if (model.contains('/')) return model.split('/').last;
    return model;
  }
}

/// Bottom sheet that lists all configured providers and their models.
class _ModelSelectorSheet extends StatelessWidget {
  final String currentProviderId;
  final String currentModel;
  final void Function(String providerId, String model) onSelected;

  const _ModelSelectorSheet({
    required this.currentProviderId,
    required this.currentModel,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final configured = AiProviders.all.where((p) {
      if (p.id == 'custom') return true;
      final key = StorageService.getProviderApiKey(p.id) ?? '';
      return key.isNotEmpty;
    }).toList();

    final unconfigured = AiProviders.all
        .where((p) => p.id != 'custom' && !configured.contains(p))
        .toList();

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
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
          const SizedBox(height: 14),
          Text(
            'Select Model',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            'Choose a provider and model for this conversation',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.5),
                ),
          ),
          const SizedBox(height: 12),
          if (configured.isNotEmpty) ...[
            _sectionLabel(context, 'Configured', configured.length),
            ...configured
                .map((p) => _buildProviderTile(context, p, enabled: true)),
          ],
          if (unconfigured.isNotEmpty) ...[
            _sectionLabel(context, 'Not configured', unconfigured.length),
            ...unconfigured
                .map((p) => _buildProviderTile(context, p, enabled: false)),
          ],
          SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
        ],
      ),
    );
  }

  Widget _sectionLabel(BuildContext context, String label, int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
      child: Row(
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.4),
                  letterSpacing: 0.5,
                ),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.4),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProviderTile(BuildContext context, AiProvider provider,
      {required bool enabled}) {
    final isActiveProvider = provider.id == currentProviderId;
    final savedModel = StorageService.getProviderModel(provider.id) ??
        provider.defaultModel;

    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        leading: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: enabled
                ? provider.color.withValues(alpha: 0.1)
                : Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            provider.icon,
            size: 18,
            color: enabled
                ? provider.color
                : Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.25),
          ),
        ),
        title: Text(
          provider.name,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isActiveProvider ? FontWeight.w700 : FontWeight.w500,
            color: enabled
                ? null
                : Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.35),
          ),
        ),
        subtitle: Text(
          enabled ? provider.description : 'Add API key in Settings',
          style: TextStyle(
            fontSize: 11,
            color: Theme.of(context)
                .colorScheme
                .onSurface
                .withValues(alpha: enabled ? 0.5 : 0.3),
          ),
        ),
        trailing: isActiveProvider
            ? Icon(Icons.check_circle_rounded,
                size: 18, color: provider.color)
            : (enabled
                ? const Icon(Icons.expand_more_rounded, size: 18)
                : Icon(Icons.lock_outline_rounded,
                    size: 16,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.2))),
        initiallyExpanded: isActiveProvider,
        collapsedShape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
        children: enabled
            ? provider.models.map((model) {
                final isActive =
                    isActiveProvider && model == currentModel;
                final isSaved = model == savedModel;
                return ListTile(
                  dense: true,
                  contentPadding:
                      const EdgeInsets.only(left: 68, right: 16),
                  title: Text(
                    _shortenModel(model),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight:
                          isActive ? FontWeight.w700 : FontWeight.w400,
                      color: isActive ? provider.color : null,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isSaved && !isActive)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'default',
                            style: TextStyle(
                              fontSize: 9,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.4),
                            ),
                          ),
                        ),
                      if (isActive)
                        Icon(Icons.radio_button_checked_rounded,
                            size: 16, color: provider.color)
                      else
                        Icon(Icons.radio_button_off_rounded,
                            size: 16,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.2)),
                    ],
                  ),
                  onTap: () => onSelected(provider.id, model),
                );
              }).toList()
            : [],
      ),
    );
  }

  String _shortenModel(String model) {
    if (model.contains('/')) return model.split('/').last;
    return model;
  }
}
