class AppConstants {
  // Signaling Server Configuration
  //
  // IMPORTANT: Update this based on your setup!
  //
  // Option 1: Local testing on emulator (use this for now):
  //   static const String signalingServerUrl = 'http://10.0.2.2:3000';
  //
  // Option 2: Cloudflare Tunnel (for testing across networks):
  //   1. Run: cloudflared tunnel --url http://localhost:3000
  //   2. Copy the URL it gives you
  //   3. Replace below with: 'https://your-new-tunnel-url.trycloudflare.com'
  //   4. Hot reload the app (press 'r')
  //
  // Option 3: Production (deploy to Railway/Heroku/Render):
  //   static const String signalingServerUrl = 'https://your-app.railway.app';
  //
  static const String signalingServerUrl = 'https://deskpro-production.up.railway.app'; // Using local for now
  static const int signalingPort = 3000;

  // WebRTC Configuration
  static const List<Map<String, String>> iceServers = [
    {'urls': 'stun:stun.l.google.com:19302'},
    {'urls': 'stun:stun1.l.google.com:19302'},
    {'urls': 'stun:stun2.l.google.com:19302'},
  ];

  // Session Configuration
  static const int sessionIdLength = 9;
  static const int sessionTimeout = 24 * 60 * 60 * 1000; // 24 hours in milliseconds

  // Streaming Configuration
  static const int minBitrate = 250000; // 250kbps
  static const int maxBitrate = 5000000; // 5Mbps
  static const int defaultBitrate = 2000000; // 2Mbps
  static const int minFrameRate = 15;
  static const int maxFrameRate = 60;
  static const int defaultFrameRate = 30;

  // Video Resolution Presets
  static const Map<String, Map<String, int>> videoResolutions = {
    'low': {'width': 1280, 'height': 720},
    'medium': {'width': 1920, 'height': 1080},
    'high': {'width': 2560, 'height': 1440},
    'ultra': {'width': 3840, 'height': 2160},
  };

  // File Transfer
  static const int maxFileSize = 500 * 1024 * 1024; // 500MB
  static const int chunkSize = 16384; // 16KB chunks for file transfer

  // Storage Keys
  static const String keyStoredPassword = 'stored_password';
  static const String keyAutoConnect = 'auto_connect';
  static const String keyQualityPreset = 'quality_preset';
  static const String keySessionHistory = 'session_history';
  static const String keySoundEnabled = 'sound_enabled';

  // App Info
  static const String appName = 'DeskPro';
  static const String appVersion = '1.0.0';
}

