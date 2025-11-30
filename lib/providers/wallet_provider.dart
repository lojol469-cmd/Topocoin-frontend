import 'package:flutter/foundation.dart';
import 'package:solana/solana.dart';
import 'package:solana/dto.dart' as dto;
import 'package:http/http.dart' as http;
import 'dart:convert';

class WalletProvider with ChangeNotifier {
  final String baseUrl = 'https://topocoin-backend.onrender.com';
  final SolanaClient _client = SolanaClient(
    rpcUrl: Uri.parse('https://api.devnet.solana.com'),
    websocketUrl: Uri.parse('wss://api.devnet.solana.com'),
  );

  // Adresse du mint Topocoin
  final String topocoinMint = '6zhMkoDvNg7cw8ojTH6BBdkYkDwery4GTRxZKVAPv2EW';

  double _balance = 0.0;
  List<Map<String, dynamic>> _transactions = [];
  String? _ataAddress;

  double get balance => _balance;
  List<Map<String, dynamic>> get transactions => _transactions;
  String? get ataAddress => _ataAddress;

  Future<void> loadBalance(String publicKey) async {
    try {
      // Charger le solde Topocoin
      final tokenAccounts = await _client.rpcClient.getTokenAccountsByOwner(
        publicKey,
        dto.TokenAccountsFilter.byMint(topocoinMint),
        encoding: dto.Encoding.jsonParsed,
      );

      double tpcBalance = 0.0;
      if (tokenAccounts.value.isNotEmpty) {
        final account = tokenAccounts.value.first;
        _ataAddress = account.pubkey;
        final parsed = account.account.data as dto.ParsedAccountData;
        final parsedData = parsed.parsed as Map<String, dynamic>;
        final info = parsedData['info'] as Map<String, dynamic>;
        final tokenAmount = info['tokenAmount'] as Map<String, dynamic>;
        tpcBalance = double.parse(tokenAmount['uiAmountString'] ?? '0');
      } else {
        _ataAddress = null;
      }

      _balance = tpcBalance;

      notifyListeners();
    } catch (e) {
      // En cas d'erreur, garder le solde à 0
      _balance = 0.0;
      notifyListeners();
    }
  }

  Future<void> loadTransactions(String publicKey) async {
    // Pour l'instant, transactions mockées. Remplacer par vraies transactions token plus tard.
    _transactions = [
      {'type': 'receive', 'amount': 100.0, 'date': '2025-11-29'},
      {'type': 'send', 'amount': 50.0, 'date': '2025-11-28'},
    ];
    notifyListeners();
  }

  Future<void> sendTransaction(String from, String to, double amount) async {
    // Implémentation réelle via le backend
    final response = await http.post(
      Uri.parse('$baseUrl/send'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'from': from,
        'to': to,
        'amount': amount,
        'token': topocoinMint,
      }),
    );

    if (response.statusCode == 200) {
      // Recharger le solde après envoi
      await loadBalance(from);
      _transactions.insert(0, {'type': 'send', 'amount': amount, 'date': DateTime.now().toString()});
      notifyListeners();
    } else {
      throw Exception('Send failed');
    }
  }
}