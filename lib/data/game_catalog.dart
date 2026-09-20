// ข้อมูลเกมแต่ละตัวที่แอพรองรับ เก็บเป็น Map กลางที่เดียว
// ย้ายมาจาก create_party_dialog.dart — เป็น "ข้อมูล" ไม่ใช่ UI จึงไม่ควรอยู่ในไฟล์ widget
// เพิ่มเกมใหม่ แก้ที่นี่ที่เดียวพอ (ต้องมีไฟล์ไอคอนจริงตาม TODO ข้อ 5 ใน PROJECT_NOTES.txt)
class GameInfo {
  final int maxMembers;
  final String iconPath; // path รูปใน assets

  const GameInfo({required this.maxMembers, required this.iconPath});
}

const Map<String, GameInfo> gameCatalog = {
  'League of Legends': GameInfo(maxMembers: 5, iconPath: 'assets/icons/lol.png'),
  'Valorant': GameInfo(maxMembers: 5, iconPath: 'assets/icons/valorant.png'),
  'Dota 2': GameInfo(maxMembers: 5, iconPath: 'assets/icons/dota2.png'),
  'Overwatch 2': GameInfo(maxMembers: 5, iconPath: 'assets/icons/ow2.png'),
  'Apex Legends': GameInfo(maxMembers: 3, iconPath: 'assets/icons/apex.png'),
};
