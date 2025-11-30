import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _passphraseController = TextEditingController();
  bool _showPassphrase = false;
  bool _isVerifying = false;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

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
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Profile',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 30),
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: const Color(0xFF00D4FF),
                        child: Text(
                          (authProvider.email ?? 'U')[0].toUpperCase(),
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        authProvider.email ?? 'No email',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00D4FF).withAlpha((0.2 * 255).round()),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFF00D4FF)),
                        ),
                        child: Text(
                          'ID: ${authProvider.userId ?? 'Not generated'}',
                          style: const TextStyle(
                            color: Color(0xFF00D4FF),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                const Text(
                  'Security Settings',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: const Color(0xFF00D4FF), width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Biometric Authentication',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                          Switch(
                            value: authProvider.biometricRequired,
                            onChanged: (value) {
                              if (value) {
                                authProvider.enableBiometricRequirement();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Biometric authentication enabled'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            },
                            activeThumbColor: const Color(0xFF00D4FF),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      Row(
                        children: [
                          Icon(
                            authProvider.faceIdData != null ? Icons.face : Icons.face_retouching_natural,
                            color: authProvider.faceIdData != null ? Colors.green : Colors.grey,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            authProvider.faceIdData != null ? 'Face ID Registered' : 'Face ID Not Registered',
                            style: TextStyle(
                              color: authProvider.faceIdData != null ? Colors.green : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(
                            authProvider.fingerprintData != null ? Icons.fingerprint : Icons.fingerprint_outlined,
                            color: authProvider.fingerprintData != null ? Colors.green : Colors.grey,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            authProvider.fingerprintData != null ? 'Fingerprint Registered' : 'Fingerprint Not Registered',
                            style: TextStyle(
                              color: authProvider.fingerprintData != null ? Colors.green : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Verify Passphrase',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: _passphraseController,
                  decoration: InputDecoration(
                    labelText: 'Enter your passphrase',
                    prefixIcon: const Icon(Icons.security, color: Color(0xFF00D4FF)),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _showPassphrase ? Icons.visibility : Icons.visibility_off,
                        color: const Color(0xFF00D4FF),
                      ),
                      onPressed: () => setState(() => _showPassphrase = !_showPassphrase),
                    ),
                  ),
                  obscureText: !_showPassphrase,
                ),
                const SizedBox(height: 15),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isVerifying ? null : _verifyPassphrase,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00D4FF),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    child: _isVerifying
                        ? const CircularProgressIndicator(color: Colors.black)
                        : const Text('Verify Passphrase'),
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _logout(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    child: const Text('Logout'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _verifyPassphrase() async {
    if (_passphraseController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your passphrase')),
      );
      return;
    }

    setState(() => _isVerifying = true);

    try {
      final isValid = await Provider.of<AuthProvider>(context, listen: false)
          .verifyPassphrase(_passphraseController.text);

      if (isValid) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Passphrase verified successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid passphrase'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Verification failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }

    setState(() => _isVerifying = false);
  }

  Future<void> _logout(BuildContext context) async {
    await Provider.of<AuthProvider>(context, listen: false).logout();
    Navigator.pushReplacementNamed(context, '/login');
  }
}