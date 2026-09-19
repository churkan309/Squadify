// รวมฟังก์ชันตรวจสอบความถูกต้องของฟอร์มต่างๆ ในแอพไว้ที่เดียว
class FormValidator {
  static String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your username';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    return null;
  }

  static String? validateGame(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please Select Game';
    }
    return null;
  }
}
