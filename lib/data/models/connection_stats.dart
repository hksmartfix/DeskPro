class ConnectionStats {
  final int bitrate;
  final int frameRate;
  final int latency;
  final int packetsLost;
  final int packetsSent;
  final int packetsReceived;
  final String resolution;
  final Duration connectionDuration;

  ConnectionStats({
    this.bitrate = 0,
    this.frameRate = 0,
    this.latency = 0,
    this.packetsLost = 0,
    this.packetsSent = 0,
    this.packetsReceived = 0,
    this.resolution = '0x0',
    this.connectionDuration = Duration.zero,
  });

  ConnectionStats copyWith({
    int? bitrate,
    int? frameRate,
    int? latency,
    int? packetsLost,
    int? packetsSent,
    int? packetsReceived,
    String? resolution,
    Duration? connectionDuration,
  }) {
    return ConnectionStats(
      bitrate: bitrate ?? this.bitrate,
      frameRate: frameRate ?? this.frameRate,
      latency: latency ?? this.latency,
      packetsLost: packetsLost ?? this.packetsLost,
      packetsSent: packetsSent ?? this.packetsSent,
      packetsReceived: packetsReceived ?? this.packetsReceived,
      resolution: resolution ?? this.resolution,
      connectionDuration: connectionDuration ?? this.connectionDuration,
    );
  }

  double get packetLossRate {
    final total = packetsSent + packetsReceived;
    if (total == 0) return 0.0;
    return (packetsLost / total) * 100;
  }
}

