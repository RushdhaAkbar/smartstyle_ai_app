import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  String? _token;
  String? get token => _token;

  final AuthService _authService = AuthService();

  Future<void> login(String email, String password) async {
    _token = await _authService.login(email, password);
    notifyListeners();
  }
}