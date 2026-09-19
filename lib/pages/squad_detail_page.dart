import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';

import '../models/party_model.dart';
import '../providers/party_provider.dart';

// ตัวช่วยเลือกว่าจะแสดง squad ไหนในแท็บ "Squad detail":
// ถ้ามี selectedPartyId (แตะการ์ดมา) ใช้ตัวนั้น
// ถ้า null (แตะแท็บตรงๆ) fallback ไปดู squad ที่ตัวเองเป็นหัวปาร์ตี้
class SquadDetailPageResolver extends StatelessWidget {
  final String? selectedPartyId;
  final void Function(String partyId) onViewSquad;

  const SquadDetailPageResolver({
    super.key,
    required this.selectedPartyId,
    required this.onViewSquad,
  });

  @override
  Widget build(BuildContext context) {
    if (selectedPartyId != null) {
      return SquadDetailPage(partyId: selectedPartyId!);
    }

    return StreamBuilder<Party?>(
      stream: context.read<PartyProvider>().myHostedParty,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final party = snapshot.data;
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
        return SquadDetailPage(partyId: party.id);
      },
    );
  }
}

// หน้าขยายรายละเอียด Squad หนึ่งใบ ดูได้ทั้ง squad ตัวเองและของคนอื่น
// - host: แก้ description, ลบ squad, ปัด slidable เตะสมาชิก
// - ไม่ใช่ host: ปุ่ม "เข้าร่วม/ออกจาก Squad" ตามสถานะ + disable เมื่อเต็ม
class SquadDetailPage extends StatelessWidget {
  final String partyId;
  const SquadDetailPage({super.key, required this.partyId});

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;
  String get _displayName => FirebaseAuth.instance.currentUser?.displayName ?? 'ผู้เล่น';

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
              context.read<PartyProvider>().updateDescription(party.id, controller.text.trim());
              Navigator.pop(context);
            },
            child: const Text('บันทึก'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteParty(BuildContext context, String partyId) {
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
            onPressed: () async {
              final navigator = Navigator.of(context);
              await context.read<PartyProvider>().deleteParty(partyId);
              navigator.pop();
            },
            child: const Text('ลบ'),
          ),
        ],
      ),
    );
  }

  Future<void> _joinParty(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final error = await context.read<PartyProvider>().joinParty(partyId, name: _displayName);
    if (error != null) {
      messenger.showSnackBar(SnackBar(content: Text(error)));
    }
  }

  Future<void> _leaveParty(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final error = await context.read<PartyProvider>().leaveParty(partyId);
    if (error != null) {
      messenger.showSnackBar(SnackBar(content: Text(error)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final partyProvider = context.read<PartyProvider>();

    return StreamBuilder<Party?>(
      stream: partyProvider.partyById(partyId),
      builder: (context, partySnapshot) {
        if (partySnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final party = partySnapshot.data;
        if (party == null) {
          return const Center(
            child: Text('ไม่พบ Squad นี้', style: TextStyle(color: Colors.white70)),
          );
        }

        final isHost = party.hostId == _uid;

        return StreamBuilder<List<SquadMember>>(
          stream: partyProvider.membersOf(partyId),
          builder: (context, membersSnapshot) {
            final members = membersSnapshot.data ?? [];
            final isMember = members.any((m) => m.uid == _uid);
            final isFull = party.memberCount >= party.maxMembers;

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
                              '${party.memberCount}/${party.maxMembers} คนใน Party · หัวปาร์ตี้ ${party.hostName}',
                              style: const TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                      if (isHost)
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                          onPressed: () => _confirmDeleteParty(context, partyId),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Expanded(
                        child: Text('Description', style: TextStyle(color: Colors.white38, fontSize: 12)),
                      ),
                      if (isHost)
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
                  const SizedBox(height: 20),
                  if (!isHost)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              isMember ? Colors.redAccent : (isFull ? Colors.white24 : Colors.lightBlue[100]),
                        ),
                        onPressed: isMember
                            ? () => _leaveParty(context)
                            : (isFull ? null : () => _joinParty(context)),
                        child: Text(isMember ? 'ออกจาก Squad' : (isFull ? 'เต็มแล้ว' : 'เข้าร่วม Squad')),
                      ),
                    ),
                  const SizedBox(height: 28),
                  const Text(
                    'สมาชิกใน Squad',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  if (isHost) ...[
                    const SizedBox(height: 4),
                    const Text('ปัดการ์ดไปทางซ้ายเพื่อเตะสมาชิกออก', style: TextStyle(color: Colors.white38, fontSize: 12)),
                  ],
                  const SizedBox(height: 12),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: members.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final member = members[index];
                      final canKick = isHost && !member.isLeader;
                      return Slidable(
                        key: ValueKey(member.uid),
                        enabled: canKick,
                        endActionPane: !canKick
                            ? null
                            : ActionPane(
                                motion: const DrawerMotion(),
                                extentRatio: 0.28,
                                children: [
                                  SlidableAction(
                                    onPressed: (context) =>
                                        context.read<PartyProvider>().removeMember(partyId, member.uid),
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
                                backgroundImage:
                                    member.avatarUrl.isNotEmpty ? NetworkImage(member.avatarUrl) : null,
                                child: member.avatarUrl.isEmpty
                                    ? Text(
                                        member.name.isNotEmpty ? member.name[0].toUpperCase() : '?',
                                        style: const TextStyle(color: Colors.white),
                                      )
                                    : null,
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
          },
        );
      },
    );
  }
}
