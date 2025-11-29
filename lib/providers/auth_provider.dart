import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

class AuthProvider with ChangeNotifier {
  final String baseUrl = 'https://topocoin-backend.onrender.com';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final LocalAuthentication _localAuth = LocalAuthentication();

  String? _token;
  String? _email;
  String? _publicKey;
  bool _biometricAvailable = false;

  String? get token => _token;
  String? get email => _email;
  String? get publicKey => _publicKey;
  bool get isAuthenticated => _token != null;
  bool get biometricAvailable => _biometricAvailable;

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

  Future<void> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'password': password}),
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
    if (token != null && email != null && publicKey != null) {
      _token = token;
      _email = email;
      _publicKey = publicKey;
      notifyListeners();
    }
  }
}