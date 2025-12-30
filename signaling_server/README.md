# DeskPro Signaling Server

This is a Node.js signaling server for DeskPro remote desktop application. It facilitates WebRTC peer connection establishment between host and client devices.

## Prerequisites

- Node.js (v14 or higher)
- npm or yarn

## Installation

```bash
npm install
```

## Running the Server

```bash
npm start
```

The server will run on port 3000 by default. You can change this in the server.js file.

## Environment Variables

Create a `.env` file in the server directory:

```
PORT=3000
NODE_ENV=production
```

## Deploy to Cloud

### Deploy to Heroku

1. Install Heroku CLI
2. Login: `heroku login`
3. Create app: `heroku create deskpro-signaling`
4. Deploy: `git push heroku main`

### Deploy to Railway

1. Go to https://railway.app
2. Create new project
3. Connect your GitHub repository
4. Railway will automatically deploy

### Deploy to Render

1. Go to https://render.com
2. Create new Web Service
3. Connect your GitHub repository
4. Set build command: `npm install`
5. Set start command: `npm start`

## Update Flutter App

After deploying, update the signaling server URL in:
`lib/core/constants/app_constants.dart`

Change:
```dart
static const String signalingServerUrl = 'https://your-deployed-server.com';
```

## Security Notes

- Use HTTPS in production
- Implement rate limiting for production
- Add authentication if needed
- Use environment variables for sensitive data

