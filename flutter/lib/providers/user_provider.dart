import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UserProvider extends ChangeNotifier {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  Map<String, dynamic>? _user;
  bool _useToll = true;
  String? _token;

  Map<String, dynamic>? get user => _user;

  bool get isLogged => _user != null;

  String? get userId => _user?['id'];

  String? get userName => _user?['pseudo'];

  String? get userEmail => _user?['email'];

  String? get userRole => _user?['role'];
  bool get useToll => _useToll;

  String? get userPicture => _user?['picture'];

  String? get token => _token;

  UserProvider() {
    _loadUserFromStorage(); // auto init
    _loadTokenFromStorage(); // auto init
    _checkTokenValidity();
  }

  Future<void> _checkTokenValidity() async {
    if (_token == null) return;

    try {
      final parts = _token!.split('.');
      if (parts.length != 3) {
        removeUser(); // Token invalide
        return;
      }

      final payload = jsonDecode(
          utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))));
      final exp = payload['exp'] as int?;
      if (exp == null || DateTime.now().millisecondsSinceEpoch / 1000 > exp) {
        removeUser(); // Token expiré
      }
    } catch (e) {
      removeUser(); // Erreur lors de la vérification
    }
  }

  Future<void> setUser(Map<String, dynamic> user) async {
    _user = user;
    await _storage.write(key: 'user', value: jsonEncode(user));
    notifyListeners();
  }

  void removeUser() async {
    _user = null;
    await _storage.delete(key: 'user');
    await _storage.delete(key: 'token');
    notifyListeners();
  }

  Future<void> _loadUserFromStorage() async {
    final userJson = await _storage.read(key: 'user');
    if (userJson != null) {
      _user = jsonDecode(userJson);
      notifyListeners();
    }
    final useTollValue = await _storage.read(key: 'useToll');
    if (useTollValue != null) {
      _useToll = useTollValue.toLowerCase() == 'true';
    }
  }
  Future<void> setUseToll(bool value) async {
    _useToll = value;
    await _storage.write(key: 'useToll', value: value.toString());
    notifyListeners();
  }

  Future<void> setToken(String token) async {
    _token = token;
    await _storage.write(key: 'token', value: token);
    notifyListeners();
  }

  Future<void> _loadTokenFromStorage() async {
    final token = await _storage.read(key: 'token');
    if (token != null) {
      _token = token;
      notifyListeners();
    }
  }
}
