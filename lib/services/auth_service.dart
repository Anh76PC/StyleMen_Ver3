import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pocketbase/pocketbase.dart';

class AuthService with ChangeNotifier {
  final PocketBase _pb = PocketBase('http://pocketbase.anhpc.online:8090');
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  static const String _tokenKey = 'auth_token';
  bool _isLoggedIn = false;

  bool get isLoggedIn => _isLoggedIn;
  PocketBase get pb => _pb;

  Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      final authData = await _pb.collection('users').authWithPassword(email, password);
      if (authData.token.isNotEmpty) {
        await _storage.write(key: _tokenKey, value: authData.token);
        _isLoggedIn = true;
        notifyListeners();
        return {
          'token': authData.token,
          'record': authData.record.toJson(),
        };
      }
      return null;
    } catch (e) {
      //('Login failed: $e');
      return null;
    }
  }

  Future<bool> checkLoginStatus() async {
    try {
      final token = await _storage.read(key: _tokenKey);
      if (token != null && token.isNotEmpty) {
        _pb.authStore.save(token, _pb.authStore.model);
        final result = await _pb.collection('users').authRefresh();
        if (result != null && _pb.authStore.isValid) {
          _isLoggedIn = true;
          notifyListeners();
          return true;
        }
      }
      _isLoggedIn = false;
      notifyListeners();
      return false;
    } catch (e) {
      //print('Error checking login status: $e');
      _isLoggedIn = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _pb.authStore.clear();
    await _storage.delete(key: _tokenKey);
    _isLoggedIn = false;
    notifyListeners();
  }
}