const express = require('express');
const http = require('http');
const socketIo = require('socket.io');
const cors = require('cors');

const app = express();
app.use(cors());
app.use(express.json());

const server = http.createServer(app);
const io = socketIo(server, {
  cors: {
    origin: "*",
    methods: ["GET", "POST"]
  }
});

const PORT = process.env.PORT || 3000;

// Store active sessions
const sessions = new Map();

// Store socket connections
const connections = new Map();

app.get('/', (req, res) => {
  res.json({
    status: 'DeskPro Signaling Server Running',
    version: '1.0.0',
    activeSessions: sessions.size,
    activeConnections: connections.size
  });
});

app.get('/health', (req, res) => {
  res.json({ status: 'healthy' });
});

io.on('connection', (socket) => {
  console.log('New connection:', socket.id);
  connections.set(socket.id, socket);

  // Create a new session
  socket.on('create-session', (data) => {
    const { sessionId, password } = data;

    if (sessions.has(sessionId)) {
      socket.emit('session-error', { message: 'Session already exists' });
      return;
    }

    sessions.set(sessionId, {
      hostSocketId: socket.id,
      password: password,
      clients: [],
      createdAt: Date.now()
    });

    socket.join(sessionId);
    socket.sessionId = sessionId;
    socket.role = 'host';

    console.log(`Session created: ${sessionId} by ${socket.id}`);
    socket.emit('session-created', { sessionId });
  });

  // Join an existing session
  socket.on('join-session', (data) => {
    const { sessionId, password } = data;

    const session = sessions.get(sessionId);

    if (!session) {
      socket.emit('session-error', { message: 'Session not found' });
      return;
    }

    // Check if this socket is already in the session
    if (session.clients.includes(socket.id)) {
      console.log(`Client ${socket.id} already in session: ${sessionId}`);
      return; // Already joined, ignore duplicate
    }

    // Verify password if required
    if (session.password && session.password !== password) {
      socket.emit('session-error', { message: 'Invalid password' });
      return;
    }

    // Add client to session
    session.clients.push(socket.id);
    socket.join(sessionId);
    socket.sessionId = sessionId;
    socket.role = 'client';

    console.log(`Client ${socket.id} joined session: ${sessionId}`);

    // Notify client of successful join first
    socket.emit('session-joined', { sessionId });

    // Then notify host that a client joined (host should create offer)
    socket.to(session.hostSocketId).emit('peer-joined', {
      peerId: socket.id,
      sessionId: sessionId
    });
  });

  // Forward WebRTC offer
  socket.on('offer', (data) => {
    const { sessionId, offer } = data;
    const session = sessions.get(sessionId);

    if (!session) return;

    if (socket.role === 'host') {
      // Send to all clients
      session.clients.forEach(clientId => {
        io.to(clientId).emit('offer', { offer, from: socket.id });
      });
    } else {
      // Send to host
      io.to(session.hostSocketId).emit('offer', { offer, from: socket.id });
    }
  });

  // Forward WebRTC answer
  socket.on('answer', (data) => {
    const { sessionId, answer } = data;
    const session = sessions.get(sessionId);

    if (!session) return;

    if (socket.role === 'client') {
      // Send to host
      io.to(session.hostSocketId).emit('answer', { answer, from: socket.id });
    } else {
      // Send to all clients
      session.clients.forEach(clientId => {
        io.to(clientId).emit('answer', { answer, from: socket.id });
      });
    }
  });

  // Forward ICE candidates
  socket.on('ice-candidate', (data) => {
    const { sessionId, candidate } = data;
    const session = sessions.get(sessionId);

    if (!session) return;

    if (socket.role === 'host') {
      // Send to all clients
      session.clients.forEach(clientId => {
        io.to(clientId).emit('ice-candidate', { candidate, from: socket.id });
      });
    } else {
      // Send to host
      io.to(session.hostSocketId).emit('ice-candidate', { candidate, from: socket.id });
    }
  });

  // Forward messages
  socket.on('message', (data) => {
    const { sessionId, message } = data;
    socket.to(sessionId).emit('message', { message, from: socket.id });
  });

  // Leave session
  socket.on('leave-session', () => {
    handleDisconnect(socket);
  });

  // Handle disconnect
  socket.on('disconnect', () => {
    console.log('Disconnected:', socket.id);
    handleDisconnect(socket);
    connections.delete(socket.id);
  });
});

function handleDisconnect(socket) {
  const sessionId = socket.sessionId;
  if (!sessionId) return;

  const session = sessions.get(sessionId);
  if (!session) return;

  if (socket.role === 'host') {
    // Host disconnected, notify all clients and close session
    session.clients.forEach(clientId => {
      io.to(clientId).emit('peer-left', { peerId: socket.id, reason: 'Host disconnected' });
    });
    sessions.delete(sessionId);
    console.log(`Session closed: ${sessionId}`);
  } else {
    // Client disconnected, remove from session
    const index = session.clients.indexOf(socket.id);
    if (index > -1) {
      session.clients.splice(index, 1);
    }
    // Notify host
    io.to(session.hostSocketId).emit('peer-left', { peerId: socket.id });
    console.log(`Client ${socket.id} left session: ${sessionId}`);
  }
}

// Clean up old sessions (24 hours)
setInterval(() => {
  const now = Date.now();
  const maxAge = 24 * 60 * 60 * 1000; // 24 hours

  sessions.forEach((session, sessionId) => {
    if (now - session.createdAt > maxAge) {
      console.log(`Cleaning up old session: ${sessionId}`);
      sessions.delete(sessionId);
    }
  });
}, 60 * 60 * 1000); // Run every hour

server.listen(PORT, () => {
  console.log(`DeskPro Signaling Server running on port ${PORT}`);
  console.log(`WebSocket endpoint: ws://localhost:${PORT}`);
});

// Graceful shutdown
process.on('SIGTERM', () => {
  console.log('SIGTERM received, closing server...');
  server.close(() => {
    console.log('Server closed');
    process.exit(0);
  });
});

