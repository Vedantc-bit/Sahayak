import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../logic/chat_provider.dart';

class ChatThreadScreen extends ConsumerStatefulWidget {
  final String chatId;

  const ChatThreadScreen({super.key, required this.chatId});

  @override
  ConsumerState<ChatThreadScreen> createState() => _ChatThreadScreenState();
}

class _ChatThreadScreenState extends ConsumerState<ChatThreadScreen>
    with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatAsync = ref.watch(chatByIdProvider(widget.chatId));

    return Scaffold(
      backgroundColor: const Color(0xFFECE5DD),
      appBar: AppBar(
        backgroundColor: const Color(0xFF075E54),
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
          onPressed: () => Navigator.of(context).pop(),
          splashRadius: 24,
        ),
        title: chatAsync.when(
          data: (chat) => Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _getAvatarColor(chat?.name ?? ''),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    (chat?.name.isNotEmpty ?? false) 
                        ? chat!.name[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      chat?.name ?? 'Chat',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'online',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          loading: () => const Row(
            children: [
              SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 2,
                ),
              ),
              SizedBox(width: 12),
              Text(
                'Loading...',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          error: (_, __) => const Text(
            'Chat',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.videocam, color: Colors.white, size: 24),
            onPressed: () {},
            splashRadius: 24,
          ),
          IconButton(
            icon: const Icon(Icons.call, color: Colors.white, size: 24),
            onPressed: () {},
            splashRadius: 24,
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white, size: 24),
            onPressed: () {},
            splashRadius: 24,
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            Expanded(child: _MessageList(chatId: widget.chatId)),
            _MessageInput(
              controller: _messageController,
              onSend: _sendMessage,
            ),
          ],
        ),
      ),
    );
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    // TODO: Implement actual message sending with Isar
    setState(() {
      _messageController.clear();
    });

    // Scroll to bottom with animation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    // Show feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Message sent: $text'),
        backgroundColor: const Color(0xFF075E54),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Color _getAvatarColor(String name) {
    final colors = [
      const Color(0xFF34B7F1),
      const Color(0xFF25D366),
      const Color(0xFFFF7B54),
      const Color(0xFF9B59B6),
      const Color(0xFFE74C3C),
      const Color(0xFFF39C12),
      const Color(0xFF1ABC9C),
      const Color(0xFF34495E),
    ];

    if (name.isEmpty) return colors[0];
    final index = name.hashCode % colors.length;
    return colors[index.abs()];
  }
}

class _MessageList extends StatelessWidget {
  final String chatId;

  const _MessageList({required this.chatId});

  @override
  Widget build(BuildContext context) {
    // Placeholder messages with better content
    final messages = [
      _Message(
        id: '1',
        text: 'All units, please report current status and location',
        timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
        isSent: false,
      ),
      _Message(
        id: '2',
        text: 'Team Alpha reporting - Sector 4 secure, 12 volunteers ready',
        timestamp: DateTime.now().subtract(const Duration(minutes: 12)),
        isSent: true,
      ),
      _Message(
        id: '3',
        text: 'Team Bravo on standby at medical camp, supplies adequate',
        timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
        isSent: true,
      ),
      _Message(
        id: '4',
        text: 'Acknowledged. Maintain positions. Update in 30 minutes',
        timestamp: DateTime.now().subtract(const Duration(minutes: 8)),
        isSent: false,
      ),
      _Message(
        id: '5',
        text: 'Copy that. Standing by for further instructions',
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        isSent: true,
      ),
    ];

    return ListView.builder(
      controller: ScrollController(),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
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
    final textColor = isSent ? const Color(0xFF111B21) : const Color(0xFF111B21);
    final timeColor = const Color(0xFF667781);
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Column(
        crossAxisAlignment: alignment,
        children: [
          Row(
            mainAxisAlignment: isSent ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              if (!isSent) ...[
                Container(
                  width: 32,
                  height: 32,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF34B7F1),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text(
                      'E',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
              Flexible(
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.75,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: bubbleColor,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(18),
                      topRight: const Radius.circular(18),
                      bottomLeft: isSent ? const Radius.circular(18) : const Radius.circular(4),
                      bottomRight: isSent ? const Radius.circular(4) : const Radius.circular(18),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 1,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Text(
                    message.text,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 16,
                      height: 1.4,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
              ),
              if (isSent) ...[
                Container(
                  width: 32,
                  height: 32,
                  margin: const EdgeInsets.only(left: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF25D366),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 4),
          Padding(
            padding: EdgeInsets.only(
              left: isSent ? 0 : 48,
              right: isSent ? 48 : 0,
            ),
            child: Text(
              _formatTime(message.timestamp),
              style: TextStyle(
                color: timeColor,
                fontSize: 11,
                fontWeight: FontWeight.w500,
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
      return 'now';
    } else if (diff.inHours == 0) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inDays == 0) {
      return DateFormat('h:mm a').format(timestamp).toLowerCase();
    } else {
      return DateFormat('MMM d, h:mm a').format(timestamp).toLowerCase();
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
      decoration: const BoxDecoration(
        color: Color(0xFFECE5DD),
        border: Border(
          top: BorderSide(color: Color(0xFFE5E5E5), width: 1),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: Color(0xFF075E54), size: 24),
            onPressed: () {},
            splashRadius: 24,
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: const Color(0xFFE5E5E5), width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 1,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: TextField(
                controller: controller,
                decoration: const InputDecoration(
                  hintText: 'Type a message...',
                  hintStyle: TextStyle(color: Color(0xFF667781), fontSize: 16),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF111B21),
                  letterSpacing: -0.2,
                ),
                maxLines: null,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onSend(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.camera_alt_outlined, color: Color(0xFF075E54), size: 24),
            onPressed: () {},
            splashRadius: 24,
          ),
          IconButton(
            icon: const Icon(Icons.mic, color: Color(0xFF075E54), size: 24),
            onPressed: () {},
            splashRadius: 24,
          ),
        ],
      ),
    );
  }
}
