import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';

part 'message_model.freezed.dart';
part 'message_model.g.dart';

@freezed
@Collection(ignore: {'copyWith'})
class Message with _$Message {
  const Message._();
  
  const factory Message({
    @Id() @Default('') String id,
    required String content,
    required String senderId,
    required DateTime timestamp,
    required bool isSent,
  }) = _Message;

  factory Message.create({
    required String content,
    required String senderId,
    required bool isSent,
    DateTime? timestamp,
  }) {
    return Message(
      id: const Uuid().v4(),
      content: content,
      senderId: senderId,
      timestamp: timestamp ?? DateTime.now(),
      isSent: isSent,
    );
  }

  factory Message.fromJson(Map<String, dynamic> json) => _$MessageFromJson(json);

  // Add this to make Isar work with freezed
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Message &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          content == other.content &&
          senderId == other.senderId &&
          timestamp == other.timestamp &&
          isSent == other.isSent;

  @override
  int get hashCode => Object.hash(id, content, senderId, timestamp, isSent);
}
