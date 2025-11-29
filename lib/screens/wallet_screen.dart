import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/wallet_provider.dart';
import 'send_screen.dart';
import 'receive_screen.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final walletProvider = Provider.of<WalletProvider>(context, listen: false);
    if (authProvider.publicKey != null) {
      walletProvider.loadBalance(authProvider.publicKey!);
      walletProvider.loadTransactions(authProvider.publicKey!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final walletProvider = Provider.of<WalletProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('TOPOCOIN WALLET'),
        backgroundColor: const Color(0xFF00D4FF),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authProvider.logout();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0A0A0A), Color(0xFF1A1A1A)],
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Text(
                    'Balance',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  Text(
                    '${walletProvider.balance.toStringAsFixed(4)} TPC',
                    style: const TextStyle(
                      color: Color(0xFF00D4FF),
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Public Key: ${authProvider.publicKey?.substring(0, 20)}...',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SendScreen()),
                  ),
                  icon: const Icon(Icons.send),
                  label: const Text('SEND'),
                ),
                ElevatedButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ReceiveScreen()),
                  ),
                  icon: const Icon(Icons.call_received),
                  label: const Text('RECEIVE'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Recent Transactions',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: ListView.builder(
                        itemCount: walletProvider.transactions.length,
                        itemBuilder: (context, index) {
                          final tx = walletProvider.transactions[index];
                          return Card(
                            color: const Color(0xFF1A1A1A),
                            child: ListTile(
                              leading: Icon(
                                tx['type'] == 'send' ? Icons.arrow_upward : Icons.arrow_downward,
                                color: tx['type'] == 'send' ? Colors.red : Colors.green,
                              ),
                              title: Text(
                                '${tx['type']} ${tx['amount']} TPC',
                                style: const TextStyle(color: Colors.white),
                              ),
                              subtitle: Text(
                                tx['date'],
                                style: const TextStyle(color: Colors.white70),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}