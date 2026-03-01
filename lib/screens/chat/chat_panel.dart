import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/chat_provider.dart';
import '../../models/chat_message.dart';

/// Slide-in panel for AI chatbot conversations about the book content.
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
          Icon(Icons.smart_toy,
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
            icon: const Icon(Icons.delete_sweep, size: 18),
            onPressed: () => context.read<ChatProvider>().clearChat(),
            tooltip: 'Clear chat',
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            onPressed: widget.onClose,
            tooltip: 'Close chat',
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedTextBanner() {
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.format_quote,
              size: 16, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              widget.selectedText!.length > 100
                  ? '${widget.selectedText!.substring(0, 100)}...'
                  : widget.selectedText!,
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
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
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 48,
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.4),
                  ),
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
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: 8),
            const Text('Thinking...', style: TextStyle(fontSize: 13)),
          ],
        ),
      ),
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
            icon: const Icon(Icons.send, size: 18),
          ),
        ],
      ),
    );
  }
}
