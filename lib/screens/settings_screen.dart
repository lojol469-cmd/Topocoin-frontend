import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/language_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;

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
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  languageProvider.getText('settings'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 30),
                Expanded(
                  child: ListView(
                    children: [
                      _buildSection(
                        languageProvider.getText('security'),
                        [
                          _buildListTile(
                            languageProvider.getText('biometric_settings'),
                            'Configure biometric authentication',
                            Icons.fingerprint,
                            () => Navigator.pushNamed(context, '/biometric_settings'),
                          ),
                          _buildListTile(
                            languageProvider.getText('change_passphrase'),
                            'Update your security passphrase',
                            Icons.lock,
                            () => _showChangePassphraseDialog(context, languageProvider),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildSection(
                        languageProvider.getText('notifications'),
                        [
                          _buildSwitchTile(
                            'Push Notifications',
                            'Receive notifications for transactions and updates',
                            _notificationsEnabled,
                            (value) => setState(() => _notificationsEnabled = value),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildSection(
                        languageProvider.getText('language'),
                        [
                          _buildDropdownTile(
                            languageProvider.getText('language'),
                            'Select your preferred language',
                            languageProvider.currentLanguage == 'fr' ? languageProvider.getText('french') : languageProvider.getText('english'),
                            [languageProvider.getText('english'), languageProvider.getText('french')],
                            (value) {
                              if (value == languageProvider.getText('french')) {
                                languageProvider.setLanguage('fr');
                              } else {
                                languageProvider.setLanguage('en');
                              }
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildSection(
                        languageProvider.getText('about'),
                        [
                          _buildListTile(
                            'Version',
                            '1.0.0',
                            Icons.info,
                            null,
                          ),
                          _buildListTile(
                            'Privacy Policy',
                            'View our privacy policy',
                            Icons.privacy_tip,
                            () => _showPrivacyPolicy(context, languageProvider),
                          ),
                          _buildListTile(
                            'Terms of Service',
                            'View our terms of service',
                            Icons.description,
                            () => _showTermsOfService(context, languageProvider),
                          ),
                        ],
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

  Widget _buildSection(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFF00D4FF), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSwitchTile(String title, String subtitle, bool value, Function(bool) onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(height: 5),
              Text(
                subtitle,
                style: TextStyle(color: Colors.grey[400], fontSize: 12),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: const Color(0xFF00D4FF),
        ),
      ],
    );
  }

  Widget _buildListTile(String title, String subtitle, IconData icon, VoidCallback? onTap) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF00D4FF)),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      subtitle: Text(subtitle, style: TextStyle(color: Colors.grey[400])),
      trailing: onTap != null ? const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16) : null,
      onTap: onTap,
    );
  }

  Widget _buildDropdownTile(String title, String subtitle, String value, List<String> items, Function(String?) onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(height: 5),
              Text(
                subtitle,
                style: TextStyle(color: Colors.grey[400], fontSize: 12),
              ),
            ],
          ),
        ),
        DropdownButton<String>(
          value: value,
          dropdownColor: const Color(0xFF1A1A1A),
          style: const TextStyle(color: Colors.white),
          underline: Container(
            height: 2,
            color: const Color(0xFF00D4FF),
          ),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  void _showChangePassphraseDialog(BuildContext context, LanguageProvider languageProvider) {
    final oldPassphraseController = TextEditingController();
    final newPassphraseController = TextEditingController();
    final confirmPassphraseController = TextEditingController();
    bool showOld = false;
    bool showNew = false;
    bool showConfirm = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1A1A1A),
          title: Text(
            languageProvider.getText('change_passphrase'),
            style: const TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: oldPassphraseController,
                decoration: InputDecoration(
                  labelText: languageProvider.getText('old_passphrase'),
                  labelStyle: const TextStyle(color: Colors.white),
                  suffixIcon: IconButton(
                    icon: Icon(
                      showOld ? Icons.visibility : Icons.visibility_off,
                      color: const Color(0xFF00D4FF),
                    ),
                    onPressed: () => setState(() => showOld = !showOld),
                  ),
                ),
                obscureText: !showOld,
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: newPassphraseController,
                decoration: InputDecoration(
                  labelText: languageProvider.getText('new_passphrase'),
                  labelStyle: const TextStyle(color: Colors.white),
                  suffixIcon: IconButton(
                    icon: Icon(
                      showNew ? Icons.visibility : Icons.visibility_off,
                      color: const Color(0xFF00D4FF),
                    ),
                    onPressed: () => setState(() => showNew = !showNew),
                  ),
                ),
                obscureText: !showNew,
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: confirmPassphraseController,
                decoration: InputDecoration(
                  labelText: languageProvider.getText('confirm_passphrase'),
                  labelStyle: const TextStyle(color: Colors.white),
                  suffixIcon: IconButton(
                    icon: Icon(
                      showConfirm ? Icons.visibility : Icons.visibility_off,
                      color: const Color(0xFF00D4FF),
                    ),
                    onPressed: () => setState(() => showConfirm = !showConfirm),
                  ),
                ),
                obscureText: !showConfirm,
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(languageProvider.getText('cancel'), style: const TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () => _changePassphrase(
                context,
                oldPassphraseController.text,
                newPassphraseController.text,
                confirmPassphraseController.text,
                languageProvider,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00D4FF),
                foregroundColor: Colors.black,
              ),
              child: Text(languageProvider.getText('save')),
            ),
          ],
            );
          },
        );
      },
    );
  }

  Future<void> _changePassphrase(BuildContext context, String oldPass, String newPass, String confirmPass, LanguageProvider languageProvider) async {
    if (oldPass.isEmpty || newPass.isEmpty || confirmPass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All fields are required')),
      );
      return;
    }

    if (newPass != confirmPass) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(languageProvider.getText('passphrase_mismatch'))),
      );
      return;
    }

    try {
      final success = await Provider.of<AuthProvider>(context, listen: false)
          .changePassphrase(oldPass, newPass);

      if (success) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(languageProvider.getText('passphrase_changed')),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(languageProvider.getText('error')),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${languageProvider.getText('error')}: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showPrivacyPolicy(BuildContext context, LanguageProvider languageProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          title: Text(
            'Privacy Policy',
            style: const TextStyle(color: Colors.white),
          ),
          content: const SingleChildScrollView(
            child: Text(
              'Topocoin Wallet Privacy Policy\n\n'
              'We collect and store biometric data (Face ID and fingerprint) for enhanced security. '
              'This data is encrypted and stored securely on our servers. We do not share this '
              'information with third parties.\n\n'
              'Your wallet balance and transaction history are stored securely. We use industry-standard '
              'encryption to protect your financial data.',
              style: TextStyle(color: Colors.white),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close', style: TextStyle(color: Color(0xFF00D4FF))),
            ),
          ],
        );
      },
    );
  }

  void _showTermsOfService(BuildContext context, LanguageProvider languageProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          title: const Text(
            'Terms of Service',
            style: TextStyle(color: Colors.white),
          ),
          content: const SingleChildScrollView(
            child: Text(
              'Topocoin Wallet Terms of Service\n\n'
              'By using this wallet, you agree to:\n\n'
              '1. Use biometric authentication for enhanced security\n'
              '2. Keep your passphrase secure and confidential\n'
              '3. Not engage in illegal activities using this wallet\n'
              '4. Report any security issues immediately\n\n'
              'We reserve the right to suspend accounts that violate these terms.',
              style: TextStyle(color: Colors.white),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close', style: TextStyle(color: Color(0xFF00D4FF))),
            ),
          ],
        );
      },
    );
  }
}