import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../widgets/settings_tile.dart';
import 'login_page.dart';
import 'profile_page.dart';

// แท็บ "ตั้งค่า" — Profile กับ Logout (Logout เรียก AuthService จริง)
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SettingsTile(
          icon: Icons.person_outline,
          title: 'Profile',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfilePage()),
            );
          },
        ),
        SettingsTile(
          icon: Icons.logout,
          title: 'Logout',
          color: Colors.redAccent,
          onTap: () async {
            final navigator = Navigator.of(context);
            await AuthService().signOut();
            navigator.pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const LoginPage()),
              (route) => false,
            );
          },
        ),
      ],
    );
  }
}
