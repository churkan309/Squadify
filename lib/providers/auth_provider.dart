import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';

// ครอบ AuthService ไว้แจ้ง UI เมื่อสถานะล็อกอิน/username เปลี่ยน
// (ใช้ context.watch<AuthProvider>() ในหน้าที่ต้องโชว์ชื่อผู้ใช้แบบ realtime)
class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  User? _user;
  String? _username;

  AuthProvider({AuthService? authService}) : _authService = authService ?? AuthService() {
    _authService.authStateChanges().listen(_onUserChanged);
  }

  User? get user => _user;
  String? get username => _username;
  AuthService get service => _authService;

  Future<void> _onUserChanged(User? user) async {
    _user = user;
    if (user != null) {
      final profile = await _authService.getUserProfile(user.uid);
      _username = profile?['username'] as String? ?? user.displayName;
    } else {
      _username = null;
    }
    notifyListeners();
  }
}
