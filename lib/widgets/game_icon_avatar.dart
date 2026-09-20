import 'package:flutter/material.dart';

// ไอคอนเกมวงกลม โหลดจาก assets ตาม iconPath ของ Party
// ถ้าไฟล์ไม่มี (ยังไม่ได้วางไอคอนจริงตาม TODO ข้อ 5) fallback เป็น Icons.videogame_asset
// ใช้ร่วมกันใน party_card.dart (การ์ดย่อ) และ squad_detail_page.dart (หน้ารายละเอียด)
class GameIconAvatar extends StatelessWidget {
  final String iconPath;
  final double size;

  const GameIconAvatar({super.key, required this.iconPath, this.size = 44});

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Image.asset(
        iconPath,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          width: size,
          height: size,
          color: Colors.white12,
          child: Icon(Icons.videogame_asset, color: Colors.white54, size: size * 0.5),
        ),
      ),
    );
  }
}
