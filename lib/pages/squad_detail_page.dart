import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';

import '../models/party_model.dart';
import '../providers/party_provider.dart';

// หน้าขยายรายละเอียด Squad ของผู้ใช้
// - แก้ไข description ได้ (ช่องเดียวที่แก้ได้)
// - ปัดการ์ดสมาชิกไปทางซ้ายเพื่อ "เตะ" ออกจากทีม (ยกเว้นหัวปาร์ตี้)
// - ลบ Squad ทั้งอันได้จากไอคอนถังขยะ
class SquadDetailPage extends StatelessWidget {
  const SquadDetailPage({super.key});

  void _showEditDescriptionDialog(BuildContext context, Party party) {
    final controller = TextEditingController(text: party.description);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('แก้ไขคำอธิบาย', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          maxLines: 3,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white30)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ยกเลิก', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<PartyProvider>().updateDescription(controller.text.trim());
              Navigator.pop(context);
            },
            child: const Text('บันทึก'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteParty(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('ลบ Squad', style: TextStyle(color: Colors.white)),
        content: const Text(
          'คุณต้องการลบ Squad นี้ใช่หรือไม่? การกระทำนี้ย้อนกลับไม่ได้',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ยกเลิก', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              context.read<PartyProvider>().deleteParty();
              Navigator.pop(context);
            },
            child: const Text('ลบ'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final party = context.watch<PartyProvider>().party;

    if (party == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'คุณยังไม่ได้สร้าง Squad\nกดปุ่ม + ด้านล่างเพื่อสร้าง Squad ของคุณ',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipOval(
                child: Image.asset(
                  party.iconPath,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 60,
                    height: 60,
                    color: Colors.white12,
                    child: const Icon(Icons.videogame_asset, color: Colors.white54),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      party.game,
                      style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${party.currentMembers}/${party.maxMembers} คนใน Party',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                onPressed: () => _confirmDeleteParty(context),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Expanded(
                child: Text('Description', style: TextStyle(color: Colors.white38, fontSize: 12)),
              ),
              GestureDetector(
                onTap: () => _showEditDescriptionDialog(context, party),
                child: const Icon(Icons.edit, color: Colors.white54, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            party.description.isEmpty ? '-' : party.description,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
          const SizedBox(height: 28),
          const Text(
            'สมาชิกใน Squad',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text('ปัดการ์ดไปทางซ้ายเพื่อเตะสมาชิกออก', style: TextStyle(color: Colors.white38, fontSize: 12)),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: party.members.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final member = party.members[index];
              return Slidable(
                key: ValueKey(member.id),
                enabled: !member.isLeader,
                endActionPane: member.isLeader
                    ? null
                    : ActionPane(
                        motion: const DrawerMotion(),
                        extentRatio: 0.28,
                        children: [
                          SlidableAction(
                            onPressed: (context) => context.read<PartyProvider>().removeMember(member.id),
                            backgroundColor: Colors.redAccent,
                            foregroundColor: Colors.white,
                            icon: Icons.person_remove,
                            label: 'เตะออก',
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ],
                      ),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.white12,
                        child: Text(
                          member.name.isNotEmpty ? member.name[0].toUpperCase() : '?',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(member.name, style: const TextStyle(color: Colors.white)),
                      ),
                      if (member.isLeader)
                        const Text('หัวปาร์ตี้', style: TextStyle(color: Colors.amber, fontSize: 12)),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
