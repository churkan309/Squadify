import 'package:flutter/material.dart';

// รวมสีที่ใช้ซ้ำทั้งแอพไว้ที่เดียว ก่อนหน้านี้แต่ละไฟล์ประกาศ
// Color.fromARGB(...) / Color(0xFF...) ซ้ำกันเองหลายจุด แก้ทีต้องไล่แก้หลายไฟล์
class AppColors {
  AppColors._();

  // พื้นหลังหลักของแอพ (scaffold, MaterialApp theme)
  static const background = Color.fromARGB(235, 10, 15, 13);

  // พื้นหลัง AppBar / BottomAppBar
  static const appBar = Color.fromARGB(248, 25, 53, 40);

  // การ์ด / กล่อง dialog / bottom sheet
  static const surface = Color(0xFF1A1A1A);

  // popup แจ้งเตือนใต้กระดิ่ง
  static const notificationPopup = Color(0xFF1B3A2E);

  // สีปุ่มหลัก (Create, Login, Register)
  static final primaryButton = Colors.lightBlue[100];

  // เส้นขอบการ์ด/กล่อง
  static const border = Colors.white24;

  static const textPrimary = Colors.white;
  static const textSecondary = Colors.white70;
  static const textMuted = Colors.white38;
  static const textFaint = Colors.white54;
}
