import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../widgets/profile_info_bar.dart';

// หน้าโปรไฟล์ผู้ใช้ปัจจุบัน แสดง username + email จริงจาก Firestore/Firebase Auth
// เปิดได้จากปุ่ม Profile ใน Settings หรือแตะ CircleAvatar ใน HomeTabPage
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: AppColors.appBar,
      ),
      body: user == null
          ? const Center(child: Text('ไม่พบผู้ใช้', style: TextStyle(color: Colors.white70)))
          : FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              future: FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final data = snapshot.data?.data();
                final username = data?['username'] as String? ?? user.displayName ?? '-';
                final email = data?['email'] as String? ?? user.email ?? '-';

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: ProfileInfoBar(name: username, detail: email),
                  ),
                );
              },
            ),
    );
  }
}
