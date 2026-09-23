import 'package:shared_preferences/shared_preferences.dart';

// เก็บ draft ข้อความที่พิมพ์ค้างไว้ในกระดานสนทนา (เก็บแค่ในเครื่อง)
class FirestoreService {
  static const _draftKey = 'community_draft';

  Future<void> saveDraft(String text) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_draftKey, text);
  }

  Future<String> readDraft() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_draftKey) ?? '';
  }

  Future<void> clearDraft() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_draftKey);
  }
}
