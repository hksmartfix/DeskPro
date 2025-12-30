import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import '../../core/constants/app_constants.dart';
import '../models/connection_stats.dart';

class WebRTCService {
  static final WebRTCService _instance = WebRTCService._internal();
  factory WebRTCService() => _instance;
  WebRTCService._internal();

  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  MediaStream? _remoteStream;
  RTCDataChannel? _dataChannel;

  final StreamController<MediaStream?> _remoteStreamController =
      StreamController<MediaStream?>.broadcast();
  final StreamController<RTCIceCandidate> _iceCandidateController =
      StreamController<RTCIceCandidate>.broadcast();
  final StreamController<Map<String, dynamic>> _dataChannelController =
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<ConnectionStats> _statsController =
      StreamController<ConnectionStats>.broadcast();

  Stream<MediaStream?> get onRemoteStream => _remoteStreamController.stream;
  Stream<RTCIceCandidate> get onIceCandidate => _iceCandidateController.stream;
  Stream<Map<String, dynamic>> get onDataChannelMessage => _dataChannelController.stream;
  Stream<ConnectionStats> get onStatsUpdate => _statsController.stream;

  Timer? _statsTimer;
  DateTime? _connectionStartTime;

  Future<void> initialize() async {
    final config = {
      'iceServers': AppConstants.iceServers,
      'sdpSemantics': 'unified-plan',
    };

    final constraints = {
      'mandatory': {},
      'optional': [
        {'DtlsSrtpKeyAgreement': true},
      ],
    };

    _peerConnection = await createPeerConnection(config, constraints);

    _peerConnection!.onIceCandidate = (candidate) {
      _iceCandidateController.add(candidate);
    };

    _peerConnection!.onTrack = (event) {
      if (event.streams.isNotEmpty) {
        _remoteStream = event.streams[0];
        _remoteStreamController.add(_remoteStream);
      }
    };

    _peerConnection!.onIceConnectionState = (state) {
      debugPrint('ICE Connection State: $state');
      if (state == RTCIceConnectionState.RTCIceConnectionStateConnected) {
        _connectionStartTime = DateTime.now();
        _startStatsMonitoring();
      } else if (state == RTCIceConnectionState.RTCIceConnectionStateDisconnected ||
          state == RTCIceConnectionState.RTCIceConnectionStateFailed) {
        _stopStatsMonitoring();
      }
    };

    _peerConnection!.onDataChannel = (channel) {
      _setupDataChannel(channel);
    };
  }

  Future<void> createDisplayStream({
    required int width,
    required int height,
    required int frameRate,
  }) async {
    try {
      final mediaConstraints = {
        'audio': true,
        'video': {
          'mandatory': {
            'minWidth': width.toString(),
            'minHeight': height.toString(),
            'minFrameRate': frameRate.toString(),
          },
          'facingMode': 'user',
          'optional': [],
        }
      };

      _localStream = await navigator.mediaDevices.getDisplayMedia(mediaConstraints);

      for (var track in _localStream!.getTracks()) {
        _peerConnection!.addTrack(track, _localStream!);
      }
    } catch (e) {
      debugPrint('Error creating display stream: $e');
      rethrow;
    }
  }

  Future<RTCSessionDescription> createOffer() async {
    try {
      final offer = await _peerConnection!.createOffer({
        'offerToReceiveAudio': true,
        'offerToReceiveVideo': true,
      });
      await _peerConnection!.setLocalDescription(offer);
      return offer;
    } catch (e) {
      debugPrint('Error creating offer: $e');
      rethrow;
    }
  }

  Future<RTCSessionDescription> createAnswer() async {
    try {
      final answer = await _peerConnection!.createAnswer({
        'offerToReceiveAudio': true,
        'offerToReceiveVideo': true,
      });
      await _peerConnection!.setLocalDescription(answer);
      return answer;
    } catch (e) {
      debugPrint('Error creating answer: $e');
      rethrow;
    }
  }

  Future<void> setRemoteDescription(RTCSessionDescription description) async {
    await _peerConnection!.setRemoteDescription(description);
  }

  Future<void> addIceCandidate(RTCIceCandidate candidate) async {
    await _peerConnection!.addCandidate(candidate);
  }

  Future<void> createDataChannel(String label) async {
    final dataChannelDict = RTCDataChannelInit();
    dataChannelDict.ordered = true;

    _dataChannel = await _peerConnection!.createDataChannel(label, dataChannelDict);
    _setupDataChannel(_dataChannel!);
  }

  void _setupDataChannel(RTCDataChannel channel) {
    _dataChannel = channel;

    _dataChannel!.onMessage = (RTCDataChannelMessage message) {
      try {
        final data = message.text;
        // Parse message and emit
        _dataChannelController.add({'type': 'message', 'data': data});
      } catch (e) {
        debugPrint('Error handling data channel message: $e');
      }
    };

    _dataChannel!.onDataChannelState = (state) {
      debugPrint('Data Channel State: $state');
    };
  }

  void sendData(String data) {
    if (_dataChannel != null && _dataChannel!.state == RTCDataChannelState.RTCDataChannelOpen) {
      _dataChannel!.send(RTCDataChannelMessage(data));
    }
  }

  void _startStatsMonitoring() {
    _statsTimer?.cancel();
    _statsTimer = Timer.periodic(const Duration(seconds: 1), (_) async {
      await _updateStats();
    });
  }

  void _stopStatsMonitoring() {
    _statsTimer?.cancel();
    _statsTimer = null;
  }

  Future<void> _updateStats() async {
    if (_peerConnection == null) return;

    try {
      final stats = await _peerConnection!.getStats();
      int bitrate = 0;
      int frameRate = 0;
      int packetsLost = 0;
      int packetsSent = 0;
      int packetsReceived = 0;
      String resolution = '0x0';

      for (var report in stats) {
        if (report.type == 'outbound-rtp' && report.values['mediaType'] == 'video') {
          bitrate = (report.values['bytesSent'] as num?)?.toInt() ?? 0;
          packetsSent = (report.values['packetsSent'] as num?)?.toInt() ?? 0;
          frameRate = (report.values['framesPerSecond'] as num?)?.toInt() ?? 0;
        }
        if (report.type == 'inbound-rtp' && report.values['mediaType'] == 'video') {
          packetsReceived = (report.values['packetsReceived'] as num?)?.toInt() ?? 0;
          packetsLost = (report.values['packetsLost'] as num?)?.toInt() ?? 0;
          final width = report.values['frameWidth'];
          final height = report.values['frameHeight'];
          if (width != null && height != null) {
            resolution = '${width}x$height';
          }
        }
      }

      final duration = _connectionStartTime != null
          ? DateTime.now().difference(_connectionStartTime!)
          : Duration.zero;

      final connectionStats = ConnectionStats(
        bitrate: bitrate,
        frameRate: frameRate,
        latency: 0, // Calculate from ICE stats if available
        packetsLost: packetsLost,
        packetsSent: packetsSent,
        packetsReceived: packetsReceived,
        resolution: resolution,
        connectionDuration: duration,
      );

      _statsController.add(connectionStats);
    } catch (e) {
      debugPrint('Error updating stats: $e');
    }
  }

  Future<void> toggleAudio(bool enabled) async {
    if (_localStream != null) {
      _localStream!.getAudioTracks().forEach((track) {
        track.enabled = enabled;
      });
    }
  }

  Future<void> toggleVideo(bool enabled) async {
    if (_localStream != null) {
      _localStream!.getVideoTracks().forEach((track) {
        track.enabled = enabled;
      });
    }
  }

  Future<void> dispose() async {
    _stopStatsMonitoring();

    await _localStream?.dispose();
    await _remoteStream?.dispose();
    await _dataChannel?.close();
    await _peerConnection?.close();

    _localStream = null;
    _remoteStream = null;
    _dataChannel = null;
    _peerConnection = null;

    await _remoteStreamController.close();
    await _iceCandidateController.close();
    await _dataChannelController.close();
    await _statsController.close();
  }
}

