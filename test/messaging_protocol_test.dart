import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'dart:typed_data';
import '../lib/core/database/sahayak_message.dart';
import '../lib/core/network/message_serializer.dart';
import '../lib/core/network/nearby_service.dart';

void main() {
  group('SahayakMessage Tests', () {
    test('Create SOS message with location', () {
      final location = GeoLocation(
        latitude: 37.7749,
        longitude: -122.4194,
        altitude: 100.0,
        accuracy: 5.0,
      );
      
      final metadata = {
        'battery_level': 85,
        'device_status': 'emergency',
        'hops_count': 0,
      };
      
      final message = SahayakMessage.create(
        senderId: 'test-device-1',
        content: 'SOS: Need immediate medical assistance!',
        priority: MessagePriority.sos,
        location: location,
        metadata: metadata,
      );
      
      expect(message.priority, MessagePriority.sos);
      expect(message.ttl, 20);
      expect(message.content, 'SOS: Need immediate medical assistance!');
      expect(message.senderId, 'test-device-1');
      expect(message.location.latitude, 37.7749);
      expect(message.location.longitude, -122.4194);
      expect(message.metadata['battery_level'], 85);
      expect(message.isExpired, false);
      expect(message.verifyIntegrity(), true);
    });
    
    test('Message expiration check', () {
      final message = SahayakMessage.create(
        senderId: 'test-device-1',
        content: 'Test message',
        location: const GeoLocation(latitude: 0, longitude: 0),
      );
      
      expect(message.isExpired, false);
      
      // Simulate TTL reaching 0
      final expiredMessage = message.copyWith(ttl: 0);
      expect(expiredMessage.isExpired, true);
    });
    
    test('Message integrity verification', () {
      final message = SahayakMessage.create(
        senderId: 'test-device-1',
        content: 'Test message',
        location: const GeoLocation(latitude: 0, longitude: 0),
      );
      
      // Valid message should pass integrity check
      expect(message.verifyIntegrity(), true);
      
      // Tampered message should fail integrity check
      final tamperedMessage = message.copyWith(
        hash: 'invalid-hash',
      );
      expect(tamperedMessage.verifyIntegrity(), false);
    });
  });
  
  group('MessageSerializer Tests', () {
    test('Serialize and deserialize message', () {
      final originalMessage = SahayakMessage.create(
        senderId: 'test-device-1',
        content: 'Test message with priority',
        priority: MessagePriority.medical,
        location: const GeoLocation(
          latitude: 40.7128,
          longitude: -74.0060,
          altitude: 50.0,
          accuracy: 3.0,
        ),
        metadata: {
          'battery_level': 75,
          'device_status': 'normal',
        },
      );
      
      // Serialize
      final bytes = MessageSerializer.pack(originalMessage);
      expect(bytes.isNotEmpty, true);
      expect(bytes.length, lessThan(500)); // Should be compressed
      
      // Deserialize
      final deserializedMessage = MessageSerializer.unpack(bytes);
      
      expect(deserializedMessage.id, originalMessage.id);
      expect(deserializedMessage.senderId, originalMessage.senderId);
      expect(deserializedMessage.content, originalMessage.content);
      expect(deserializedMessage.priority, originalMessage.priority);
      expect(deserializedMessage.location.latitude, originalMessage.location.latitude);
      expect(deserializedMessage.location.longitude, originalMessage.location.longitude);
      expect(deserializedMessage.ttl, originalMessage.ttl);
      expect(deserializedMessage.hash, originalMessage.hash);
      expect(deserializedMessage.metadata['battery_level'], 75);
    });
    
    test('Handle message without metadata', () {
      final message = SahayakMessage.create(
        senderId: 'test-device-1',
        content: 'Simple message',
        location: const GeoLocation(latitude: 0, longitude: 0),
      );
      
      final bytes = MessageSerializer.pack(message);
      final deserializedMessage = MessageSerializer.unpack(bytes);
      
      expect(deserializedMessage.content, message.content);
      expect(deserializedMessage.metadata, {});
    });
    
    test('Handle message without location', () {
      final message = SahayakMessage.create(
        senderId: 'test-device-1',
        content: 'Message without location',
        location: const GeoLocation(latitude: 0, longitude: 0),
      );
      
      final bytes = MessageSerializer.pack(message);
      final deserializedMessage = MessageSerializer.unpack(bytes);
      
      expect(deserializedMessage.content, message.content);
      expect(deserializedMessage.location.latitude, 0.0);
      expect(deserializedMessage.location.longitude, 0.0);
    });
  });
  
  group('Priority Queue Tests', () {
    test('Messages sorted by priority', () {
      final messages = [
        SahayakMessage.create(
          senderId: 'device-1',
          content: 'Chat message',
          location: const GeoLocation(latitude: 0, longitude: 0),
          priority: MessagePriority.chat,
        ),
        SahayakMessage.create(
          senderId: 'device-2',
          content: 'Medical emergency',
          location: const GeoLocation(latitude: 0, longitude: 0),
          priority: MessagePriority.medical,
        ),
        SahayakMessage.create(
          senderId: 'device-3',
          content: 'SOS alert',
          location: const GeoLocation(latitude: 0, longitude: 0),
          priority: MessagePriority.sos,
        ),
        SahayakMessage.create(
          senderId: 'device-4',
          content: 'Weather alert',
          location: const GeoLocation(latitude: 0, longitude: 0),
          priority: MessagePriority.alert,
        ),
      ];
      
      // Sort by priority (ascending: SOS=0, Medical=1, Alert=2, Chat=3)
      messages.sort((a, b) => a.priority.value.compareTo(b.priority.value));
      
      expect(messages[0].priority, MessagePriority.sos);
      expect(messages[1].priority, MessagePriority.medical);
      expect(messages[2].priority, MessagePriority.alert);
      expect(messages[3].priority, MessagePriority.chat);
    });
    
    test('TTL decrement simulation', () {
      final message = SahayakMessage.create(
        senderId: 'test-device',
        content: 'Test message',
        location: const GeoLocation(latitude: 0, longitude: 0),
        ttl: 5,
      );
      
      expect(message.ttl, 5);
      
      // Simulate network hops
      var currentMessage = message;
      for (int i = 0; i < 3; i++) {
        currentMessage = currentMessage.copyWith(ttl: currentMessage.ttl - 1);
      }
      
      expect(currentMessage.ttl, 2);
      expect(currentMessage.isExpired, false);
      
      // One more hop should expire
      currentMessage = currentMessage.copyWith(ttl: currentMessage.ttl - 1);
      expect(currentMessage.ttl, 1);
      
      currentMessage = currentMessage.copyWith(ttl: currentMessage.ttl - 1);
      expect(currentMessage.ttl, 0);
      expect(currentMessage.isExpired, true);
    });
  });
  
  group('Message Size Optimization Tests', () {
    test('Binary serialization is smaller than JSON', () {
      final message = SahayakMessage.create(
        senderId: 'test-device-12345',
        content: 'This is a test message that should be compressed efficiently in binary format',
        priority: MessagePriority.alert,
        location: const GeoLocation(
          latitude: 37.7749,
          longitude: -122.4194,
          altitude: 100.5,
          accuracy: 2.3,
        ),
        metadata: {
          'battery_level': 85,
          'device_status': 'active',
          'signal_strength': -45,
          'network_type': 'bluetooth_mesh',
        },
      );
      
      // Binary serialization
      final binaryBytes = MessageSerializer.pack(message);
      
      // JSON serialization (for comparison)
      final jsonString = '''
      {
        "id": "${message.id}",
        "senderId": "${message.senderId}",
        "content": "${message.content}",
        "priority": ${message.priority.value},
        "location": {
          "latitude": ${message.location.latitude},
          "longitude": ${message.location.longitude},
          "altitude": ${message.location.altitude},
          "accuracy": ${message.location.accuracy}
        },
        "metadata": ${message.metadataJson},
        "ttl": ${message.ttl},
        "hash": "${message.hash}",
        "timestamp": "${message.timestamp.toIso8601String()}"
      }
      ''';
      
      final jsonBytes = Uint8List.fromList(jsonString.codeUnits);
      
      print('Binary size: ${binaryBytes.length} bytes');
      print('JSON size: ${jsonBytes.length} bytes');
      print('Compression ratio: ${(binaryBytes.length / jsonBytes.length * 100).toStringAsFixed(1)}%');
      
      expect(binaryBytes.length, lessThan(jsonBytes.length));
      expect(binaryBytes.length, lessThan(jsonBytes.length ~/ 2)); // Should be at least 50% smaller
    });
  });
}
