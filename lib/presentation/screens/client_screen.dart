import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/remote_desktop_provider.dart';
import '../../core/theme/app_theme.dart';
import 'control_screen.dart';

class ClientScreen extends StatefulWidget {
  const ClientScreen({super.key});

  @override
  State<ClientScreen> createState() => _ClientScreenState();
}

class _ClientScreenState extends State<ClientScreen> {
  final TextEditingController _sessionIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isConnecting = false;

  @override
  void dispose() {
    _sessionIdController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _connect() async {
    if (_sessionIdController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a session ID')),
      );
      return;
    }

    setState(() => _isConnecting = true);

    final provider = context.read<RemoteDesktopProvider>();

    await provider.connectToSession(
      _sessionIdController.text,
      password: _passwordController.text.isNotEmpty ? _passwordController.text : null,
    );

    if (!mounted) return;

    setState(() => _isConnecting = false);

    if (provider.errorMessage != null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.errorMessage!)),
      );
    } else if (provider.isConnected) {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ControlScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connect to Device'),
      ),
      body: SingleChildScrollView(
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
                      Icons.link,
                      size: 48,
                      color: AppTheme.primaryBlue,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Connect to Remote Device',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Enter the session ID provided by the host device',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Session ID Input
            TextField(
              controller: _sessionIdController,
              decoration: InputDecoration(
                labelText: 'Session ID',
                hintText: '123 456 789',
                prefixIcon: const Icon(Icons.tag),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.qr_code_scanner),
                  onPressed: () {
                    // TODO: Implement QR code scanner
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('QR Scanner coming soon')),
                    );
                  },
                ),
              ),
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                letterSpacing: 4,
                color: AppTheme.primaryBlue,
              ),
              onChanged: (value) {
                // Auto-format session ID
                if (value.length <= 11) {
                  final cleaned = value.replaceAll(' ', '');
                  if (cleaned.length >= 3) {
                    String formatted = cleaned.substring(0, 3);
                    if (cleaned.length >= 6) {
                      formatted += ' ${cleaned.substring(3, 6)}';
                      if (cleaned.length >= 9) {
                        formatted += ' ${cleaned.substring(6, 9)}';
                      } else if (cleaned.length > 6) {
                        formatted += ' ${cleaned.substring(6)}';
                      }
                    } else if (cleaned.length > 3) {
                      formatted += ' ${cleaned.substring(3)}';
                    }
                    if (formatted != value) {
                      _sessionIdController.value = TextEditingValue(
                        text: formatted,
                        selection: TextSelection.collapsed(offset: formatted.length),
                      );
                    }
                  }
                }
              },
            ),
            const SizedBox(height: 16),

            // Password Input
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Password (Optional)',
                hintText: 'Enter password if required',
                prefixIcon: Icon(Icons.lock_outline),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 32),

            // Connect Button
            ElevatedButton(
              onPressed: _isConnecting ? null : _connect,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isConnecting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Connect',
                      style: TextStyle(fontSize: 18),
                    ),
            ),
            const SizedBox(height: 24),

            // Recent Sessions
            Consumer<RemoteDesktopProvider>(
              builder: (context, provider, child) {
                return FutureBuilder(
                  future: Future.value(context.read<RemoteDesktopProvider>()),
                  builder: (context, snapshot) {
                    return _buildRecentSessions();
                  },
                );
              },
            ),

            const SizedBox(height: 24),

            // Help Section
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
                      Icon(Icons.help_outline, size: 20, color: AppTheme.primaryBlue),
                      const SizedBox(width: 8),
                      Text(
                        'How to Connect',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppTheme.primaryBlue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildHelpStep('1', 'Get the 9-digit session ID from the host'),
                  _buildHelpStep('2', 'Enter the session ID above'),
                  _buildHelpStep('3', 'Enter password if required'),
                  _buildHelpStep('4', 'Tap Connect to start the session'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentSessions() {
    // TODO: Load from storage service
    return const SizedBox.shrink();
  }

  Widget _buildHelpStep(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
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
}

