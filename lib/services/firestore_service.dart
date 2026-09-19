import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

// รวมของที่ provider หลายตัวใช้ร่วมกัน: อ้างอิง Firestore instance กลาง
// + cache โพสต์ล่าสุดไว้ดู offline + เก็บ draft ข้อความที่พิมพ์ค้างไว้
// ⚠️ shared_preferences เก็บแค่ในเครื่อง ไม่ sync กับใคร ใช้แค่ 2 อย่างนี้เท่านั้น
// ข้อมูลจริงของแอพ (parties, posts, comments) อยู่ Firestore เสมอ
class FirestoreService {
  static const _cachedPostsKey = 'community_cached_posts';
  static const _draftKey = 'community_draft';

  final FirebaseFirestore firestore;

  FirestoreService({FirebaseFirestore? firestore}) : firestore = firestore ?? FirebaseFirestore.instance;

  Future<void> cachePosts(List<Map<String, dynamic>> posts) async {
    final prefs = await SharedPreferences.getInstance();
    // Timestamp เป็น object ที่ jsonEncode ไม่ได้ตรงๆ แปลงเป็น millis ก่อน
    final safePosts = posts.map((p) {
      final copy = Map<String, dynamic>.from(p);
      final createdAt = copy['createdAt'];
      if (createdAt is Timestamp) {
        copy['createdAt'] = createdAt.millisecondsSinceEpoch;
      }
      return copy;
    }).toList();
    await prefs.setString(_cachedPostsKey, jsonEncode(safePosts));
  }

  Future<List<Map<String, dynamic>>> readCachedPosts() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_cachedPostsKey);
    if (raw == null) return [];
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded.cast<Map<String, dynamic>>();
  }

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
