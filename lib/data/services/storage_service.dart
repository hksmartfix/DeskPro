import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Password Management
  Future<bool> savePassword(String password) async {
    try {
      return await _prefs!.setString('stored_password', password);
    } catch (e) {
      return false;
    }
  }

  String? getPassword() {
    return _prefs!.getString('stored_password');
  }

  Future<bool> removePassword() async {
    return await _prefs!.remove('stored_password');
  }

  bool hasStoredPassword() {
    return _prefs!.containsKey('stored_password');
  }

  // Session History
  Future<bool> addSessionToHistory(Map<String, dynamic> session) async {
    try {
      final history = getSessionHistory();
      history.insert(0, session);
      // Keep only last 20 sessions
      if (history.length > 20) {
        history.removeRange(20, history.length);
      }
      final jsonString = jsonEncode(history);
      return await _prefs!.setString('session_history', jsonString);
    } catch (e) {
      return false;
    }
  }

  List<Map<String, dynamic>> getSessionHistory() {
    try {
      final jsonString = _prefs!.getString('session_history');
      if (jsonString == null) return [];
      final List<dynamic> decoded = jsonDecode(jsonString);
      return decoded.map((e) => e as Map<String, dynamic>).toList();
    } catch (e) {
      return [];
    }
  }

  Future<bool> clearSessionHistory() async {
    return await _prefs!.remove('session_history');
  }

  // Quality Settings
  Future<bool> setQualityPreset(String preset) async {
    return await _prefs!.setString('quality_preset', preset);
  }

  String getQualityPreset() {
    return _prefs!.getString('quality_preset') ?? 'medium';
  }

  // Auto Connect
  Future<bool> setAutoConnect(bool enabled) async {
    return await _prefs!.setBool('auto_connect', enabled);
  }

  bool getAutoConnect() {
    return _prefs!.getBool('auto_connect') ?? false;
  }

  // Sound Enabled
  Future<bool> setSoundEnabled(bool enabled) async {
    return await _prefs!.setBool('sound_enabled', enabled);
  }

  bool getSoundEnabled() {
    return _prefs!.getBool('sound_enabled') ?? true;
  }

  // Frame Rate
  Future<bool> setFrameRate(int frameRate) async {
    return await _prefs!.setInt('frame_rate', frameRate);
  }

  int getFrameRate() {
    return _prefs!.getInt('frame_rate') ?? 30;
  }

  // Bitrate
  Future<bool> setBitrate(int bitrate) async {
    return await _prefs!.setInt('bitrate', bitrate);
  }

  int getBitrate() {
    return _prefs!.getInt('bitrate') ?? 2000000;
  }

  // Clear All Data
  Future<bool> clearAll() async {
    return await _prefs!.clear();
  }
}

