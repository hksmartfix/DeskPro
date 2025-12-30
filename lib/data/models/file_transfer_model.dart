class FileTransferModel {
  final String id;
  final String fileName;
  final int fileSize;
  final String filePath;
  final FileTransferDirection direction;
  final FileTransferStatus status;
  final int bytesTransferred;
  final DateTime startedAt;

  FileTransferModel({
    required this.id,
    required this.fileName,
    required this.fileSize,
    required this.filePath,
    required this.direction,
    this.status = FileTransferStatus.pending,
    this.bytesTransferred = 0,
    required this.startedAt,
  });

  FileTransferModel copyWith({
    String? id,
    String? fileName,
    int? fileSize,
    String? filePath,
    FileTransferDirection? direction,
    FileTransferStatus? status,
    int? bytesTransferred,
    DateTime? startedAt,
  }) {
    return FileTransferModel(
      id: id ?? this.id,
      fileName: fileName ?? this.fileName,
      fileSize: fileSize ?? this.fileSize,
      filePath: filePath ?? this.filePath,
      direction: direction ?? this.direction,
      status: status ?? this.status,
      bytesTransferred: bytesTransferred ?? this.bytesTransferred,
      startedAt: startedAt ?? this.startedAt,
    );
  }

  double get progress {
    if (fileSize == 0) return 0.0;
    return bytesTransferred / fileSize;
  }

  String get progressPercentage {
    return '${(progress * 100).toStringAsFixed(1)}%';
  }
}

enum FileTransferDirection {
  sending,
  receiving,
}

enum FileTransferStatus {
  pending,
  transferring,
  completed,
  failed,
  cancelled,
}

