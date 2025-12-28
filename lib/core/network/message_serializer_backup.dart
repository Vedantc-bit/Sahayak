import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import '../database/sahayak_message.dart';

class MessageSerializer {
  static const int _version = 1;
  
  static Uint8List pack(SahayakMessage message) {
    final buffer = <int>[];
    
    // Write version (1 byte)
    buffer.add(_version);
    
    // Write priority (1 byte)
    buffer.add(message.priority.value);
    
    // Write TTL (1 byte)
    buffer.add(message.ttl.clamp(0, 255));
    
    // Write flags (1 byte) - bit 0: hasLocation, bit 1: hasMetadata
    int flags = 0;
    if (message.location.latitude != 0 || message.location.longitude != 0) {
      flags |= 0x01;
    }
    if (message.metadata.isNotEmpty) {
      flags |= 0x02;
    }
    buffer.add(flags);
    
    // Write message ID (variable length)
    final messageIdBytes = utf8.encode(message.id);
    _writeVarInt(buffer, messageIdBytes.length);
    buffer.addAll(messageIdBytes);
    
    // Write sender ID (variable length)
    final senderIdBytes = utf8.encode(message.senderId);
    _writeVarInt(buffer, senderIdBytes.length);
    buffer.addAll(senderIdBytes);
    
    // Write content (variable length)
    final contentBytes = utf8.encode(message.content);
    _writeVarInt(buffer, contentBytes.length);
    buffer.addAll(contentBytes);
    
    // Write hash (64 bytes for hex SHA-256)
    final hashBytes = utf8.encode(message.hash);
    if (hashBytes.length < 64) {
      // Pad to 64 bytes if needed
      final padded = List<int>.filled(64, 0);
      for (int i = 0; i < hashBytes.length; i++) {
        padded[i] = hashBytes[i];
      }
      buffer.addAll(padded);
    } else {
      buffer.addAll(hashBytes.sublist(0, 64));
    }
    
    // Write timestamp (8 bytes - milliseconds since epoch)
    final timestampBytes = ByteData(8)
      ..setInt64(0, message.timestamp.millisecondsSinceEpoch);
    buffer.addAll(timestampBytes.buffer.asUint8List());
    
    // Write location if present
    if (flags & 0x01 != 0) {
      final locationBytes = ByteData(32);
      locationBytes.setFloat64(0, message.location.latitude);
      locationBytes.setFloat64(8, message.location.longitude);
      locationBytes.setFloat64(16, message.location.altitude ?? 0.0);
      locationBytes.setFloat64(24, message.location.accuracy ?? 0.0);
      buffer.addAll(locationBytes.buffer.asUint8List());
    }
    
    // Write metadata if present
    if (flags & 0x02 != 0) {
      final metadataJson = message.metadataJson;
      final metadataBytes = utf8.encode(metadataJson);
      _writeVarInt(buffer, metadataBytes.length);
      buffer.addAll(metadataBytes);
    }
    
    // Compress the entire payload
    final uncompressed = Uint8List.fromList(buffer);
    final compressed = gzip.encode(uncompressed);
    
    return Uint8List.fromList(compressed);
  }
  
  static SahayakMessage unpack(Uint8List bytes) {
    // Decompress first
    final decompressed = gzip.decode(bytes);
    final data = Uint8List.fromList(decompressed);
    int offset = 0;
    
    // Read version
    final version = data[offset++];
    if (version != _version) {
      throw FormatException('Unsupported message version: $version');
    }
    
    // Read priority
    final priorityValue = data[offset++];
    final priority = MessagePriority.fromValue(priorityValue);
    
    // Read TTL
    final ttl = data[offset++];
    
    // Read flags
    final flags = data[offset++];
    final hasLocation = (flags & 0x01) != 0;
    final hasMetadata = (flags & 0x02) != 0;
    
    // Read message ID
    final messageIdLength = _readVarInt(data, offset);
    offset += _varIntLength(messageIdLength);
    final messageId = utf8.decode(data.sublist(offset, offset + messageIdLength));
    offset += messageIdLength;
    
    // Read sender ID
    final senderIdLength = _readVarInt(data, offset);
    offset += _varIntLength(senderIdLength);
    final senderId = utf8.decode(data.sublist(offset, offset + senderIdLength));
    offset += senderIdLength;
    
    // Read content
    final contentLength = _readVarInt(data, offset);
    offset += _varIntLength(contentLength);
    final content = utf8.decode(data.sublist(offset, offset + contentLength));
    offset += contentLength;
    
    // Read hash (64 bytes)
    final hashBytes = data.sublist(offset, offset + 64);
    final hash = utf8.decode(hashBytes.where((b) => b != 0).toList());
    offset += 64;
    
    // Read timestamp (8 bytes - milliseconds since epoch)
    final timestampBytes = ByteData.view(data.buffer, offset, 8);
    final timestampMs = timestampBytes.getInt64(0);
    final timestamp = DateTime.fromMillisecondsSinceEpoch(timestampMs.clamp(-8640000000000000, 8640000000000000));
    offset += 8;
    
    // Read location if present
    GeoLocation location = const GeoLocation(latitude: 0, longitude: 0);
    if (hasLocation) {
      final locationBytes = ByteData.view(data.buffer, offset, 32);
      location = GeoLocation(
        latitude: locationBytes.getFloat64(0),
        longitude: locationBytes.getFloat64(8),
        altitude: locationBytes.getFloat64(16) == 0.0 ? null : locationBytes.getFloat64(16),
        accuracy: locationBytes.getFloat64(24) == 0.0 ? null : locationBytes.getFloat64(24),
      );
      offset += 32;
    }
    
    // Read metadata if present
    String metadataJson = '{}';
    if (hasMetadata) {
      final metadataLength = _readVarInt(data, offset);
      offset += _varIntLength(metadataLength);
      metadataJson = utf8.decode(data.sublist(offset, offset + metadataLength));
      offset += metadataLength;
    }
    
    return SahayakMessage(
      id: messageId,
      senderId: senderId,
      content: content,
      priority: priority,
      location: location,
      metadataJson: metadataJson,
      ttl: ttl,
      hash: hash,
      timestamp: timestamp,
      isSent: false, // Will be set when actually sent
    );
  }
  
  static void _writeVarInt(List<int> buffer, int value) {
    while (value >= 0x80) {
      buffer.add((value & 0x7F) | 0x80);
      value >>= 7;
    }
    buffer.add(value & 0x7F);
  }
  
  static int _readVarInt(Uint8List data, int offset) {
    int value = 0;
    int shift = 0;
    int byte;
    
    do {
      byte = data[offset++];
      value |= (byte & 0x7F) << shift;
      shift += 7;
    } while (byte & 0x80 != 0);
    
    return value;
  }
  
  static int _varIntLength(int value) {
    int length = 0;
    while (value >= 0x80) {
      length++;
      value >>= 7;
    }
    return length + 1;
  }
}
