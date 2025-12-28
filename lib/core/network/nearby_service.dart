import 'dart:async';
import 'dart:typed_data';
import 'package:nearby_connections/nearby_connections.dart';
import 'package:isar/isar.dart';
import '../database/sahayak_message.dart';
import 'message_serializer.dart';

class NearbyService {
  static const String _serviceId = 'sahayak-mesh';
  static const int _maxRetries = 3;
  
  final Isar _isar;
  final List<String> _connectedDevices = [];
  final List<SahayakMessage> _messageQueue = [];
  Timer? _broadcastTimer;
  Timer? _cleanupTimer;
  
  NearbyService(this._isar);

  Future<void> startAdvertising() async {
    try {
      await Nearby().startAdvertising(
        'Sahayak Device',
        Strategy.P2P_CLUSTER,
        onConnectionInitiated: _onConnectionInit,
        onConnectionResult: _onConnectionResult,
        onDisconnected: _onDisconnected,
        serviceId: _serviceId,
      );
      _startBroadcastTimer();
      _startCleanupTimer();
    } catch (e) {
      print('Error starting advertising: $e');
    }
  }

  Future<void> startDiscovery() async {
    try {
      await Nearby().startDiscovery(
        _serviceId,
        Strategy.P2P_CLUSTER,
        onEndpointFound: (endpointId, endpointName, serviceId) {
          print('Endpoint found: $endpointId ($endpointName)');
          connectToDevice(endpointId);
        },
        onEndpointLost: (endpointId) {
          print('Endpoint lost: $endpointId');
        },
      );
    } catch (e) {
      print('Error starting discovery: $e');
    }
  }

  Future<void> stop() async {
    _broadcastTimer?.cancel();
    _cleanupTimer?.cancel();
    await Nearby().stopAllEndpoints();
  }

  Future<void> connectToDevice(String endpointId) async {
    try {
      await Nearby().requestConnection(
        'Sahayak Device',
        endpointId,
        onConnectionInitiated: _onConnectionInit,
        onConnectionResult: _onConnectionResult,
        onDisconnected: _onDisconnected,
      );
    } catch (e) {
      print('Error connecting to device: $e');
    }
  }

  Future<void> sendMessage(SahayakMessage message) async {
    if (message.isExpired) {
      print('Message expired, dropping: ${message.id}');
      return;
    }

    // Add to queue for broadcasting
    _messageQueue.add(message);
    
    // Also save to local database
    await _isar.writeTxn(() async {
      await _isar.sahayakMessages.put(message);
    });
  }

  Future<void> broadcastMessages() async {
    if (_connectedDevices.isEmpty || _messageQueue.isEmpty) return;

    // Sort queue by priority (SOS first, then Medical, Alert, Chat)
    _messageQueue.sort((a, b) => a.priority.value.compareTo(b.priority.value));

    // Process messages in priority order
    for (final message in List.from(_messageQueue)) {
      if (message.isExpired) {
        _messageQueue.remove(message);
        continue;
      }

      // Decrease TTL for each hop
      final messageWithDecrementedTtl = message.copyWith(
        ttl: message.ttl - 1,
      );

      if (messageWithDecrementedTtl.ttl <= 0) {
        _messageQueue.remove(message);
        continue;
      }

      // Serialize and send to all connected devices
      try {
        final bytes = MessageSerializer.pack(messageWithDecrementedTtl);
        
        for (final endpointId in _connectedDevices) {
          await _sendWithRetry(endpointId, bytes);
        }
        
        // Remove from queue after successful broadcast
        _messageQueue.remove(message);
      } catch (e) {
        print('Error broadcasting message: $e');
      }
    }
  }

  Future<void> _sendWithRetry(String endpointId, Uint8List bytes, {int retryCount = 0}) async {
    try {
      await Nearby().sendBytesPayload(endpointId, bytes);
    } catch (e) {
      if (retryCount < _maxRetries) {
        await Future.delayed(Duration(milliseconds: 100 * (retryCount + 1)));
        await _sendWithRetry(endpointId, bytes, retryCount: retryCount + 1);
      } else {
        print('Failed to send after $_maxRetries retries: $e');
      }
    }
  }

  Future<void> _onConnectionInit(String endpointId, ConnectionInfo info) async {
    print('Connection initiated with: $endpointId');
  }

  Future<void> _onConnectionResult(String endpointId, Status status) async {
    if (status == Status.CONNECTED) {
      _connectedDevices.add(endpointId);
      print('Connected to: $endpointId');
    } else {
      print('Failed to connect to: $endpointId, status: $status');
    }
  }

  Future<void> _onDisconnected(String endpointId) async {
    _connectedDevices.remove(endpointId);
    print('Disconnected from: $endpointId');
  }

  Future<void> onBytesReceived(String endpointId, Uint8List bytes) async {
    try {
      final message = MessageSerializer.unpack(bytes);
      
      // Verify message integrity
      if (!message.verifyIntegrity()) {
        print('Message integrity check failed: ${message.id}');
        return;
      }

      // Check if message already exists (deduplication)
      final existingMessage = await _isar.sahayakMessages
          .where()
          .filter()
          .idEqualTo(message.id)
          .findFirst();
      
      if (existingMessage != null) {
        print('Duplicate message received: ${message.id}');
        return;
      }

      // Save to database
      await _isar.writeTxn(() async {
        await _isar.sahayakMessages.put(message);
      });

      // Add to queue for rebroadcasting (if TTL allows)
      if (!message.isExpired) {
        _messageQueue.add(message);
      }

      print('Received message: ${message.id} with priority: ${message.priority}');
    } catch (e) {
      print('Error processing received bytes: $e');
    }
  }

  void _startBroadcastTimer() {
    _broadcastTimer = Timer.periodic(Duration(seconds: 2), (_) {
      broadcastMessages();
    });
  }

  void _startCleanupTimer() {
    _cleanupTimer = Timer.periodic(Duration(minutes: 5), (_) {
      _cleanupExpiredMessages();
    });
  }

  Future<void> _cleanupExpiredMessages() async {
    await _isar.writeTxn(() async {
      final expiredMessages = await _isar.sahayakMessages
          .where()
          .filter()
          .ttlLessThan(1)
          .findAll();
      
      if (expiredMessages.isNotEmpty) {
        await _isar.sahayakMessages.deleteAll(expiredMessages.map((m) => m.isarId).toList());
        print('Cleaned up ${expiredMessages.length} expired messages');
      }
    });

    // Also remove expired messages from queue
    _messageQueue.removeWhere((message) => message.isExpired);
  }

  Future<List<SahayakMessage>> getMessagesByPriority(MessagePriority priority) async {
    return await _isar.sahayakMessages
        .where()
        .filter()
        .priorityEqualTo(priority)
        .findAll();
  }

  Future<List<SahayakMessage>> getAllUnexpiredMessages() async {
    return await _isar.sahayakMessages
        .where()
        .filter()
        .ttlGreaterThan(0)
        .findAll();
  }
}
