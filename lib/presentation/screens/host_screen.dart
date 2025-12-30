import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../providers/remote_desktop_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/utils.dart';

class HostScreen extends StatefulWidget {
  const HostScreen({super.key});

  @override
  State<HostScreen> createState() => _HostScreenState();
}

class _HostScreenState extends State<HostScreen> {
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordProtected = false;
  bool _isStarted = false;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _startSession() async {
    final provider = context.read<RemoteDesktopProvider>();

    String? password;
    if (_isPasswordProtected && _passwordController.text.isNotEmpty) {
      password = _passwordController.text;
    }

    await provider.startHostSession(password: password);

    if (!mounted) return;
    setState(() => _isStarted = true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Share Your Screen'),
        actions: [
          if (_isStarted)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () async {
                await context.read<RemoteDesktopProvider>().disconnect();
                if (mounted) {
                  Navigator.pop(context);
                }
              },
            ),
        ],
      ),
      body: Consumer<RemoteDesktopProvider>(
        builder: (context, provider, child) {
          if (!_isStarted) {
            return _buildSetupView();
          }

          if (provider.currentSession == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return _buildActiveSessionView(provider);
        },
      ),
    );
  }

  Widget _buildSetupView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),

          // Info Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 48,
                    color: AppTheme.primaryBlue,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Allow remote access',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'You will receive a session ID that others can use to connect to your screen',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Password Protection
          SwitchListTile(
            value: _isPasswordProtected,
            onChanged: (value) {
              setState(() => _isPasswordProtected = value);
            },
            title: const Text('Password Protection'),
            subtitle: const Text('Require password to connect'),
            activeTrackColor: AppTheme.primaryBlue.withValues(alpha: 0.5),
            activeThumbColor: AppTheme.primaryBlue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            tileColor: AppTheme.surfaceColor,
          ),

          if (_isPasswordProtected) ...[
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Set Password',
                hintText: 'Enter a secure password',
                prefixIcon: Icon(Icons.lock_outline),
              ),
              obscureText: true,
            ),
          ],

          const SizedBox(height: 32),

          // Start Button
          ElevatedButton(
            onPressed: _startSession,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Start Sharing',
              style: TextStyle(fontSize: 18),
            ),
          ),

          const SizedBox(height: 16),

          // Info Notes
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primaryBlueLight.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.primaryBlueLight),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.security, size: 20, color: AppTheme.primaryBlue),
                    const SizedBox(width: 8),
                    Text(
                      'Security Tips',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppTheme.primaryBlue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildTipItem('Only share your session ID with trusted people'),
                _buildTipItem('Use password protection for added security'),
                _buildTipItem('You can end the session at any time'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle,
            size: 16,
            color: AppTheme.successColor,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveSessionView(RemoteDesktopProvider provider) {
    final sessionId = provider.currentSession!.sessionId;
    final formattedId = Utils.formatSessionId(sessionId);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Status Card
          Card(
            color: AppTheme.successColor.withValues(alpha: 0.1),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Icon(
                    Icons.check_circle,
                    size: 64,
                    color: AppTheme.successColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Screen Sharing Active',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppTheme.successColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Share your session ID to allow others to connect',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Session ID Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Text(
                    'Session ID',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    formattedId,
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      color: AppTheme.primaryBlue,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 4,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Copy Button
                  ElevatedButton.icon(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: sessionId));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Session ID copied to clipboard'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    icon: const Icon(Icons.copy),
                    label: const Text('Copy Session ID'),
                  ),

                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),

                  // QR Code
                  Text(
                    'Or scan QR Code',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  QrImageView(
                    data: sessionId,
                    version: QrVersions.auto,
                    size: 200,
                    backgroundColor: Colors.white,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Connection Stats
          StreamBuilder(
            stream: provider.connectionStats,
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const SizedBox.shrink();

              final stats = snapshot.data;
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Connection Statistics',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      _buildStatRow('Resolution', stats.resolution),
                      _buildStatRow('Frame Rate', '${stats.frameRate} fps'),
                      _buildStatRow('Bitrate', Utils.formatBitrate(stats.bitrate)),
                      _buildStatRow('Duration', Utils.formatDuration(stats.connectionDuration)),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),

          // Control Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await provider.toggleAudio();
                  },
                  icon: Icon(provider.isAudioEnabled ? Icons.mic : Icons.mic_off),
                  label: Text(provider.isAudioEnabled ? 'Mute' : 'Unmute'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final navigator = Navigator.of(context);
                    await provider.disconnect();
                    navigator.pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.errorColor,
                  ),
                  icon: const Icon(Icons.stop),
                  label: const Text('Stop Sharing'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryBlue,
            ),
          ),
        ],
      ),
    );
  }
}

