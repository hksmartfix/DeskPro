import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:provider/provider.dart';
import '../providers/remote_desktop_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/utils.dart';

class ControlScreen extends StatefulWidget {
  const ControlScreen({super.key});

  @override
  State<ControlScreen> createState() => _ControlScreenState();
}

class _ControlScreenState extends State<ControlScreen> {
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  bool _isFullScreen = false;
  bool _showControls = true;
  final GlobalKey _videoKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _initRenderer();
  }

  Future<void> _initRenderer() async {
    await _remoteRenderer.initialize();

    if (!mounted) return;

    final provider = context.read<RemoteDesktopProvider>();
    provider.remoteStream.listen((stream) {
      if (stream != null && mounted) {
        setState(() {
          _remoteRenderer.srcObject = stream;
        });
      }
    });
  }

  @override
  void dispose() {
    _remoteRenderer.dispose();
    super.dispose();
  }

  void _handlePointerDown(PointerDownEvent event) {
    final provider = context.read<RemoteDesktopProvider>();
    final box = _videoKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;

    final localPosition = box.globalToLocal(event.position);
    final normalizedX = localPosition.dx / box.size.width;
    final normalizedY = localPosition.dy / box.size.height;

    provider.sendMouseEvent('down', normalizedX, normalizedY, button: event.buttons);
  }

  void _handlePointerMove(PointerMoveEvent event) {
    final provider = context.read<RemoteDesktopProvider>();
    final box = _videoKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;

    final localPosition = box.globalToLocal(event.position);
    final normalizedX = localPosition.dx / box.size.width;
    final normalizedY = localPosition.dy / box.size.height;

    provider.sendMouseEvent('move', normalizedX, normalizedY);
  }

  void _handlePointerUp(PointerUpEvent event) {
    final provider = context.read<RemoteDesktopProvider>();
    final box = _videoKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;

    final localPosition = box.globalToLocal(event.position);
    final normalizedX = localPosition.dx / box.size.width;
    final normalizedY = localPosition.dy / box.size.height;

    provider.sendMouseEvent('up', normalizedX, normalizedY);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Consumer<RemoteDesktopProvider>(
        builder: (context, provider, child) {
          return Stack(
            children: [
              // Remote Screen Display
              Center(
                child: GestureDetector(
                  onTap: () {
                    setState(() => _showControls = !_showControls);
                  },
                  child: Listener(
                    onPointerDown: _handlePointerDown,
                    onPointerMove: _handlePointerMove,
                    onPointerUp: _handlePointerUp,
                    child: Container(
                      key: _videoKey,
                      child: RTCVideoView(
                        _remoteRenderer,
                        objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitContain,
                        mirror: false,
                      ),
                    ),
                  ),
                ),
              ),

              // Top Controls
              if (_showControls)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.7),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    padding: EdgeInsets.only(
                      top: MediaQuery.of(context).padding.top + 8,
                      left: 16,
                      right: 16,
                      bottom: 16,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Session Info
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.successColor,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(
                                    Icons.circle,
                                    size: 8,
                                    color: Colors.white,
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    'Connected',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            StreamBuilder(
                              stream: provider.connectionStats,
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return const SizedBox.shrink();
                                }
                                final stats = snapshot.data;
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.5),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    '${stats.frameRate} FPS • ${Utils.formatBitrate(stats.bitrate)}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),

                        // Close Button
                        IconButton(
                          onPressed: () async {
                            final navigator = Navigator.of(context);

                            final confirmed = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Disconnect'),
                                content: const Text('Are you sure you want to disconnect?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, false),
                                    child: const Text('Cancel'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () => Navigator.pop(context, true),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.errorColor,
                                    ),
                                    child: const Text('Disconnect'),
                                  ),
                                ],
                              ),
                            );

                            if (confirmed == true) {
                              await provider.disconnect();
                              navigator.popUntil((route) => route.isFirst);
                            }
                          },
                          icon: const Icon(Icons.close, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),

              // Bottom Controls
              if (_showControls)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.7),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).padding.bottom + 16,
                      left: 16,
                      right: 16,
                      top: 16,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildControlButton(
                          icon: Icons.fullscreen,
                          label: 'Fullscreen',
                          onTap: () {
                            setState(() => _isFullScreen = !_isFullScreen);
                            // TODO: Implement fullscreen toggle
                          },
                        ),
                        _buildControlButton(
                          icon: Icons.keyboard,
                          label: 'Keyboard',
                          onTap: () {
                            _showVirtualKeyboard();
                          },
                        ),
                        _buildControlButton(
                          icon: Icons.file_upload,
                          label: 'Send File',
                          onTap: () async {
                            await provider.sendFile();
                          },
                        ),
                        _buildControlButton(
                          icon: Icons.settings,
                          label: 'Settings',
                          onTap: () {
                            _showSettingsSheet();
                          },
                        ),
                      ],
                    ),
                  ),
                ),

              // Loading Indicator
              if (!provider.isConnected)
                Container(
                  color: Colors.black,
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryBlue),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Connecting...',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showVirtualKeyboard() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Virtual Keyboard',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              TextField(
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Type here to send keyboard input',
                  border: OutlineInputBorder(),
                ),
                onChanged: (text) {
                  if (text.isNotEmpty) {
                    final provider = context.read<RemoteDesktopProvider>();
                    provider.sendKeyboardEvent(text[text.length - 1], true);
                  }
                },
              ),
              const SizedBox(height: 16),
              const Text(
                'Special keys coming soon',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSettingsSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Consumer<RemoteDesktopProvider>(
          builder: (context, provider, child) {
            return Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Session Settings',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 24),

                  // Audio Toggle
                  SwitchListTile(
                    value: provider.isAudioEnabled,
                    onChanged: (value) => provider.toggleAudio(),
                    title: const Text('Audio'),
                    subtitle: const Text('Enable/disable audio transmission'),
                    activeTrackColor: AppTheme.primaryBlue.withValues(alpha: 0.5),
                    activeThumbColor: AppTheme.primaryBlue,
                  ),

                  const Divider(),

                  // Stats Display
                  StreamBuilder(
                    stream: provider.connectionStats,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const SizedBox.shrink();

                      final stats = snapshot.data;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Connection Statistics',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 12),
                          _buildStatItem('Resolution', stats.resolution),
                          _buildStatItem('Frame Rate', '${stats.frameRate} fps'),
                          _buildStatItem('Bitrate', Utils.formatBitrate(stats.bitrate)),
                          _buildStatItem('Latency', '${stats.latency} ms'),
                          _buildStatItem('Packet Loss', '${stats.packetLossRate.toStringAsFixed(2)}%'),
                        ],
                      );
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryBlue,
            ),
          ),
        ],
      ),
    );
  }
}

