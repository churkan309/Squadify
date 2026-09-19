import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// จัดการเรื่อง login/logout และเก็บสถานะการล็อกอินแบบปลอดภัย (secure storage)
class AuthService {
  final FlutterSecureStorage _secureStorage;

  AuthService({FlutterSecureStorage? secureStorage})
      : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  // TODO: ตอนนี้ยัง hardcode username/password ไว้ก่อน ค่อยเปลี่ยนเป็นเรียก API จริงทีหลัง
  static const String _correctUsername = 'admin';
  static const String _correctPassword = '123456';

  Future<bool> login(String username, String password) async {
    final isValid = username == _correctUsername && password == _correctPassword;

    if (isValid) {
      await _secureStorage.write(key: 'isLoggedIn', value: 'true');
    }
    return isValid;
  }

  Future<bool> checkLoginStatus() async {
    final value = await _secureStorage.read(key: 'isLoggedIn');
    return value == 'true';
  }

  Future<void> logout() async {
    await _secureStorage.delete(key: 'isLoggedIn');
  }
}
