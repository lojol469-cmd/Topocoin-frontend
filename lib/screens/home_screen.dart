import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/wallet_provider.dart';
import '../providers/language_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _loadWalletData();
  }

  Future<void> _loadWalletData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.publicKey != null) {
      await Provider.of<WalletProvider>(context, listen: false).loadBalance(authProvider.publicKey!);
      await Provider.of<WalletProvider>(context, listen: false).loadTransactions(authProvider.publicKey!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final walletProvider = Provider.of<WalletProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0A0A0A), Color(0xFF1A1A1A)],
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        languageProvider.getText('welcome_back'),
                        style: TextStyle(
                          color: Colors.white.withAlpha((0.7 * 255).round()),
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        authProvider.email ?? 'User',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: const Color(0xFF00D4FF),
                    child: Text(
                      (authProvider.email ?? 'U')[0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: const Color(0xFF00D4FF), width: 1),
                ),
                child: Column(
                  children: [
                    Text(
                      languageProvider.getText('wallet_balance'),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 10),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        '${walletProvider.balance.toStringAsFixed(4)} TPC',
                        style: const TextStyle(
                          color: Color(0xFF00D4FF),
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.pushNamed(context, '/send'),
                      icon: const Icon(Icons.send),
                      label: Text(languageProvider.getText('send')),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00D4FF),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.pushNamed(context, '/receive'),
                      icon: const Icon(Icons.call_received),
                      label: Text(languageProvider.getText('receive')),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A1A1A),
                        foregroundColor: const Color(0xFF00D4FF),
                        side: const BorderSide(color: Color(0xFF00D4FF)),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              Text(
                languageProvider.getText('recent_transactions'),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),
              SizedBox(
                height: 300,
                child: walletProvider.transactions.isEmpty
                    ? Center(
                        child: Text(
                          languageProvider.getText('no_transactions'),
                          style: TextStyle(color: Colors.white70),
                        ),
                      )
                    : ListView.builder(
                        itemCount: walletProvider.transactions.length,
                        itemBuilder: (context, index) {
                          final transaction = walletProvider.transactions[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1A1A1A),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      transaction['type'] == 'receive'
                                          ? Icons.arrow_downward
                                          : Icons.arrow_upward,
                                      color: transaction['type'] == 'receive'
                                          ? Colors.green
                                          : Colors.red,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      transaction['type'] == 'receive' ? languageProvider.getText('received') : languageProvider.getText('sent'),
                                      style: const TextStyle(color: Colors.white),
                                    ),
                                  ],
                                ),
                                Text(
                                  '${transaction['amount']} TPC',
                                  style: TextStyle(
                                    color: transaction['type'] == 'receive'
                                        ? Colors.green
                                        : Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}