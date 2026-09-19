import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../validation/form_validator.dart';

// ข้อมูลเกมแต่ละตัว เก็บเป็น Map กลาง จะได้แก้ทีเดียวถ้าจะเพิ่มเกมใหม่
class GameInfo {
  final int maxMembers;
  final String iconPath; // path รูปใน assets

  GameInfo({required this.maxMembers, required this.iconPath});
}

final Map<String, GameInfo> gameData = {
  'League of Legends': GameInfo(
    maxMembers: 5,
    iconPath: 'assets/icons/lol.png',
  ),
  'Valorant': GameInfo(maxMembers: 5, iconPath: 'assets/icons/valorant.png'),
  'Dota 2': GameInfo(maxMembers: 5, iconPath: 'assets/icons/dota2.png'),
  'Overwatch 2': GameInfo(maxMembers: 5, iconPath: 'assets/icons/ow2.png'),
  'Apex Legends': GameInfo(maxMembers: 3, iconPath: 'assets/icons/apex.png'),
};

// onCreated: เรียกกลับพร้อม partyId หลังสร้าง Squad สำเร็จ (พาไปหน้า detail ทันที)
// หมายเหตุ: ผู้เรียกควรเช็ค hasHostedParty() ก่อนเปิด dialog นี้อยู่แล้ว
// (ดู main_navigation_page.dart) เพื่อกันไม่ให้สร้างซ้ำ
void showCreatePartyDialog(
  BuildContext context, {
  void Function(String partyId)? onCreated,
}) {
  final TextEditingController descriptionController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  String? selectedGame;
  bool isLoading = false;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          final selectedGameInfo = selectedGame != null
              ? gameData[selectedGame]
              : null;

          Future<void> handleCreate() async {
            if (!formKey.currentState!.validate()) return;
            final user = FirebaseAuth.instance.currentUser;
            if (user == null) return;

            setState(() => isLoading = true);
            final navigator = Navigator.of(context);
            try {
              final info = gameData[selectedGame]!;
              final firestore = FirebaseFirestore.instance;
              final partyRef = firestore.collection('parties').doc();

              // ดึง username จริงจาก Firestore มาใช้เป็น hostName (สำรองเป็น displayName)
              final userDoc = await firestore
                  .collection('users')
                  .doc(user.uid)
                  .get();
              final hostName =
                  (userDoc.data()?['username'] as String?) ??
                  user.displayName ??
                  'ผู้เล่น';

              // สร้าง doc party + เพิ่ม host เข้า subcollection members ในคราวเดียว
              final batch = firestore.batch();
              batch.set(partyRef, {
                'game': selectedGame,
                'iconPath': info.iconPath,
                'maxMembers': info.maxMembers,
                'description': descriptionController.text.trim(),
                'hostId': user.uid,
                'hostName': hostName,
                'memberCount': 1,
                'status': 'open',
                'createdAt': FieldValue.serverTimestamp(),
              });
              batch.set(partyRef.collection('members').doc(user.uid), {
                'name': hostName,
                'avatarUrl': '',
                'isLeader': true,
                'joinedAt': FieldValue.serverTimestamp(),
              });
              await batch.commit();

              navigator.pop();
              onCreated?.call(partyRef.id);
            } finally {
              setState(() => isLoading = false);
            }
          }

          return AlertDialog(
            backgroundColor: const Color(0xFF1A1A1A),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              'Create Squad',
              style: TextStyle(color: Colors.white),
            ),
            content: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 👇 Dropdown เลือกเกม
                    DropdownButtonFormField<String>(
                      value: selectedGame,
                      dropdownColor: const Color(0xFF1A1A1A),
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Game',
                        labelStyle: TextStyle(color: Colors.white70),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white30),
                        ),
                      ),
                      items: gameData.keys.map((gameName) {
                        return DropdownMenuItem(
                          value: gameName,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset(
                                gameData[gameName]!.iconPath,
                                width: 20,
                                height: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(gameName),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedGame = value;
                        });
                      },
                      validator: FormValidator.validateGame,
                    ),

                    const SizedBox(height: 16),

                    // 👇 ไอคอนใหญ่ขึ้น + จำนวนสมาชิก 1/x เฉพาะตอนเลือกเกมแล้ว
                    if (selectedGameInfo != null)
                      Row(
                        children: [
                          Image.asset(
                            selectedGameInfo.iconPath,
                            width: 40,
                            height: 40,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '1/${selectedGameInfo.maxMembers}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'สมาชิก',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),

                    const SizedBox(height: 16),

                    // 👇 Description พิมพ์อิสระ
                    TextFormField(
                      controller: descriptionController,
                      style: const TextStyle(color: Colors.white),
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        hintText: 'เช่น เล่น chill ๆ ไม่ toxic',
                        hintStyle: TextStyle(color: Colors.white38),
                        labelStyle: TextStyle(color: Colors.white70),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white30),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: isLoading ? null : () => Navigator.pop(context),
                child: const Text(
                  'ยกเลิก',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlue[100],
                ),
                onPressed: isLoading ? null : handleCreate,
                child: isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Create'),
              ),
            ],
          );
        },
      );
    },
  );
}
