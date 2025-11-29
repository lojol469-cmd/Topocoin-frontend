import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../providers/auth_provider.dart';

class ReceiveScreen extends StatelessWidget {
  const ReceiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final publicKey = authProvider.publicKey ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('RECEIVE TOPOCOIN'),
        backgroundColor: const Color(0xFF00D4FF),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0A0A0A), Color(0xFF1A1A1A)],
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Scan QR Code to Receive',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            const SizedBox(height: 20),
            QrImageView(
              data: publicKey,
              size: 200.0,
              eyeStyle: const QrEyeStyle(color: Color(0xFF00D4FF)),
              dataModuleStyle: const QrDataModuleStyle(color: Color(0xFF00D4FF)),
              backgroundColor: Colors.white,
            ),
            const SizedBox(height: 20),
            Text(
              'Your Public Key:',
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 10),
            SelectableText(
              publicKey,
              style: const TextStyle(color: Color(0xFF00D4FF), fontSize: 14),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Copy to clipboard
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Address copied to clipboard')),
                );
              },
              child: const Text('COPY ADDRESS'),
            ),
          ],
        ),
      ),
    );
  }
}