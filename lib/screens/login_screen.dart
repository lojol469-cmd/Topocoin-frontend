import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/wallet_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _otpController = TextEditingController();
  bool _isLoading = false;
  bool _showPassword = false;
  bool _useOtp = false;

  @override
  void initState() {
    super.initState();
    Provider.of<AuthProvider>(context, listen: false).checkBiometric();
    Provider.of<AuthProvider>(context, listen: false).tryAutoLogin().then((_) {
      if (Provider.of<AuthProvider>(context, listen: false).isAuthenticated) {
        Navigator.pushReplacementNamed(context, '/wallet');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0A0A0A), Color(0xFF1A1A1A)],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.account_balance_wallet,
                  size: 100,
                  color: Color(0xFF00D4FF),
                ),
                const SizedBox(height: 20),
                Text(
                  'TOPOCOIN WALLET',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: const Color(0xFF00D4FF),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 40),
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email, color: Color(0xFF00D4FF)),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 20),
                if (!_useOtp)
                  TextField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock, color: Color(0xFF00D4FF)),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _showPassword ? Icons.visibility : Icons.visibility_off,
                          color: const Color(0xFF00D4FF),
                        ),
                        onPressed: () => setState(() => _showPassword = !_showPassword),
                      ),
                    ),
                    obscureText: !_showPassword,
                  ),
                if (_useOtp)
                  Column(
                    children: [
                      TextField(
                        controller: _otpController,
                        decoration: const InputDecoration(
                          labelText: 'OTP Code',
                          prefixIcon: Icon(Icons.security, color: Color(0xFF00D4FF)),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 10),
                      TextButton(
                        onPressed: _sendOtp,
                        child: const Text('Send OTP', style: TextStyle(color: Color(0xFF00D4FF))),
                      ),
                    ],
                  ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Checkbox(
                      value: _useOtp,
                      onChanged: (value) => setState(() => _useOtp = value ?? false),
                      activeColor: const Color(0xFF00D4FF),
                    ),
                    const Text('Use OTP instead of password', style: TextStyle(color: Colors.white)),
                  ],
                ),
                const SizedBox(height: 20),
                if (!_useOtp)
                  _isLoading
                      ? const CircularProgressIndicator(color: Color(0xFF00D4FF))
                      : ElevatedButton(
                          onPressed: _login,
                          child: const Text('LOGIN'),
                        ),
                if (_useOtp)
                  _isLoading
                      ? const CircularProgressIndicator(color: Color(0xFF00D4FF))
                      : ElevatedButton(
                          onPressed: _verifyOtp,
                          child: const Text('VERIFY OTP'),
                        ),
                const SizedBox(height: 10),
                if (Provider.of<AuthProvider>(context).biometricAvailable)
                  ElevatedButton.icon(
                    onPressed: _biometricLogin,
                    icon: const Icon(Icons.fingerprint),
                    label: const Text('BIOMETRIC LOGIN'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00D4FF),
                      foregroundColor: Colors.black,
                    ),
                  ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/register'),
                  child: const Text(
                    'Create Account',
                    style: TextStyle(color: Color(0xFF00D4FF)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _login() async {
    setState(() => _isLoading = true);
    try {
      await Provider.of<AuthProvider>(context, listen: false).login(
        _emailController.text,
        _passwordController.text,
      );
      if (Provider.of<AuthProvider>(context, listen: false).publicKey != null) {
        await Provider.of<WalletProvider>(context, listen: false).loadBalance(
          Provider.of<AuthProvider>(context, listen: false).publicKey!,
        );
        await Provider.of<WalletProvider>(context, listen: false).loadTransactions(
          Provider.of<AuthProvider>(context, listen: false).publicKey!,
        );
      }
      Navigator.pushReplacementNamed(context, '/wallet');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed: $e')),
      );
    }
    setState(() => _isLoading = false);
  }

  Future<void> _sendOtp() async {
    if (_emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter email first')),
      );
      return;
    }
    try {
      await Provider.of<AuthProvider>(context, listen: false).sendOtp(_emailController.text);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('OTP sent to email')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Send OTP failed: $e')),
      );
    }
  }

  Future<void> _verifyOtp() async {
    setState(() => _isLoading = true);
    try {
      await Provider.of<AuthProvider>(context, listen: false).verifyOtp(
        _emailController.text,
        _otpController.text,
      );
      if (Provider.of<AuthProvider>(context, listen: false).publicKey != null) {
        await Provider.of<WalletProvider>(context, listen: false).loadBalance(
          Provider.of<AuthProvider>(context, listen: false).publicKey!,
        );
        await Provider.of<WalletProvider>(context, listen: false).loadTransactions(
          Provider.of<AuthProvider>(context, listen: false).publicKey!,
        );
      }
      Navigator.pushReplacementNamed(context, '/wallet');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('OTP verification failed: $e')),
      );
    }
    setState(() => _isLoading = false);
  }

  Future<void> _biometricLogin() async {
    if (_emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter email first')),
      );
      return;
    }
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final authenticated = await authProvider.authenticateBiometric();
    if (authenticated) {
      setState(() => _isLoading = true);
      try {
        await authProvider.biometricLogin(_emailController.text);
        if (authProvider.publicKey != null) {
          await Provider.of<WalletProvider>(context, listen: false).loadBalance(authProvider.publicKey!);
          await Provider.of<WalletProvider>(context, listen: false).loadTransactions(authProvider.publicKey!);
        }
        Navigator.pushReplacementNamed(context, '/wallet');
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Biometric login failed: $e')),
        );
      }
      setState(() => _isLoading = false);
    }
  }
}