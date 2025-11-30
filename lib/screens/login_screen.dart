import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/wallet_provider.dart';
import '../providers/language_provider.dart';

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
        Navigator.pushReplacementNamed(context, '/main');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/external_logo.png',
                  height: 120,
                  width: 120,
                  fit: BoxFit.contain,
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
                  decoration: InputDecoration(
                    labelText: languageProvider.getText('email'),
                    prefixIcon: Icon(Icons.email, color: Color(0xFF00D4FF)),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 20),
                if (!_useOtp)
                  TextField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: languageProvider.getText('password'),
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
                        decoration: InputDecoration(
                          labelText: languageProvider.getText('otp'),
                          prefixIcon: Icon(Icons.security, color: Color(0xFF00D4FF)),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 10),
                      TextButton(
                        onPressed: _sendOtp,
                        child: Text(languageProvider.getText('send_otp'), style: TextStyle(color: Color(0xFF00D4FF))),
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
                    Text('Use OTP instead of password', style: TextStyle(color: Colors.white)),
                  ],
                ),
                const SizedBox(height: 20),
                if (!_useOtp)
                  _isLoading
                      ? const CircularProgressIndicator(color: Color(0xFF00D4FF))
                      : ElevatedButton(
                          onPressed: _login,
                          child: Text(languageProvider.getText('login')),
                        ),
                if (_useOtp)
                  _isLoading
                      ? const CircularProgressIndicator(color: Color(0xFF00D4FF))
                      : ElevatedButton(
                          onPressed: _verifyOtp,
                          child: Text(languageProvider.getText('verify_otp')),
                        ),
                const SizedBox(height: 10),
                if (Provider.of<AuthProvider>(context).biometricAvailable)
                  ElevatedButton.icon(
                    onPressed: _biometricLogin,
                    icon: const Icon(Icons.fingerprint),
                    label: Text(languageProvider.getText('biometric_login')),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00D4FF),
                      foregroundColor: Colors.black,
                    ),
                  ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/register'),
                  child: Text(
                    languageProvider.getText('create_account'),
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
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
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
        SnackBar(content: Text('${languageProvider.getText('login_failed')}: $e')),
      );
    }
    setState(() => _isLoading = false);
  }

  Future<void> _sendOtp() async {
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    if (_emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(languageProvider.getText('enter_email_first'))),
      );
      return;
    }
    try {
      await Provider.of<AuthProvider>(context, listen: false).sendOtp(_emailController.text);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(languageProvider.getText('otp_sent'))),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${languageProvider.getText('error')}: $e')),
      );
    }
  }

  Future<void> _verifyOtp() async {
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
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
        SnackBar(content: Text('${languageProvider.getText('otp_verification_failed')}: $e')),
      );
    }
    setState(() => _isLoading = false);
  }

  Future<void> _biometricLogin() async {
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    if (_emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(languageProvider.getText('enter_email_first'))),
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
          SnackBar(content: Text('${languageProvider.getText('biometric_login_failed')}: $e')),
        );
      }
      setState(() => _isLoading = false);
    }
  }
}