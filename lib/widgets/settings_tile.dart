import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color color; // สีไอคอน+ข้อความ (ไว้ทำปุ่ม logout สีแดง)

  const SettingsTile({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          splashColor: Colors.white12,
          highlightColor: Colors.white10,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(title, style: TextStyle(color: color, fontSize: 16)),
                ),
                const Icon(Icons.chevron_right, color: Colors.white38),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
