import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

part 'sahayak_message.freezed.dart';
part 'sahayak_message.g.dart';

enum MessagePriority {
  sos(0),
  medical(1),
  alert(2),
  chat(3);

  const MessagePriority(this.value);
  final int value;

  static MessagePriority fromValue(int value) {
    return MessagePriority.values.firstWhere(
      (priority) => priority.value == value,
      orElse: () => MessagePriority.chat,
    );
  }
}

@embedded
class GeoLocation {
  final double latitude;
  final double longitude;
  final double? altitude;
  final double? accuracy;

  const GeoLocation({
    this.latitude = 0.0,
    this.longitude = 0.0,
    this.altitude,
    this.accuracy,
  });

  Map<String, dynamic> toJson() => {
    'latitude': latitude,
    'longitude': longitude,
    if (altitude != null) 'altitude': altitude,
    if (accuracy != null) 'accuracy': accuracy,
  };

  factory GeoLocation.fromJson(Map<String, dynamic> json) => GeoLocation(
    latitude: json['latitude'] as double,
    longitude: json['longitude'] as double,
    altitude: json['altitude'] as double?,
    accuracy: json['accuracy'] as double?,
  );
}

@freezed
@Collection(ignore: {'copyWith'})
class SahayakMessage with _$SahayakMessage {
  SahayakMessage._();

  external Id get isarId;
  external String get id;
  external String get senderId;
  external String get content;
  @enumerated
  external MessagePriority get priority;
  external GeoLocation get location;
  external final String metadataJson;
  external int get ttl;
  external String get hash;
  external DateTime get timestamp;
  external bool get isSent;

  @Index(composite: [CompositeIndex('priority')])
  external final String? chatId;

  factory SahayakMessage({
    @Default(Isar.autoIncrement) Id isarId,
    required String id,
    required String senderId,
    required String content,
    @Default(MessagePriority.chat) MessagePriority priority,
    required GeoLocation location,
    @Default('{}') String metadataJson,
    @Default(20) int ttl,
    required String hash,
    required DateTime timestamp,
    @Default(false) bool isSent,
    String? chatId,
  }) = _SahayakMessage;

  factory SahayakMessage.create({
    required String senderId,
    required String content,
    MessagePriority priority = MessagePriority.chat,
    required GeoLocation location,
    Map<String, dynamic> metadata = const {},
    int ttl = 20,
    String? chatId,
  }) {
    final messageId = const Uuid().v4();
    final contentBytes = utf8.encode(content);
    final hash = sha256.convert(contentBytes).toString();
    final metadataJson = jsonEncode(metadata);
    
    return SahayakMessage(
      id: messageId,
      senderId: senderId,
      content: content,
      priority: priority,
      location: location,
      metadataJson: metadataJson,
      ttl: ttl,
      hash: hash,
      timestamp: DateTime.now(),
      isSent: true,
      chatId: chatId,
    );
  }

  factory SahayakMessage.fromJson(Map<String, dynamic> json) => _$SahayakMessageFromJson(json);

  @ignore
  Map<String, dynamic> get metadata {
    try {
      return jsonDecode(metadataJson);
    } catch (e) {
      return {};
    }
  }

  bool get isExpired => ttl <= 0;

  bool verifyIntegrity() {
    final contentBytes = utf8.encode(content);
    final computedHash = sha256.convert(contentBytes).toString();
    return hash == computedHash;
  }
}
