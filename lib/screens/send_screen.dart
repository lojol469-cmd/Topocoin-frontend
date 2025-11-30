import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/wallet_provider.dart';
import '../providers/auth_provider.dart';

class SendScreen extends StatefulWidget {
  const SendScreen({super.key});

  @override
  State<SendScreen> createState() => _SendScreenState();
}

class _SendScreenState extends State<SendScreen> {
  final _toController = TextEditingController();
  final _amountController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SEND TOPOCOIN'),
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
          children: [
            TextField(
              controller: _toController,
              decoration: const InputDecoration(
                labelText: 'Recipient Address',
                prefixIcon: Icon(Icons.account_circle, color: Color(0xFF00D4FF)),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Amount (TPC)',
                prefixIcon: Icon(Icons.attach_money, color: Color(0xFF00D4FF)),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 30),
            _isLoading
                ? const CircularProgressIndicator(color: Color(0xFF00D4FF))
                : ElevatedButton(
                    onPressed: _send,
                    child: const Text('SEND'),
                  ),
          ],
        ),
      ),
    );
  }

  Future<void> _send() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final from = authProvider.publicKey ?? '';
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid amount')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await Provider.of<WalletProvider>(context, listen: false).sendTransaction(
        from,
        _toController.text,
        amount,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transaction sent!')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Send failed: $e')),
      );
    }
    setState(() => _isLoading = false);
  }
}