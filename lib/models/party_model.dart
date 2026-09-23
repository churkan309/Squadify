import 'package:cloud_firestore/cloud_firestore.dart';

// ข้อมูลสมาชิกคนหนึ่งใน Squad (เก็บเป็น subcollection parties/{id}/members)
class SquadMember {
  final String uid;
  final String name;
  final String avatarUrl;
  final bool isLeader; // หัวปาร์ตี้ (คนสร้าง Squad) เตะตัวเองออกไม่ได้
  final DateTime? joinedAt;

  SquadMember({
    required this.uid,
    required this.name,
    this.avatarUrl = '',
    this.isLeader = false,
    this.joinedAt,
  });

  factory SquadMember.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    return SquadMember(
      uid: doc.id,
      name: data['name'] as String? ?? '',
      avatarUrl: data['avatarUrl'] as String? ?? '',
      isLeader: data['isLeader'] as bool? ?? false,
      joinedAt: (data['joinedAt'] as Timestamp?)?.toDate(),
    );
  }

}

// ข้อมูล Squad/Party หนึ่งกลุ่ม เก็บใน Firestore collection `parties`
// members ไม่ได้เป็น field ในนี้แล้ว ย้ายไปเป็น subcollection (ดู SquadMember)
class Party {
  final String id;
  final String game; // ชื่อเกม
  final String iconPath; // path ไอคอนเกมใน assets
  final int maxMembers; // จำนวนสมาชิกสูงสุดของเกมนี้
  final String description; // คำอธิบาย Squad แก้ไขได้ภายหลัง (host แก้ได้เท่านั้น)
  final String hostId; // uid ของหัวปาร์ตี้
  final String hostName;
  final int memberCount; // นับจาก Firestore ไม่ใช่ members.length ในเครื่อง
  final String status; // 'open' | 'full' | 'closed'
  final DateTime? createdAt;

  Party({
    required this.id,
    required this.game,
    required this.iconPath,
    required this.maxMembers,
    required this.description,
    required this.hostId,
    required this.hostName,
    required this.memberCount,
    required this.status,
    this.createdAt,
  });

  factory Party.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    return Party(
      id: doc.id,
      game: data['game'] as String? ?? '',
      iconPath: data['iconPath'] as String? ?? '',
      maxMembers: data['maxMembers'] as int? ?? 0,
      description: data['description'] as String? ?? '',
      hostId: data['hostId'] as String? ?? '',
      hostName: data['hostName'] as String? ?? '',
      memberCount: data['memberCount'] as int? ?? 0,
      status: data['status'] as String? ?? 'open',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

}
