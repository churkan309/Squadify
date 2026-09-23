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
        title: const Text(
          'Group\'s Members',
          style: TextStyle(
            color: Color.fromARGB(255, 234, 234, 234),
            fontWeight: FontWeight.w900,
            fontSize: 30,
          ),
        ),
        backgroundColor: AppColors.appBar,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
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
              name: 'เฌอกานต์ คล้ายเครือ',
              detail: '6721602326',
            ),
          ),
          SizedBox(height: 10),
          Image.asset('assets/images/whoIsJson.png'),
        ],
      ),
    );
  }
}
