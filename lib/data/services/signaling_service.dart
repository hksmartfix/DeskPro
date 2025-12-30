import 'package:socket_io_client/socket_io_client.dart' as io;
import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../core/constants/app_constants.dart';

class SignalingService {
  static final SignalingService _instance = SignalingService._internal();
  factory SignalingService() => _instance;
  SignalingService._internal();

  io.Socket? _socket;
  String? _currentSessionId;

  final StreamController<Map<String, dynamic>> _messageController =
      StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get onMessage => _messageController.stream;

  bool get isConnected => _socket?.connected ?? false;

  Future<void> connect() async {
    if (_socket?.connected ?? false) return;

    _socket = io.io(
      AppConstants.signalingServerUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
          .enableReconnection()
          .setReconnectionAttempts(5)
          .setReconnectionDelay(2000)
          .build(),
    );

    _socket!.onConnect((_) {
      debugPrint('Connected to signaling server');
    });

    _socket!.onDisconnect((_) {
      debugPrint('Disconnected from signaling server');
    });

    _socket!.onConnectError((error) {
      debugPrint('Connection error: $error');
    });

    _socket!.on('message', (data) {
      _messageController.add(data as Map<String, dynamic>);
    });

    _socket!.on('offer', (data) {
      _messageController.add({'type': 'offer', 'data': data});
    });

    _socket!.on('answer', (data) {
      _messageController.add({'type': 'answer', 'data': data});
    });

    _socket!.on('ice-candidate', (data) {
      _messageController.add({'type': 'ice-candidate', 'data': data});
    });

    _socket!.on('session-error', (data) {
      _messageController.add({'type': 'error', 'data': data});
    });

    _socket!.on('peer-joined', (data) {
      _messageController.add({'type': 'peer-joined', 'data': data});
    });

    _socket!.on('peer-left', (data) {
      _messageController.add({'type': 'peer-left', 'data': data});
    });

    _socket!.connect();
  }

  Future<void> createSession(String sessionId, String? password) async {
    _currentSessionId = sessionId;
    _socket!.emit('create-session', {
      'sessionId': sessionId,
      'password': password,
    });
  }

  Future<void> joinSession(String sessionId, String? password) async {
    _currentSessionId = sessionId;
    _socket!.emit('join-session', {
      'sessionId': sessionId,
      'password': password,
    });
  }

  void sendOffer(String sessionId, Map<String, dynamic> offer) {
    _socket!.emit('offer', {
      'sessionId': sessionId,
      'offer': offer,
    });
  }

  void sendAnswer(String sessionId, Map<String, dynamic> answer) {
    _socket!.emit('answer', {
      'sessionId': sessionId,
      'answer': answer,
    });
  }

  void sendIceCandidate(String sessionId, Map<String, dynamic> candidate) {
    _socket!.emit('ice-candidate', {
      'sessionId': sessionId,
      'candidate': candidate,
    });
  }

  void sendMessage(String sessionId, Map<String, dynamic> message) {
    _socket!.emit('message', {
      'sessionId': sessionId,
      'message': message,
    });
  }

  Future<void> leaveSession() async {
    if (_currentSessionId != null) {
      _socket!.emit('leave-session', {'sessionId': _currentSessionId});
      _currentSessionId = null;
    }
  }

  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }

  void dispose() {
    disconnect();
    _messageController.close();
  }
}

