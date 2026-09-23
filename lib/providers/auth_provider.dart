import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';

// ครอบ AuthService ไว้แจ้ง UI เมื่อสถานะล็อกอิน/username เปลี่ยน
// (ใช้ context.watch<AuthProvider>() ในหน้าที่ต้องโชว์ชื่อผู้ใช้แบบ realtime)
class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  StreamSubscription<User?>? _authSubscription;
  User? _user;
  String? _username;
  bool _disposed = false;

  AuthProvider({AuthService? authService})
    : _authService = authService ?? AuthService() {
    _user = _authService.currentUser;
    _username = _user?.displayName;
    _authSubscription = _authService.authStateChanges().listen(_onUserChanged);
    if (_user != null) {
      _loadUsername(_user!);
    }
  }

  User? get user => _user;
  String? get username => _username;
  AuthService get service => _authService;

  Future<String> currentUsername() async {
    final currentUser = _user ?? _authService.currentUser;
    if (currentUser == null) return 'ผู้เล่น';

    try {
      final profile = await _authService.getUserProfile(currentUser.uid);
      final profileUsername = profile?['username'] as String?;
      if (profileUsername != null && profileUsername.trim().isNotEmpty) {
        return profileUsername.trim();
      }
    } catch (_) {
      // Use Firebase Auth's display name when the profile cannot be read.
    }

    final displayName = currentUser.displayName?.trim();
    return displayName == null || displayName.isEmpty ? 'ผู้เล่น' : displayName;
  }

  Future<void> _onUserChanged(User? user) async {
    _user = user;
    _username = user?.displayName;
    if (_disposed) return;
    notifyListeners();
    if (user == null) {
      _username = null;
      return;
    }
    await _loadUsername(user);
  }

  Future<void> _loadUsername(User user) async {
    try {
      final profile = await _authService.getUserProfile(user.uid);
      final profileUsername = profile?['username'] as String?;
      final username = profileUsername?.trim();
      if (_disposed || _user?.uid != user.uid) return;
      if (username != null && username.isNotEmpty) {
        _username = username;
      } else {
        _username = user.displayName;
      }
    } catch (_) {
      if (_disposed || _user?.uid != user.uid) return;
      _username = user.displayName;
    }
    if (_disposed) return;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _authSubscription?.cancel();
    super.dispose();
  }
}
