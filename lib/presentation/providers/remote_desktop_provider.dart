import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../../data/models/session_model.dart';
import '../../data/services/signaling_service.dart';
import '../../data/services/webrtc_service.dart';
import '../../data/services/storage_service.dart';
import '../../data/services/file_transfer_service.dart';
import '../../core/utils/utils.dart';
import '../../core/constants/app_constants.dart';

class RemoteDesktopProvider extends ChangeNotifier {
  final SignalingService _signalingService = SignalingService();
  final WebRTCService _webrtcService = WebRTCService();
  final StorageService _storageService = StorageService();
  final FileTransferService _fileTransferService = FileTransferService();

  SessionModel? _currentSession;
  bool _isInitialized = false;
  String? _errorMessage;
  bool _isAudioEnabled = true;
  bool _isVideoEnabled = true;
  bool _isJoiningSession = false; // Prevent duplicate joins

  SessionModel? get currentSession => _currentSession;
  bool get isInitialized => _isInitialized;
  String? get errorMessage => _errorMessage;
  bool get isAudioEnabled => _isAudioEnabled;
  bool get isVideoEnabled => _isVideoEnabled;
  bool get isHost => _currentSession?.type == SessionType.host;
  bool get isConnected => _currentSession?.status == SessionStatus.connected;

  Stream get remoteStream => _webrtcService.onRemoteStream;
  Stream get connectionStats => _webrtcService.onStatsUpdate;
  Stream get fileTransferUpdates => _fileTransferService.onTransferUpdate;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await _storageService.init();
      await _signalingService.connect();
      await _webrtcService.initialize();

      // Listen to signaling messages
      _signalingService.onMessage.listen(_handleSignalingMessage);

      // Listen to ICE candidates
      _webrtcService.onIceCandidate.listen((candidate) {
        if (_currentSession != null) {
          _signalingService.sendIceCandidate(
            _currentSession!.sessionId,
            candidate.toMap(),
          );
        }
      });

      // Listen to data channel messages
      _webrtcService.onDataChannelMessage.listen(_handleDataChannelMessage);

      // Setup file transfer callback
      _fileTransferService.onSendData = (data) {
        _webrtcService.sendData(data.toString());
      };

      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Initialization failed: $e';
      notifyListeners();
    }
  }

  Future<void> startHostSession({String? password}) async {
    try {
      final sessionId = Utils.generateSessionId();
      final hashedPassword = password != null ? Utils.hashPassword(password) : null;

      _currentSession = SessionModel(
        sessionId: sessionId,
        password: hashedPassword,
        createdAt: DateTime.now(),
        type: SessionType.host,
        status: SessionStatus.connecting,
      );

      // Save password if provided
      if (password != null) {
        await _storageService.savePassword(password);
      }

      // Create session on signaling server
      await _signalingService.createSession(sessionId, hashedPassword);

      // Get quality settings
      final qualityPreset = _storageService.getQualityPreset();
      final resolution = AppConstants.videoResolutions[qualityPreset]!;
      final frameRate = _storageService.getFrameRate();

      // Create display stream
      await _webrtcService.createDisplayStream(
        width: resolution['width']!,
        height: resolution['height']!,
        frameRate: frameRate,
      );

      // Create data channel for input events
      await _webrtcService.createDataChannel('control');

      _currentSession = _currentSession!.copyWith(status: SessionStatus.connected);
      notifyListeners();

      // Add to history
      await _storageService.addSessionToHistory({
        'sessionId': sessionId,
        'type': 'host',
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      _errorMessage = 'Failed to start host session: $e';
      _currentSession = _currentSession?.copyWith(status: SessionStatus.error);
      notifyListeners();
    }
  }

  Future<void> connectToSession(String sessionId, {String? password}) async {
    try {
      // Prevent duplicate join attempts
      if (_isJoiningSession) {
        debugPrint('Already joining session, ignoring duplicate request');
        return;
      }

      if (!Utils.isValidSessionId(sessionId)) {
        _errorMessage = 'Invalid session ID format';
        notifyListeners();
        return;
      }

      _isJoiningSession = true;
      final cleanSessionId = Utils.unformatSessionId(sessionId);
      final hashedPassword = password != null ? Utils.hashPassword(password) : null;

      _currentSession = SessionModel(
        sessionId: cleanSessionId,
        password: hashedPassword,
        createdAt: DateTime.now(),
        type: SessionType.client,
        status: SessionStatus.connecting,
      );
      notifyListeners();

      debugPrint('Joining session: $cleanSessionId');

      // Join session on signaling server
      await _signalingService.joinSession(cleanSessionId, hashedPassword);

      // Add to history
      await _storageService.addSessionToHistory({
        'sessionId': cleanSessionId,
        'type': 'client',
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      _errorMessage = 'Failed to connect: $e';
      _currentSession = _currentSession?.copyWith(status: SessionStatus.error);
      _isJoiningSession = false;
      notifyListeners();
    }
  }

  Future<void> _handleSignalingMessage(Map<String, dynamic> message) async {
    try {
      final type = message['type'] as String;
      debugPrint('Handling signaling message: $type');

      switch (type) {
        case 'offer':
          // Only process offer if we're a client
          if (_currentSession?.type != SessionType.client) {
            debugPrint('Ignoring offer - we are not a client');
            return;
          }

          final offerMap = message['data']['offer'] as Map<String, dynamic>;
          final offer = RTCSessionDescription(
            offerMap['sdp'] as String,
            offerMap['type'] as String,
          );

          debugPrint('Received offer, setting remote description');
          await _webrtcService.setRemoteDescription(offer);

          debugPrint('Creating answer');
          final answer = await _webrtcService.createAnswer();

          debugPrint('Sending answer to signaling server');
          _signalingService.sendAnswer(_currentSession!.sessionId, answer.toMap());
          break;

        case 'answer':
          // Only process answer if we're a host
          if (_currentSession?.type != SessionType.host) {
            debugPrint('Ignoring answer - we are not a host');
            return;
          }

          final answerMap = message['data']['answer'] as Map<String, dynamic>;
          final answer = RTCSessionDescription(
            answerMap['sdp'] as String,
            answerMap['type'] as String,
          );

          debugPrint('Received answer, setting remote description');
          await _webrtcService.setRemoteDescription(answer);
          break;

        case 'ice-candidate':
          final candidateMap = message['data']['candidate'] as Map<String, dynamic>;
          final candidate = RTCIceCandidate(
            candidateMap['candidate'] as String,
            candidateMap['sdpMid'] as String,
            candidateMap['sdpMLineIndex'] as int,
          );

          debugPrint('Adding ICE candidate');
          await _webrtcService.addIceCandidate(candidate);
          break;

        case 'peer-joined':
          debugPrint('Peer joined event received');
          if (_currentSession?.type == SessionType.host) {
            // Create offer for the new peer
            debugPrint('We are host, creating offer');
            final offer = await _webrtcService.createOffer();
            _signalingService.sendOffer(_currentSession!.sessionId, offer.toMap());
          }
          _currentSession = _currentSession?.copyWith(status: SessionStatus.connected);
          notifyListeners();
          break;

        case 'session-joined':
          debugPrint('Successfully joined session');
          _isJoiningSession = false; // Reset flag
          // Wait for offer from host
          _currentSession = _currentSession?.copyWith(status: SessionStatus.connecting);
          notifyListeners();
          break;

        case 'error':
          debugPrint('Session error: ${message['data']}');
          _errorMessage = message['data']['message'] ?? 'Unknown error';
          _isJoiningSession = false; // Reset flag on error
          _currentSession = _currentSession?.copyWith(status: SessionStatus.error);
          notifyListeners();
          break;

        case 'peer-left':
          await disconnect();
          break;

        case 'error':
          _errorMessage = message['data']['message'] as String;
          _currentSession = _currentSession?.copyWith(status: SessionStatus.error);
          notifyListeners();
          break;
      }
    } catch (e) {
      _errorMessage = 'Error handling signaling message: $e';
      notifyListeners();
    }
  }

  void _handleDataChannelMessage(Map<String, dynamic> message) {
    try {
      final type = message['type'] as String;

      switch (type) {
        case 'mouse':
          // Handle mouse event
          _handleMouseEvent(message['data']);
          break;
        case 'keyboard':
          // Handle keyboard event
          _handleKeyboardEvent(message['data']);
          break;
        case 'file-metadata':
          _fileTransferService.handleIncomingFileMetadata(message['data']);
          break;
        case 'file-chunk':
          _fileTransferService.handleIncomingFileChunk(message['data']);
          break;
        case 'file-complete':
          _fileTransferService.handleFileComplete(message['data']['id']);
          break;
      }
    } catch (e) {
      debugPrint('Error handling data channel message: $e');
    }
  }

  void sendMouseEvent(String eventType, double x, double y, {int? button}) {
    if (!isConnected) return;

    final event = {
      'type': 'mouse',
      'data': {
        'eventType': eventType,
        'x': x,
        'y': y,
        'button': button,
      },
    };

    _webrtcService.sendData(event.toString());
  }

  void sendKeyboardEvent(String key, bool isDown) {
    if (!isConnected) return;

    final event = {
      'type': 'keyboard',
      'data': {
        'key': key,
        'isDown': isDown,
      },
    };

    _webrtcService.sendData(event.toString());
  }

  void _handleMouseEvent(Map<String, dynamic> data) {
    // Platform-specific mouse event handling will be implemented in native code
    // This will use MethodChannel to communicate with native Android/Windows code
    debugPrint('Mouse event: $data');
  }

  void _handleKeyboardEvent(Map<String, dynamic> data) {
    // Platform-specific keyboard event handling will be implemented in native code
    debugPrint('Keyboard event: $data');
  }

  Future<void> sendFile() async {
    try {
      final transfer = await _fileTransferService.pickAndPrepareFile();
      if (transfer != null) {
        await _fileTransferService.sendFile(transfer);
      }
    } catch (e) {
      _errorMessage = 'Failed to send file: $e';
      notifyListeners();
    }
  }

  Future<void> toggleAudio() async {
    _isAudioEnabled = !_isAudioEnabled;
    await _webrtcService.toggleAudio(_isAudioEnabled);
    notifyListeners();
  }

  Future<void> toggleVideo() async {
    _isVideoEnabled = !_isVideoEnabled;
    await _webrtcService.toggleVideo(_isVideoEnabled);
    notifyListeners();
  }

  void copySessionIdToClipboard() {
    if (_currentSession != null) {
      Clipboard.setData(ClipboardData(text: _currentSession!.sessionId));
    }
  }

  Future<void> disconnect() async {
    try {
      await _signalingService.leaveSession();
      await _webrtcService.dispose();

      _currentSession = _currentSession?.copyWith(status: SessionStatus.disconnected);
      notifyListeners();

      // Reinitialize for next connection
      await _webrtcService.initialize();
    } catch (e) {
      _errorMessage = 'Error disconnecting: $e';
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _signalingService.dispose();
    _webrtcService.dispose();
    _fileTransferService.dispose();
    super.dispose();
  }
}

