import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/language_provider.dart';

class BiometricSettingsScreen extends StatefulWidget {
  const BiometricSettingsScreen({super.key});

  @override
  State<BiometricSettingsScreen> createState() => _BiometricSettingsScreenState();
}

class _BiometricSettingsScreenState extends State<BiometricSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(languageProvider.getText('biometric_settings')),
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
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  languageProvider.getText('biometric_settings'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            languageProvider.getText('enable_biometric'),
                            style: const TextStyle(color: Colors.white, fontSize: 16),
                          ),
                          Switch(
                            value: authProvider.biometricRequired,
                            onChanged: (value) {
                              if (value) {
                                authProvider.enableBiometricRequirement();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(languageProvider.getText('success')),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            },
                            activeThumbColor: const Color(0xFF00D4FF),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      if (authProvider.faceIdData != null)
                        ListTile(
                          leading: const Icon(Icons.face, color: Color(0xFF00D4FF)),
                          title: Text(languageProvider.getText('face_id'), style: const TextStyle(color: Colors.white)),
                          subtitle: Text(authProvider.faceIdData!, style: TextStyle(color: Colors.grey[400])),
                        ),
                      if (authProvider.fingerprintData != null)
                        ListTile(
                          leading: const Icon(Icons.fingerprint, color: Color(0xFF00D4FF)),
                          title: Text(languageProvider.getText('fingerprint'), style: const TextStyle(color: Colors.white)),
                          subtitle: Text(authProvider.fingerprintData!, style: TextStyle(color: Colors.grey[400])),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}