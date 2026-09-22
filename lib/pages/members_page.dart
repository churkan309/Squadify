import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../widgets/profile_info_bar.dart';

class MembersPage extends StatelessWidget {
  const MembersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('สมาชิก'),
        backgroundColor: AppColors.appBar,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          Align(
            alignment: Alignment.topCenter,
            child: ProfileInfoBar(
              name: 'สวัสดิภาพ ธงศิลา',
              detail: '6721602661',
            ),
          ),
          SizedBox(height: 10),
          Align(
            alignment: Alignment.topCenter,
            child: ProfileInfoBar(
              name: 'เฌอกานต์',
              detail: '6721602326',
            ),
          ),
        ],
      ),
    );
  }
}