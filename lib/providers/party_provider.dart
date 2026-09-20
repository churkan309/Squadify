import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/party_model.dart';

// คุย Firestore collection `parties` + subcollection `parties/{id}/members`
// กติกา: 1 คนเป็นหัวปาร์ตี้ได้แค่ 1 squad เช็กจาก Firestore เสมอ ไม่ใช่ memory
// แยกให้ชัด: "squad ที่ฉันเป็นหัวปาร์ตี้" (myHostedParty) กับ
// "squad ที่ฉันไป join ของคนอื่น" (เช็กผ่าน isMember)
class PartyProvider {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  PartyProvider({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _parties =>
      _firestore.collection('parties');

  String? get _uid => _auth.currentUser?.uid;

  // squad ที่เปิดรับสมาชิกทั้งหมด เรียงใหม่สุดก่อน
  Stream<List<Party>> get allOpenParties {
    return _parties
        .where('status', isEqualTo: 'open')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => Party.fromFirestore(d)).toList());
  }

  // squad ที่ผู้ใช้ปัจจุบันเป็นหัวปาร์ตี้ (มีได้สูงสุด 1 ใบ)
  Stream<Party?> get myHostedParty {
    final uid = _uid;
    if (uid == null) return Stream.value(null);
    return _parties
        .where('hostId', isEqualTo: uid)
        .limit(1)
        .snapshots()
        .map(
          (snap) =>
              snap.docs.isEmpty ? null : Party.fromFirestore(snap.docs.first),
        );
  }

  Stream<Party?> partyById(String id) {
    return _parties
        .doc(id)
        .snapshots()
        .map((doc) => doc.exists ? Party.fromFirestore(doc) : null);
  }

  Stream<List<SquadMember>> membersOf(String partyId) {
    return _parties
        .doc(partyId)
        .collection('members')
        .orderBy('joinedAt')
        .snapshots()
        .map(
          (snap) => snap.docs.map((d) => SquadMember.fromFirestore(d)).toList(),
        );
  }

  // สร้าง Squad ใหม่: doc party + เพิ่ม host เข้า subcollection members ในคราวเดียว (batch)
  // ผู้เรียกควรเช็ค hasHostedParty() ก่อนเรียกเมธอดนี้อยู่แล้ว (ดู main_navigation_page.dart)
  // คืนค่า id ของ party ที่สร้างเสร็จ
  Future<String> createParty({
    required String game,
    required String iconPath,
    required int maxMembers,
    required String description,
    required String hostName,
  }) async {
    final uid = _uid;
    if (uid == null) throw StateError('กรุณาล็อกอินก่อน');

    final partyRef = _parties.doc();
    final batch = _firestore.batch();
    batch.set(partyRef, {
      'game': game,
      'iconPath': iconPath,
      'maxMembers': maxMembers,
      'description': description,
      'hostId': uid,
      'hostName': hostName,
      'memberCount': 1,
      'status': 'open',
      'createdAt': FieldValue.serverTimestamp(),
    });
    batch.set(partyRef.collection('members').doc(uid), {
      'name': hostName,
      'avatarUrl': '',
      'isLeader': true,
      'joinedAt': FieldValue.serverTimestamp(),
    });
    await batch.commit();
    return partyRef.id;
  }

  // เช็กว่าผู้ใช้ปัจจุบันเป็นหัวปาร์ตี้ของ squad ใบไหนอยู่แล้วหรือยัง (ใช้กันปุ่ม +)
  Future<bool> hasHostedParty() async {
    final uid = _uid;
    if (uid == null) return false;
    final snap = await _parties.where('hostId', isEqualTo: uid).limit(1).get();
    return snap.docs.isNotEmpty;
  }

  // เข้าร่วม squad คนอื่น: กัน join ซ้ำ, กันเกิน maxMembers,
  // อัปเดต status เป็น 'full' อัตโนมัติเมื่อเต็ม — ทั้งหมดในทรานแซกชันเดียว
  // คืนค่า null = สำเร็จ, คืนข้อความ = ทำไม่สำเร็จ (ไว้ขึ้น SnackBar)
  Future<String?> joinParty(
    String partyId, {
    required String name,
    String avatarUrl = '',
  }) async {
    final uid = _uid;
    if (uid == null) return 'กรุณาล็อกอินก่อน';

    return _firestore.runTransaction<String?>((tx) async {
      final partyRef = _parties.doc(partyId);
      final partySnap = await tx.get(partyRef);
      if (!partySnap.exists) return 'ไม่พบ Squad นี้';

      final memberRef = partyRef.collection('members').doc(uid);
      final memberSnap = await tx.get(memberRef);
      if (memberSnap.exists) return 'คุณอยู่ใน Squad นี้อยู่แล้ว';

      final data = partySnap.data()!;
      final maxMembers = data['maxMembers'] as int? ?? 0;
      final memberCount = data['memberCount'] as int? ?? 0;
      if (memberCount >= maxMembers) return 'Squad นี้เต็มแล้ว';

      tx.set(memberRef, {
        'name': name,
        'avatarUrl': avatarUrl,
        'isLeader': false,
        'joinedAt': FieldValue.serverTimestamp(),
      });
      final newCount = memberCount + 1;
      tx.update(partyRef, {
        'memberCount': newCount,
        'status': newCount >= maxMembers ? 'full' : 'open',
      });
      return null;
    });
  }

  // ออกจาก squad คนอื่น (host ออกจาก squad ตัวเองไม่ได้ ให้ลบทั้งอันแทน)
  Future<String?> leaveParty(String partyId) async {
    final uid = _uid;
    if (uid == null) return 'กรุณาล็อกอินก่อน';

    return _firestore.runTransaction<String?>((tx) async {
      final partyRef = _parties.doc(partyId);
      final partySnap = await tx.get(partyRef);
      if (!partySnap.exists) return 'ไม่พบ Squad นี้';

      final data = partySnap.data()!;
      if (data['hostId'] == uid)
        return 'หัวปาร์ตี้ออกจาก Squad ตัวเองไม่ได้ ให้ลบ Squad แทน';

      final memberRef = partyRef.collection('members').doc(uid);
      final memberSnap = await tx.get(memberRef);
      if (!memberSnap.exists) return 'คุณไม่ได้อยู่ใน Squad นี้';

      tx.delete(memberRef);
      final memberCount = data['memberCount'] as int? ?? 1;
      final newCount = memberCount > 0 ? memberCount - 1 : 0;
      tx.update(partyRef, {
        'memberCount': newCount,
        'status': 'open',
      });
      return null;
    });
  }

  // แก้ description ได้เฉพาะ host (ฝั่ง UI ซ่อนปุ่มไว้แล้ว, security rules กันซ้ำอีกชั้น)
  Future<void> updateDescription(String partyId, String text) async {
    await _parties.doc(partyId).update({'description': text});
  }

  // host เตะสมาชิกออก (เตะตัวเองไม่ได้)
  Future<void> removeMember(String partyId, String memberUid) async {
    final partyRef = _parties.doc(partyId);
    await _firestore.runTransaction((tx) async {
      final partySnap = await tx.get(partyRef);
      if (!partySnap.exists) return;
      final data = partySnap.data()!;
      if (data['hostId'] == memberUid) return; // host เตะตัวเองไม่ได้

      final memberRef = partyRef.collection('members').doc(memberUid);
      final memberSnap = await tx.get(memberRef);
      if (!memberSnap.exists) return;

      tx.delete(memberRef);
      final memberCount = data['memberCount'] as int? ?? 1;
      final newCount = memberCount > 0 ? memberCount - 1 : 0;
      tx.update(partyRef, {
        'memberCount': newCount,
        'status': 'open',
      });
    });
  }

  // ลบ squad ทั้งอัน ลบ subcollection members ทิ้งด้วย
  Future<void> deleteParty(String partyId) async {
    final partyRef = _parties.doc(partyId);
    final membersSnap = await partyRef.collection('members').get();
    final batch = _firestore.batch();
    for (final doc in membersSnap.docs) {
      batch.delete(doc.reference);
    }
    batch.delete(partyRef);
    await batch.commit();
  }
}
