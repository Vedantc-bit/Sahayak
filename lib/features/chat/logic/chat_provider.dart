import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatSummary {
  final String id;
  final String name;
  final String lastMessage;
  final DateTime lastMessageTimestamp;
  final int unreadCount;

  ChatSummary({
    required this.id,
    required this.name,
    required this.lastMessage,
    required this.lastMessageTimestamp,
    this.unreadCount = 0,
  });
}

// Placeholder data for now - will replace with Isar later
final List<ChatSummary> _placeholderChats = [
  ChatSummary(
    id: '1',
    name: 'Emergency Response Team',
    lastMessage: 'All units, please report status',
    lastMessageTimestamp: DateTime.now().subtract(const Duration(minutes: 5)),
    unreadCount: 2,
  ),
  ChatSummary(
    id: '2',
    name: 'Medical Aid Group',
    lastMessage: 'We have 3 volunteers available',
    lastMessageTimestamp: DateTime.now().subtract(const Duration(hours: 1)),
    unreadCount: 0,
  ),
  ChatSummary(
    id: '3',
    name: 'Shelter Coordinator',
    lastMessage: 'Shelter A is at 75% capacity',
    lastMessageTimestamp: DateTime.now().subtract(const Duration(hours: 3)),
    unreadCount: 1,
  ),
  ChatSummary(
    id: '4',
    name: 'Supply Distribution',
    lastMessage: 'Water supplies running low in Zone 3',
    lastMessageTimestamp: DateTime.now().subtract(const Duration(days: 1)),
    unreadCount: 0,
  ),
  ChatSummary(
    id: '5',
    name: 'Community Watch',
    lastMessage: 'Power restored to downtown area',
    lastMessageTimestamp: DateTime.now().subtract(const Duration(days: 2)),
    unreadCount: 0,
  ),
];

final chatsListProvider = FutureProvider<List<ChatSummary>>((ref) async {
  // Simulate network delay - will replace with actual Isar query later
  await Future.delayed(const Duration(milliseconds: 500));
  return _placeholderChats;
});

final chatByIdProvider = FutureProvider.family<ChatSummary?, String>((ref, chatId) async {
  await Future.delayed(const Duration(milliseconds: 300));
  try {
    return _placeholderChats.firstWhere((chat) => chat.id == chatId);
  } catch (e) {
    return null;
  }
});
