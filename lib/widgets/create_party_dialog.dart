import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/game_catalog.dart';
import '../providers/party_provider.dart';
import '../services/auth_service.dart';
import '../theme/app_colors.dart';
import '../validation/form_validator.dart';

// onCreated: เรียกกลับพร้อม partyId หลังสร้าง Squad สำเร็จ (พาไปหน้า detail ทันที)
// หมายเหตุ: ผู้เรียกควรเช็ค hasHostedParty() ก่อนเปิด dialog นี้อยู่แล้ว
// (ดู main_navigation_page.dart) เพื่อกันไม่ให้สร้างซ้ำ
void showCreatePartyDialog(
  BuildContext context, {
  void Function(String partyId)? onCreated,
}) {
  final partyProvider = context.read<PartyProvider>();
  final TextEditingController descriptionController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  String? selectedGame;
  bool isLoading = false;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          final selectedGameInfo = selectedGame != null ? gameCatalog[selectedGame] : null;

          Future<void> handleCreate() async {
            if (!formKey.currentState!.validate()) return;
            final user = FirebaseAuth.instance.currentUser;
            if (user == null) return;

            setState(() => isLoading = true);
            final navigator = Navigator.of(context);
            try {
              final info = gameCatalog[selectedGame]!;

              // ดึง username จริงจาก Firestore มาใช้เป็น hostName (สำรองเป็น displayName)
              final profile = await AuthService().getUserProfile(user.uid);
              final hostName = (profile?['username'] as String?) ?? user.displayName ?? 'ผู้เล่น';

              final partyId = await partyProvider.createParty(
                game: selectedGame!,
                iconPath: info.iconPath,
                maxMembers: info.maxMembers,
                description: descriptionController.text.trim(),
                hostName: hostName,
              );

              navigator.pop();
              onCreated?.call(partyId);
            } finally {
              setState(() => isLoading = false);
            }
          }

          return AlertDialog(
            backgroundColor: AppColors.surface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text('Create Squad', style: TextStyle(color: Colors.white)),
            content: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButtonFormField<String>(
                      value: selectedGame,
                      dropdownColor: AppColors.surface,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Game',
                        labelStyle: TextStyle(color: Colors.white70),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white30),
                        ),
                      ),
                      items: gameCatalog.keys.map((gameName) {
                        return DropdownMenuItem(
                          value: gameName,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset(
                                gameCatalog[gameName]!.iconPath,
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
                          const Text('สมาชิก', style: TextStyle(color: Colors.white70)),
                        ],
                      ),

                    const SizedBox(height: 16),

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
                child: const Text('ยกเลิก', style: TextStyle(color: Colors.white70)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryButton),
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
