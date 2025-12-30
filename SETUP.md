# 🚀 Quick Setup Guide

## Prerequisites Checklist
- [ ] Flutter SDK installed (3.0+)
- [ ] Android Studio or VS Code
- [ ] Node.js installed (for signaling server)
- [ ] Git installed

## Step-by-Step Setup

### 1. Setup Signaling Server (Required)

The app needs a signaling server to establish connections between devices.

**Option A: Run Locally (Testing)**
```bash
cd signaling_server
npm install
npm start
```
Server will run on `http://localhost:3000`

**Option B: Deploy to Cloud (Production)**

#### Heroku:
```bash
cd signaling_server
heroku login
heroku create your-app-name
git init
git add .
git commit -m "Initial commit"
git push heroku main
```

#### Railway.app (Recommended - Free):
1. Go to https://railway.app
2. Click "New Project" → "Deploy from GitHub repo"
3. Select your repository
4. Railway will auto-detect and deploy

#### Render.com:
1. Go to https://render.com
2. New Web Service → Connect GitHub
3. Build: `cd signaling_server && npm install`
4. Start: `npm start`

### 2. Configure App

Edit `lib/core/constants/app_constants.dart`:

```dart
static const String signalingServerUrl = 'YOUR_SERVER_URL_HERE';
// Examples:
// Local: 'http://localhost:3000'
// Railway: 'https://your-app.railway.app'
// Heroku: 'https://your-app.herokuapp.com'
// Render: 'https://your-app.onrender.com'
```

### 3. Install Dependencies

```bash
flutter pub get
```

### 4. Run the App

#### Android:
```bash
flutter run
```

#### Windows:
```bash
flutter run -d windows
```

## Testing the App

### Test Scenario 1: Same Network
1. Device A: Open app → "Share Screen" → Get Session ID
2. Device B: Open app → "Connect" → Enter Session ID
3. You should see Device A's screen on Device B

### Test Scenario 2: Different Networks
1. Ensure signaling server is publicly accessible (deployed to cloud)
2. Follow same steps as above
3. Connection will use STUN servers for NAT traversal

## Troubleshooting

### "Connection Failed"
- ✅ Check signaling server is running
- ✅ Verify URL in app_constants.dart
- ✅ Check firewall settings
- ✅ Ensure both devices have internet

### "Permission Denied" (Android)
- ✅ Grant screen capture permission
- ✅ Grant storage permission
- ✅ Grant camera/microphone permission

### "Black Screen"
- ✅ Ensure host is actively sharing
- ✅ Check network connection quality
- ✅ Try reducing video quality in settings

### Build Errors
```bash
flutter clean
flutter pub get
flutter run
```

## Configuration Options

### Adjust Video Quality
In `lib/core/constants/app_constants.dart`:

```dart
// Lower quality for slower networks
static const int defaultBitrate = 1000000; // 1Mbps instead of 2Mbps
static const int defaultFrameRate = 24; // 24fps instead of 30fps

// Change default resolution
'medium': {'width': 1280, 'height': 720}, // 720p instead of 1080p
```

### Session Timeout
```dart
static const int sessionTimeout = 12 * 60 * 60 * 1000; // 12 hours instead of 24
```

## Features Overview

### ✅ Currently Working
- Session ID generation and connection
- Password protection
- High-quality video streaming
- Real-time statistics
- File sharing
- Modern UI with light blue theme

### 🚧 Requires Additional Setup
- Mouse/Keyboard control (requires accessibility service on Android)
- Background service (requires foreground service)

### 📅 Planned Features
- iOS support
- Recording sessions
- Chat functionality
- Multi-monitor support

## Security Best Practices

1. **Always use HTTPS** for signaling server in production
2. **Enable password protection** for sensitive sessions
3. **Don't share Session IDs publicly**
4. **End sessions** when finished
5. **Use strong passwords** (6+ characters)

## Performance Tips

### For Better Quality:
- Use WiFi instead of mobile data
- Close other bandwidth-heavy apps
- Increase bitrate in settings
- Use higher resolution preset

### For Lower Latency:
- Reduce frame rate to 24fps
- Lower bitrate to 1Mbps
- Use 720p resolution
- Ensure stable network connection

## Need Help?

- 📖 Read the full README.md
- 🐛 Check for known issues
- 💬 Open an issue on GitHub
- 📧 Contact support

## Quick Commands Reference

```bash
# Install dependencies
flutter pub get

# Run on Android
flutter run

# Run on Windows
flutter run -d windows

# Build APK
flutter build apk --release

# Build Windows executable
flutter build windows --release

# Clean build
flutter clean

# Check for outdated packages
flutter pub outdated

# Upgrade packages
flutter pub upgrade
```

## Directory Structure Quick Reference

```
lib/
├── core/           # Constants, theme, utilities
├── data/           # Models, services
└── presentation/   # UI screens, widgets, providers

signaling_server/   # Node.js WebRTC signaling server
├── server.js       # Main server file
└── package.json    # Dependencies
```

---

🎉 **You're all set!** Start by running the signaling server, then launch the app on your devices.

