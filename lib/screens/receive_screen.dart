import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/services.dart';
import '../providers/auth_provider.dart';
import '../providers/wallet_provider.dart';

class ReceiveScreen extends StatelessWidget {
  const ReceiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final walletProvider = Provider.of<WalletProvider>(context);
    final publicKey = authProvider.publicKey ?? '';
    final ataAddress = walletProvider.ataAddress ?? publicKey; // Use ATA if available, else publicKey

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
              'Scan QR Code to Receive Topocoin',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            const SizedBox(height: 20),
            QrImageView(
              data: ataAddress,
              size: 200.0,
              eyeStyle: const QrEyeStyle(color: Color(0xFF00D4FF)),
              dataModuleStyle: const QrDataModuleStyle(color: Color(0xFF00D4FF)),
              backgroundColor: Colors.white,
            ),
            const SizedBox(height: 20),
            Text(
              ataAddress == publicKey ? 'Your Public Key (ATA will be created on receive):' : 'Your Token Account Address:',
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 10),
            SelectableText(
              ataAddress,
              style: const TextStyle(color: Color(0xFF00D4FF), fontSize: 14),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: ataAddress));
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