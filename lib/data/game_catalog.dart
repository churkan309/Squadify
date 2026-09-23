// ข้อมูลเกมแต่ละตัวที่แอพรองรับ เก็บเป็น Map กลางที่เดียว เพิ่มเกมใหม่แก้ที่นี่พอ
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
