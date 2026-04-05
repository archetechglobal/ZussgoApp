import 'dart:async';
import 'dart:convert';
import '../config/api.dart';
import 'dart:io';

class ChatService {
  static WebSocket? _socket;
  static String? _userId;
  static bool _isConnected = false;

  // Stream controllers for real-time events
  static final _messageController = StreamController<Map<String, dynamic>>.broadcast();
  static final _typingController = StreamController<Map<String, dynamic>>.broadcast();

  // Streams that screens listen to
  static Stream<Map<String, dynamic>> get onMessage => _messageController.stream;
  static Stream<Map<String, dynamic>> get onTyping => _typingController.stream;
  static bool get isConnected => _isConnected;

  // Connect to WebSocket
  static Future<void> connect(String userId) async {
    if (_isConnected && _userId == userId) return;

    _userId = userId;

    try {
      final wsUrl = ApiConfig.baseUrl.replaceFirst('http', 'ws');
      _socket = await WebSocket.connect('$wsUrl/ws/chat?userId=$userId');
      _socket!.pingInterval = const Duration(seconds: 15);
      _isConnected = true;

      _socket!.listen(
            (data) {
          final message = jsonDecode(data);
          switch (message['type']) {
            case 'new_message':
            case 'message_sent':
              _messageController.add(message['data']);
              break;
            case 'typing':
              _typingController.add(message);
              break;
          }
        },
        onDone: () {
          _isConnected = false;
          // Auto-reconnect after 3 seconds
          Future.delayed(const Duration(seconds: 3), () {
            if (_userId != null) connect(_userId!);
          });
        },
        onError: (error) {
          _isConnected = false;
        },
      );
    } catch (e) {
      _isConnected = false;
      // Retry after 5 seconds
      Future.delayed(const Duration(seconds: 5), () {
        if (_userId != null) connect(_userId!);
      });
    }
  }

  // Send a chat message
  static void sendMessage(String conversationId, String content) {
    if (_socket == null || !_isConnected) return;

    _socket!.add(jsonEncode({
      'type': 'message',
      'conversationId': conversationId,
      'content': content,
    }));
  }

  // Send typing indicator
  static void sendTyping(String conversationId) {
    if (_socket == null || !_isConnected) return;

    _socket!.add(jsonEncode({
      'type': 'typing',
      'conversationId': conversationId,
    }));
  }

  // Mark messages as read
  static void markRead(String conversationId) {
    if (_socket == null || !_isConnected) return;

    _socket!.add(jsonEncode({
      'type': 'read',
      'conversationId': conversationId,
    }));
  }

  // Disconnect
  static void disconnect() {
    _socket?.close(WebSocketStatus.normalClosure, 'Client disconnecting normally');
    _socket = null;
    _isConnected = false;
    _userId = null;
  }
}