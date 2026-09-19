import 'package:flutter/material.dart';

class TeamMember {
  final String name;
  final String studentId;
  TeamMember({required this.name, required this.studentId});
}

final List<TeamMember> teamMembers = [
  TeamMember(name: 'สวัสดิภาพ ธงศิลา', studentId: '6721602661'),
  TeamMember(name: 'เฌอกานต์ คล้ายเคลือ', studentId: '6721602326'),
];

// หน้าที่เปิดจาก Settings > Profile แสดงรายชื่อผู้จัดทำ
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(235, 10, 15, 13),
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: const Color(0xFF1B3A2E),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: teamMembers.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final member = teamMembers[index];
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white24),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: Colors.white12,
                  child: Text(
                    member.name.isNotEmpty ? member.name[0] : '?',
                    style: const TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        member.name,
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'รหัสนักศึกษา: ${member.studentId}',
                        style: const TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
