class SessionModel {
  final String sessionId;
  final String? password;
  final DateTime createdAt;
  final SessionType type;
  final String? remotePeerId;
  final SessionStatus status;

  SessionModel({
    required this.sessionId,
    this.password,
    required this.createdAt,
    required this.type,
    this.remotePeerId,
    this.status = SessionStatus.idle,
  });

  SessionModel copyWith({
    String? sessionId,
    String? password,
    DateTime? createdAt,
    SessionType? type,
    String? remotePeerId,
    SessionStatus? status,
  }) {
    return SessionModel(
      sessionId: sessionId ?? this.sessionId,
      password: password ?? this.password,
      createdAt: createdAt ?? this.createdAt,
      type: type ?? this.type,
      remotePeerId: remotePeerId ?? this.remotePeerId,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sessionId': sessionId,
      'password': password,
      'createdAt': createdAt.toIso8601String(),
      'type': type.toString(),
      'remotePeerId': remotePeerId,
      'status': status.toString(),
    };
  }

  factory SessionModel.fromJson(Map<String, dynamic> json) {
    return SessionModel(
      sessionId: json['sessionId'] as String,
      password: json['password'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      type: SessionType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => SessionType.client,
      ),
      remotePeerId: json['remotePeerId'] as String?,
      status: SessionStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
        orElse: () => SessionStatus.idle,
      ),
    );
  }
}

enum SessionType {
  host,
  client,
}

enum SessionStatus {
  idle,
  connecting,
  connected,
  disconnected,
  error,
}

