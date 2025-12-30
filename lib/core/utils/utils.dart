import 'dart:math';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class Utils {
  /// Generate a random session ID
  static String generateSessionId([int length = 9]) {
    const chars = '0123456789';
    final random = Random.secure();
    return String.fromCharCodes(
      Iterable.generate(
        length,
        (_) => chars.codeUnitAt(random.nextInt(chars.length)),
      ),
    );
  }

  /// Format session ID with spaces for better readability (123 456 789)
  static String formatSessionId(String sessionId) {
    if (sessionId.length != 9) return sessionId;
    return '${sessionId.substring(0, 3)} ${sessionId.substring(3, 6)} ${sessionId.substring(6, 9)}';
  }

  /// Remove spaces from formatted session ID
  static String unformatSessionId(String formattedId) {
    return formattedId.replaceAll(' ', '');
  }

  /// Hash password for secure storage
  static String hashPassword(String password) {
    final bytes = utf8.encode(password);
    final hash = sha256.convert(bytes);
    return hash.toString();
  }

  /// Validate session ID format
  static bool isValidSessionId(String sessionId) {
    final cleaned = unformatSessionId(sessionId);
    return RegExp(r'^\d{9}$').hasMatch(cleaned);
  }

  /// Format bytes to human readable size
  static String formatBytes(int bytes, {int decimals = 2}) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB"];
    var i = (log(bytes) / log(1024)).floor();
    return '${(bytes / pow(1024, i)).toStringAsFixed(decimals)} ${suffixes[i]}';
  }

  /// Format duration to human readable string
  static String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    if (duration.inHours > 0) {
      return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
    }
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  /// Get quality preset name from resolution
  static String getQualityPreset(int width, int height) {
    if (width <= 1280) return 'low';
    if (width <= 1920) return 'medium';
    if (width <= 2560) return 'high';
    return 'ultra';
  }

  /// Generate encryption key from session ID
  static String generateEncryptionKey(String sessionId, String password) {
    final combined = '$sessionId:$password';
    final bytes = utf8.encode(combined);
    final hash = sha256.convert(bytes);
    return hash.toString();
  }

  /// Validate password strength
  static bool isStrongPassword(String password) {
    // At least 6 characters
    return password.length >= 6;
  }

  /// Format bitrate to human readable
  static String formatBitrate(int bitsPerSecond) {
    if (bitsPerSecond < 1000000) {
      return '${(bitsPerSecond / 1000).toStringAsFixed(0)} Kbps';
    }
    return '${(bitsPerSecond / 1000000).toStringAsFixed(1)} Mbps';
  }
}

