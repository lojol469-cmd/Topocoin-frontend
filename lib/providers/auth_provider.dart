import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:logging/logging.dart';

class AuthProvider with ChangeNotifier {
  final Logger _logger = Logger('AuthProvider');
  final String baseUrl = 'https://topocoin-backend.onrender.com';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final LocalAuthentication _localAuth = LocalAuthentication();

  String? _token;
  String? _email;
  String? _publicKey;
  String? _userId;
  bool _biometricAvailable = false;
  bool _biometricRequired = false;
  String? _faceIdData;
  String? _fingerprintData;

  String? get token => _token;
  String? get email => _email;
  String? get publicKey => _publicKey;
  String? get userId => _userId;
  bool get isAuthenticated => _token != null;
  bool get biometricAvailable => _biometricAvailable;
  bool get biometricRequired => _biometricRequired;
  String? get faceIdData => _faceIdData;
  String? get fingerprintData => _fingerprintData;

  Future<void> checkBiometric() async {
    try {
      _biometricAvailable = await _localAuth.canCheckBiometrics;
      notifyListeners();
    } catch (e) {
      _biometricAvailable = false;
    }
  }

  Future<bool> authenticateBiometric() async {
    try {
      return await _localAuth.authenticate(
        localizedReason: 'Authenticate to access your wallet',
      );
    } catch (e) {
      return false;
    }
  }

  Future<void> login(String email, String password, {String? passphrase}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': email,
        'password': password,
        'passphrase': passphrase,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      _token = data['token'];
      _email = email;
      _publicKey = data['publicKey'];
      _userId = data['userId'] ?? _generateUserId();
      _biometricRequired = data['biometricRequired'] ?? false;
      
      await _storage.write(key: 'token', value: _token);
      await _storage.write(key: 'email', value: _email);
      await _storage.write(key: 'publicKey', value: _publicKey);
      await _storage.write(key: 'userId', value: _userId);
      await _storage.write(key: 'biometricRequired', value: _biometricRequired.toString());
      
      // Enregistrer les données biométriques après connexion réussie
      await _registerBiometricData();
      
      notifyListeners();
    } else {
      throw Exception('Login failed');
    }
  }

  Future<void> register(String email, String password, String passphrase) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': email,
        'password': password,
        'passphrase': passphrase,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      _publicKey = data['publicKey'];
      notifyListeners();
    } else {
      throw Exception('Registration failed');
    }
  }

  Future<void> logout() async {
    _token = null;
    _email = null;
    _publicKey = null;
    await _storage.deleteAll();
    notifyListeners();
  }

  Future<void> biometricLogin(String email) async {
    final response = await http.post(
      Uri.parse('$baseUrl/biometric-login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      _token = data['token'];
      _email = email;
      _publicKey = data['publicKey'];
      await _storage.write(key: 'token', value: _token);
      await _storage.write(key: 'email', value: _email);
      await _storage.write(key: 'publicKey', value: _publicKey);
      notifyListeners();
    } else {
      throw Exception('Biometric login failed');
    }
  }

  Future<void> sendOtp(String email) async {
    final response = await http.post(
      Uri.parse('$baseUrl/send-otp'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email}),
    );

    if (response.statusCode != 200) {
      throw Exception('Send OTP failed');
    }
  }

  Future<void> verifyOtp(String email, String otp) async {
    final response = await http.post(
      Uri.parse('$baseUrl/verify-otp'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'otp': otp}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      _token = data['token'];
      _email = email;
      _publicKey = data['publicKey'];
      await _storage.write(key: 'token', value: _token);
      await _storage.write(key: 'email', value: _email);
      await _storage.write(key: 'publicKey', value: _publicKey);
      notifyListeners();
    } else {
      throw Exception('OTP verification failed');
    }
  }

  Future<void> tryAutoLogin() async {
    final token = await _storage.read(key: 'token');
    final email = await _storage.read(key: 'email');
    final publicKey = await _storage.read(key: 'publicKey');
    final userId = await _storage.read(key: 'userId');
    final biometricRequired = await _storage.read(key: 'biometricRequired');
    final faceIdData = await _storage.read(key: 'faceIdData');
    final fingerprintData = await _storage.read(key: 'fingerprintData');
    
    if (token != null && email != null && publicKey != null) {
      _token = token;
      _email = email;
      _publicKey = publicKey;
      _userId = userId;
      _biometricRequired = biometricRequired == 'true';
      _faceIdData = faceIdData;
      _fingerprintData = fingerprintData;
      notifyListeners();
    }
  }

  Future<void> enableBiometricRequirement() async {
    _biometricRequired = true;
    await _storage.write(key: 'biometricRequired', value: 'true');
    notifyListeners();
  }

  Future<bool> verifyPassphrase(String passphrase) async {
    if (_email == null) return false;
    
    final response = await http.post(
      Uri.parse('$baseUrl/verify-passphrase'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': _email,
        'passphrase': passphrase,
      }),
    );

    return response.statusCode == 200;
  }

  String _generateUserId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = DateTime.now().microsecondsSinceEpoch % 10000;
    return 'TPC_${timestamp}_$random';
  }

  Future<void> _registerBiometricData() async {
    try {
      // Capturer les données biométriques disponibles
      final availableBiometrics = await _localAuth.getAvailableBiometrics();
      
      if (availableBiometrics.contains(BiometricType.face)) {
        _faceIdData = 'face_registered_${DateTime.now().toIso8601String()}';
        await _storage.write(key: 'faceIdData', value: _faceIdData);
      }
      
      if (availableBiometrics.contains(BiometricType.fingerprint)) {
        _fingerprintData = 'fingerprint_registered_${DateTime.now().toIso8601String()}';
        await _storage.write(key: 'fingerprintData', value: _fingerprintData);
      }
      
      // Envoyer les données biométriques au backend
      if (_userId != null) {
        await http.post(
          Uri.parse('$baseUrl/register-biometric'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'userId': _userId,
            'faceIdData': _faceIdData,
            'fingerprintData': _fingerprintData,
            'email': _email,
          }),
        );
      }
    } catch (e) {
      // Ne pas échouer si l'enregistrement biométrique échoue
      _logger.warning('Biometric registration failed: $e');
    }
  }

  Future<bool> changePassphrase(String oldPassphrase, String newPassphrase) async {
    if (_email == null) return false;

    final response = await http.post(
      Uri.parse('$baseUrl/change-passphrase'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': _email,
        'oldPassphrase': oldPassphrase,
        'newPassphrase': newPassphrase,
      }),
    );

    return response.statusCode == 200;
  }
}