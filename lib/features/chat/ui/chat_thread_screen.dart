import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../logic/chat_provider.dart';

class ChatThreadScreen extends ConsumerStatefulWidget {
  final String chatId;

  const ChatThreadScreen({super.key, required this.chatId});

  @override
  ConsumerState<ChatThreadScreen> createState() => _ChatThreadScreenState();
}

class _ChatThreadScreenState extends ConsumerState<ChatThreadScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatAsync = ref.watch(chatByIdProvider(widget.chatId));

    return Scaffold(
      backgroundColor: const Color(0xFFECE5DD),
      appBar: AppBar(
        backgroundColor: const Color(0xFF075E54),
        title: chatAsync.when(
          data: (chat) => Text(
            chat?.name ?? 'Chat',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          loading: () => const SizedBox(
            width: 100,
            height: 16,
            child: LinearProgressIndicator(
              backgroundColor: Colors.white24,
              color: Colors.white,
            ),
          ),
          error: (_, __) => const Text(
            'Chat',
            style: TextStyle(color: Colors.white),
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.videocam, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.call, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {},
          ),
        ],
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(child: _MessageList(chatId: widget.chatId)),
          _MessageInput(
            controller: _messageController,
            onSend: _sendMessage,
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    // TODO: Implement actual message sending with Isar
    setState(() {
      _messageController.clear();
    });

    // Scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
}

class _MessageList extends StatelessWidget {
  final String chatId;

  const _MessageList({required this.chatId});

  @override
  Widget build(BuildContext context) {
    // Placeholder messages - will replace with actual Isar queries
    final messages = [
      _Message(
        id: '1',
        text: 'All units, please report status',
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        isSent: false,
      ),
      _Message(
        id: '2',
        text: 'Team Alpha reporting - all clear',
        timestamp: DateTime.now().subtract(const Duration(minutes: 3)),
        isSent: true,
      ),
      _Message(
        id: '3',
        text: 'Team Bravo on standby',
        timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
        isSent: true,
      ),
      _Message(
        id: '4',
        text: 'Acknowledged. Maintain positions',
        timestamp: DateTime.now().subtract(const Duration(minutes: 1)),
        isSent: false,
      ),
    ];

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        return _MessageBubble(message: message);
      },
    );
  }
}

class _Message {
  final String id;
  final String text;
  final DateTime timestamp;
  final bool isSent;

  _Message({
    required this.id,
    required this.text,
    required this.timestamp,
    required this.isSent,
  });
}

class _MessageBubble extends StatelessWidget {
  final _Message message;

  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isSent = message.isSent;
    final alignment = isSent ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final bubbleColor = isSent ? const Color(0xFFDCF8C6) : Colors.white;
    final textColor = isSent ? Colors.black87 : Colors.black87;
    final borderRadius = BorderRadius.only(
      topLeft: const Radius.circular(18),
      topRight: const Radius.circular(18),
      bottomLeft: isSent ? const Radius.circular(18) : const Radius.circular(4),
      bottomRight: isSent ? const Radius.circular(4) : const Radius.circular(18),
    );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        crossAxisAlignment: alignment,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: bubbleColor,
              borderRadius: borderRadius,
            ),
            child: Text(
              message.text,
              style: TextStyle(
                color: textColor,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: EdgeInsets.only(
              left: isSent ? 0 : 16,
              right: isSent ? 16 : 0,
            ),
            child: Text(
              _formatTime(message.timestamp),
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);

    if (diff.inMinutes == 0) {
      return 'just now';
    } else if (diff.inHours == 0) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inDays == 0) {
      return '${diff.inHours}h ago';
    } else {
      return DateFormat('MMM d, h:mm a').format(timestamp);
    }
  }
}

class _MessageInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;

  const _MessageInput({
    required this.controller,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      color: const Color(0xFFECE5DD),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.attach_file, color: Color(0xFF075E54)),
            onPressed: () {},
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
              ),
              child: TextField(
                controller: controller,
                decoration: const InputDecoration(
                  hintText: 'Type a message...',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                style: const TextStyle(fontSize: 16),
                maxLines: null,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onSend(),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.camera_alt, color: Color(0xFF075E54)),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.mic, color: Color(0xFF075E54)),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
