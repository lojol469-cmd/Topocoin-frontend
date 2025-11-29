import 'package:flutter/foundation.dart';
import 'package:solana/solana.dart';

class WalletProvider with ChangeNotifier {
  final String baseUrl = 'https://topocoin-backend.onrender.com';
  final SolanaClient _client = SolanaClient(
    rpcUrl: Uri.parse('https://api.mainnet-beta.solana.com'),
    websocketUrl: Uri.parse('wss://api.mainnet-beta.solana.com'),
  );

  double _balance = 0.0;
  List<Map<String, dynamic>> _transactions = [];

  double get balance => _balance;
  List<Map<String, dynamic>> get transactions => _transactions;

  Future<void> loadBalance(String publicKey) async {
    try {
      final balance = await _client.rpcClient.getBalance(publicKey);
      _balance = balance.value / 1000000000.0; // LAMPORTS_PER_SOL
      notifyListeners();
    } catch (e) {
      // print('Error loading balance: $e');
    }
  }

  Future<void> loadTransactions(String publicKey) async {
    // For now, mock transactions. In real app, fetch from Solana or backend
    _transactions = [
      {'type': 'receive', 'amount': 10.0, 'date': '2023-10-01'},
      {'type': 'send', 'amount': 5.0, 'date': '2023-10-02'},
    ];
    notifyListeners();
  }

  Future<void> sendTransaction(String from, String to, double amount) async {
    // Implement sending transaction using Solana
    // This requires private key, which should be handled securely
    // For demo, just update balance
    _balance -= amount;
    _transactions.insert(0, {'type': 'send', 'amount': amount, 'date': DateTime.now().toString()});
    notifyListeners();
  }
}