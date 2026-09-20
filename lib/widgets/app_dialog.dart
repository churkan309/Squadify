import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

// AlertDialog กรอบมาตรฐานของแอพ (สีพื้นหลัง, ขอบมน, สไตล์ title)
// ก่อนหน้านี้ AlertDialog(backgroundColor: ..., shape: ..., title: TextStyle(...))
// ถูก copy ซ้ำใน main_navigation_page / squad_detail_page (2 จุด) — รวมไว้ที่นี่ที่เดียว
class AppAlertDialog extends StatelessWidget {
  final String title;
  final Widget content;
  final List<Widget> actions;

  const AppAlertDialog({
    super.key,
    required this.title,
    required this.content,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(title, style: const TextStyle(color: AppColors.textPrimary)),
      content: content,
      actions: actions,
    );
  }
}

// ปุ่ม "ยกเลิก" มาตรฐาน — ไม่ระบุ onPressed จะ pop(context) เฉยๆ ให้อัตโนมัติ
class AppCancelButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String label;
  const AppCancelButton({super.key, this.onPressed, this.label = 'ยกเลิก'});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed ?? () => Navigator.pop(context),
      child: Text(label, style: const TextStyle(color: AppColors.textSecondary)),
    );
  }
}

// dialog แจ้งข้อมูลแบบกดปุ่มเดียวปิด เช่น "สร้าง Squad ใหม่ไม่ได้"
Future<void> showInfoDialog(
  BuildContext context, {
  required String title,
  required String message,
  String buttonLabel = 'เข้าใจแล้ว',
}) {
  return showDialog<void>(
    context: context,
    builder: (context) => AppAlertDialog(
      title: title,
      content: Text(message, style: const TextStyle(color: AppColors.textSecondary)),
      actions: [AppCancelButton(label: buttonLabel)],
    ),
  );
}

// dialog ยืนยัน 2 ปุ่ม (ยกเลิก / ยืนยัน) — คืนค่า true เฉพาะตอนกดยืนยันเท่านั้น
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'ยืนยัน',
  Color? confirmColor,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AppAlertDialog(
      title: title,
      content: Text(message, style: const TextStyle(color: AppColors.textSecondary)),
      actions: [
        AppCancelButton(onPressed: () => Navigator.pop(context, false)),
        ElevatedButton(
          style: confirmColor != null
              ? ElevatedButton.styleFrom(backgroundColor: confirmColor)
              : null,
          onPressed: () => Navigator.pop(context, true),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return result ?? false;
}
