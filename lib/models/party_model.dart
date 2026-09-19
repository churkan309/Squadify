// ข้อมูลสมาชิกคนหนึ่งใน Squad
class SquadMember {
  final String id;
  final String name;
  final bool isLeader; // หัวปาร์ตี้ (คนสร้าง Squad) เตะตัวเองออกไม่ได้

  SquadMember({
    required this.id,
    required this.name,
    this.isLeader = false,
  });
}

// ข้อมูล Squad/Party หนึ่งกลุ่ม
class Party {
  final String game; // ชื่อเกม
  final String iconPath; // path ไอคอนเกมใน assets
  final int maxMembers; // จำนวนสมาชิกสูงสุดของเกมนี้
  String description; // คำอธิบาย Squad แก้ไขได้ภายหลัง (ช่องเดียวที่แก้ได้)
  final List<SquadMember> members; // รายชื่อสมาชิกในกลุ่ม

  Party({
    required this.game,
    required this.iconPath,
    required this.maxMembers,
    required this.description,
    List<SquadMember>? members,
  }) : members = members ?? [SquadMember(id: 'me', name: 'You', isLeader: true)];

  int get currentMembers => members.length;
}
