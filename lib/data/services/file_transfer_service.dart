import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../models/file_transfer_model.dart';
import '../../core/constants/app_constants.dart';

class FileTransferService {
  static final FileTransferService _instance = FileTransferService._internal();
  factory FileTransferService() => _instance;
  FileTransferService._internal();

  final Map<String, FileTransferModel> _activeTransfers = {};
  final StreamController<FileTransferModel> _transferUpdateController =
      StreamController<FileTransferModel>.broadcast();

  Stream<FileTransferModel> get onTransferUpdate => _transferUpdateController.stream;

  Function(Map<String, dynamic>)? onSendData;

  Future<FileTransferModel?> pickAndPrepareFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) return null;

      final file = result.files.first;

      if (file.size > AppConstants.maxFileSize) {
        throw Exception('File too large. Maximum size is ${AppConstants.maxFileSize ~/ (1024 * 1024)}MB');
      }

      final transferModel = FileTransferModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        fileName: file.name,
        fileSize: file.size,
        filePath: file.path!,
        direction: FileTransferDirection.sending,
        startedAt: DateTime.now(),
      );

      _activeTransfers[transferModel.id] = transferModel;
      return transferModel;
    } catch (e) {
      debugPrint('Error picking file: $e');
      rethrow;
    }
  }

  Future<void> sendFile(FileTransferModel transfer) async {
    try {
      final file = File(transfer.filePath);
      if (!await file.exists()) {
        throw Exception('File not found');
      }

      // Update status to transferring
      _updateTransfer(transfer.id, FileTransferStatus.transferring, 0);

      // Send file metadata
      onSendData?.call({
        'type': 'file-metadata',
        'id': transfer.id,
        'fileName': transfer.fileName,
        'fileSize': transfer.fileSize,
      });

      // Read and send file in chunks
      final stream = file.openRead();
      int bytesRead = 0;

      await for (var chunk in stream) {
        final base64Chunk = base64Encode(chunk);

        onSendData?.call({
          'type': 'file-chunk',
          'id': transfer.id,
          'chunk': base64Chunk,
          'offset': bytesRead,
        });

        bytesRead += chunk.length;
        _updateTransfer(transfer.id, FileTransferStatus.transferring, bytesRead);

        // Add small delay to prevent overwhelming the data channel
        await Future.delayed(const Duration(milliseconds: 10));
      }

      // Send completion message
      onSendData?.call({
        'type': 'file-complete',
        'id': transfer.id,
      });

      _updateTransfer(transfer.id, FileTransferStatus.completed, bytesRead);
    } catch (e) {
      debugPrint('Error sending file: $e');
      _updateTransfer(transfer.id, FileTransferStatus.failed, transfer.bytesTransferred);
      rethrow;
    }
  }

  Future<void> handleIncomingFileMetadata(Map<String, dynamic> metadata) async {
    try {
      final transfer = FileTransferModel(
        id: metadata['id'] as String,
        fileName: metadata['fileName'] as String,
        fileSize: metadata['fileSize'] as int,
        filePath: '', // Will be set when saving
        direction: FileTransferDirection.receiving,
        status: FileTransferStatus.transferring,
        startedAt: DateTime.now(),
      );

      _activeTransfers[transfer.id] = transfer;
      _transferUpdateController.add(transfer);
    } catch (e) {
      debugPrint('Error handling file metadata: $e');
    }
  }

  Future<void> handleIncomingFileChunk(Map<String, dynamic> chunkData) async {
    try {
      final id = chunkData['id'] as String;
      final chunk = chunkData['chunk'] as String;
      final offset = chunkData['offset'] as int;

      final transfer = _activeTransfers[id];
      if (transfer == null) return;

      // Decode chunk
      final bytes = base64Decode(chunk);

      // Get or create file
      final dir = await getApplicationDocumentsDirectory();
      final filePath = '${dir.path}/${transfer.fileName}';
      final file = File(filePath);

      // Append chunk to file
      await file.writeAsBytes(bytes, mode: FileMode.append);

      // Update transfer
      final bytesTransferred = offset + bytes.length;
      final updatedTransfer = transfer.copyWith(
        filePath: filePath,
        bytesTransferred: bytesTransferred,
      );

      _activeTransfers[id] = updatedTransfer;
      _transferUpdateController.add(updatedTransfer);
    } catch (e) {
      debugPrint('Error handling file chunk: $e');
    }
  }

  Future<void> handleFileComplete(String id) async {
    final transfer = _activeTransfers[id];
    if (transfer == null) return;

    _updateTransfer(id, FileTransferStatus.completed, transfer.fileSize);
  }

  void _updateTransfer(String id, FileTransferStatus status, int bytesTransferred) {
    final transfer = _activeTransfers[id];
    if (transfer == null) return;

    final updated = transfer.copyWith(
      status: status,
      bytesTransferred: bytesTransferred,
    );

    _activeTransfers[id] = updated;
    _transferUpdateController.add(updated);
  }

  void cancelTransfer(String id) {
    _updateTransfer(id, FileTransferStatus.cancelled, _activeTransfers[id]?.bytesTransferred ?? 0);
    _activeTransfers.remove(id);
  }

  List<FileTransferModel> getActiveTransfers() {
    return _activeTransfers.values.toList();
  }

  void clearCompletedTransfers() {
    _activeTransfers.removeWhere((key, value) =>
      value.status == FileTransferStatus.completed ||
      value.status == FileTransferStatus.failed ||
      value.status == FileTransferStatus.cancelled
    );
  }

  void dispose() {
    _activeTransfers.clear();
    _transferUpdateController.close();
  }
}

