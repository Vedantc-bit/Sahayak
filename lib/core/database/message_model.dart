import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';

part 'message_model.freezed.dart';
part 'message_model.g.dart';

@freezed
@Collection(ignore: {'copyWith'})
class Message with _$Message {
  const Message._();

  external Id get isarId;
  external String get id;
  external String get content;
  external String get senderId;
  external DateTime get timestamp;
  external bool get isSent;
  
  const factory Message({
    @Default(Isar.autoIncrement) Id isarId,
    required String id,
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
}
