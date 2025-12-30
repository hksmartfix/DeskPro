# 🖥️ DeskPro - Remote Desktop Application

![DeskPro](https://img.shields.io/badge/Platform-Android%20%7C%20Windows-blue)
![Flutter](https://img.shields.io/badge/Flutter-3.0%2B-02569B?logo=flutter)
![License](https://img.shields.io/badge/License-MIT-green)

DeskPro is a powerful, cross-platform remote desktop application built with Flutter that allows you to remotely access and control devices over the internet. Similar to AnyDesk, it provides high-quality screen streaming, full mouse and keyboard control, file sharing, and more!

## ✨ Features

### Core Functionality
- 🔐 **Session ID Connection** - Easy 9-digit session ID for quick connections
- 🔒 **Password Protection** - Optional password authentication with local storage
- 📺 **High-Resolution Streaming** - Support for up to 4K resolution
- 🖱️ **Full Input Control** - Complete mouse and keyboard control
- 📁 **File Sharing** - Transfer files between devices
- ⚡ **Low Latency** - Optimized WebRTC streaming for minimal delay
- 📊 **Real-time Statistics** - Monitor connection quality, FPS, bitrate
- 🎨 **Modern UI** - Beautiful light blue theme, responsive design

### Technical Features
- WebRTC for peer-to-peer video streaming
- Adaptive bitrate (250kbps - 5Mbps)
- Configurable frame rate (15-60 FPS)
- Hardware-accelerated encoding
- Session history tracking
- QR code sharing for easy connection
- Connection statistics and monitoring

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.0+)
- Android Studio / VS Code
- For Android: Android SDK 21+
- For Windows: Windows 10+
- Node.js (for signaling server)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/deskpro.git
   cd deskpro
   ```

2. **Install Flutter dependencies**
   ```bash
   flutter pub get
   ```

3. **Set up the Signaling Server**
   ```bash
   cd signaling_server
   npm install
   npm start
   ```

4. **Update Server URL**
   
   Edit `lib/core/constants/app_constants.dart`:
   ```dart
   static const String signalingServerUrl = 'https://your-server-url.com';
   ```

5. **Run the app**
   ```bash
   # For Android
   flutter run

   # For Windows
   flutter run -d windows
   ```

## 📱 How to Use

### As Host (Share Your Screen)

1. Open DeskPro and tap **"Share Screen"**
2. Set an optional password for security
3. Tap **"Start Sharing"**
4. Share your Session ID or QR code with the person you want to connect with
5. They can now see and control your screen

### As Client (Connect to Remote Device)

1. Open DeskPro and tap **"Connect"**
2. Enter the 9-digit Session ID provided by the host
3. Enter the password if required
4. Tap **"Connect"**
5. You can now view and control the remote screen

## 🏗️ Project Structure

```
lib/
├── core/
│   ├── constants/      # App constants and configurations
│   ├── theme/          # Light blue theme definitions
│   └── utils/          # Utility functions
├── data/
│   ├── models/         # Data models (Session, FileTransfer, etc.)
│   └── services/       # Core services
│       ├── signaling_service.dart    # WebRTC signaling
│       ├── webrtc_service.dart       # Video streaming
│       ├── file_transfer_service.dart # File sharing
│       ├── storage_service.dart      # Local storage
│       └── platform_service.dart     # Native platform integration
└── presentation/
    ├── providers/      # State management
    ├── screens/        # UI screens
    │   ├── home_screen.dart
    │   ├── host_screen.dart
    │   ├── client_screen.dart
    │   └── control_screen.dart
    └── widgets/        # Reusable widgets

signaling_server/
├── server.js          # Node.js signaling server
├── package.json       # Server dependencies
└── README.md          # Server setup guide
```

## 🔧 Configuration

### Video Quality Settings

Edit `lib/core/constants/app_constants.dart` to adjust quality:

```dart
// Video Resolution Presets
static const Map<String, Map<String, int>> videoResolutions = {
  'low': {'width': 1280, 'height': 720},      // 720p
  'medium': {'width': 1920, 'height': 1080},  // 1080p (default)
  'high': {'width': 2560, 'height': 1440},    // 1440p
  'ultra': {'width': 3840, 'height': 2160},   // 4K
};

// Bitrate Configuration
static const int minBitrate = 250000;   // 250kbps
static const int maxBitrate = 5000000;  // 5Mbps
static const int defaultBitrate = 2000000; // 2Mbps

// Frame Rate
static const int minFrameRate = 15;
static const int maxFrameRate = 60;
static const int defaultFrameRate = 30;
```

### Permissions

#### Android
Permissions are already configured in `android/app/src/main/AndroidManifest.xml`:
- Internet access
- Camera and microphone
- Storage access
- Screen capture

#### Windows
Windows permissions are handled at runtime through the application.

## 🌐 Deploy Signaling Server

### Option 1: Heroku
```bash
cd signaling_server
heroku login
heroku create deskpro-signaling
git push heroku main
```

### Option 2: Railway
1. Go to https://railway.app
2. Create new project from GitHub repo
3. Railway auto-deploys the signaling server

### Option 3: Render
1. Go to https://render.com
2. Create new Web Service
3. Connect GitHub repo
4. Deploy automatically

## 🔐 Security Features

- End-to-end encrypted data channels
- Password protection with SHA-256 hashing
- Session timeout after 24 hours
- No data stored on signaling server
- Direct peer-to-peer connections

## 🎨 Customization

### Change Theme Colors

Edit `lib/core/theme/app_theme.dart`:

```dart
static const Color primaryBlue = Color(0xFF4FC3F7);
static const Color accentBlue = Color(0xFF29B6F6);
// Customize more colors...
```

### Add More Features

The architecture is modular and easy to extend:
- Add new services in `lib/data/services/`
- Create new screens in `lib/presentation/screens/`
- Add models in `lib/data/models/`

## 📦 Dependencies

### Flutter Packages
- `flutter_webrtc` - WebRTC streaming
- `socket_io_client` - Signaling communication
- `shared_preferences` - Local storage
- `permission_handler` - Runtime permissions
- `file_picker` - File selection
- `provider` - State management
- `qr_flutter` - QR code generation
- `crypto` - Encryption

### Server Dependencies
- `express` - Web server
- `socket.io` - WebSocket signaling
- `cors` - Cross-origin support

## 🐛 Known Issues & Limitations

1. **Android Input Injection**: Requires accessibility service (not implemented yet)
2. **iOS Support**: Not yet implemented (iOS has restrictions on screen capture)
3. **Background Mode**: Screen sharing stops when app is minimized
4. **NAT Traversal**: May require TURN server for some network configurations

## 🛠️ Troubleshooting

### Connection Issues
- Ensure signaling server is running and accessible
- Check firewall settings
- Verify internet connection on both devices

### Screen Capture Not Working
- Grant screen capture permissions on Android
- Ensure app has necessary permissions

### Low Quality Video
- Increase bitrate in settings
- Check network bandwidth
- Reduce resolution if needed

## 📝 TODO / Future Enhancements

- [ ] iOS support
- [ ] Clipboard synchronization
- [ ] Multi-monitor support
- [ ] Recording sessions
- [ ] Chat feature
- [ ] Accessibility service for input injection
- [ ] TURN server integration for better NAT traversal
- [ ] Dark theme
- [ ] Multiple language support

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the project
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 👨‍💻 Author

Your Name - [@yourhandle](https://twitter.com/yourhandle)

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- WebRTC community
- AnyDesk for inspiration

## 📧 Contact

For questions or support, please open an issue or contact [your-email@example.com](mailto:your-email@example.com)

---

⭐ If you find this project helpful, please give it a star!

