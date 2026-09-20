import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/party_model.dart';
import '../providers/party_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/app_dialog.dart';
import '../widgets/game_icon_avatar.dart';
import '../widgets/squad_member_tile.dart';

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
  String get _displayName =>
      FirebaseAuth.instance.currentUser?.displayName ?? 'ผู้เล่น';

  void _showEditDescriptionDialog(BuildContext context, Party party) {
    final controller = TextEditingController(text: party.description);
    showDialog(
      context: context,
      builder: (context) => AppAlertDialog(
        title: 'แก้ไขคำอธิบาย',
        content: TextField(
          controller: controller,
          maxLines: 3,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white30),
            ),
          ),
        ),
        actions: [
          const AppCancelButton(),
          ElevatedButton(
            onPressed: () {
              context.read<PartyProvider>().updateDescription(
                party.id,
                controller.text.trim(),
              );
              Navigator.pop(context);
            },
            child: const Text('บันทึก'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteParty(BuildContext context, String partyId) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'ลบ Squad',
      message: 'คุณต้องการลบ Squad นี้ใช่หรือไม่? การกระทำนี้ย้อนกลับไม่ได้',
      confirmLabel: 'ลบ',
      confirmColor: Colors.redAccent,
    );
    if (!confirmed || !context.mounted) return;
    await context.read<PartyProvider>().deleteParty(partyId);
  }

  Future<void> _joinParty(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final error = await context.read<PartyProvider>().joinParty(
      partyId,
      name: _displayName,
    );
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
            child: Text(
              'ไม่พบ Squad นี้',
              style: TextStyle(color: Colors.white70),
            ),
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
                  _SquadHeader(
                    party: party,
                    isHost: isHost,
                    onDelete: () => _confirmDeleteParty(context, partyId),
                  ),
                  const SizedBox(height: 20),
                  _DescriptionSection(
                    party: party,
                    isHost: isHost,
                    onEdit: () => _showEditDescriptionDialog(context, party),
                  ),
                  const SizedBox(height: 20),
                  if (!isHost)
                    StreamBuilder<Party?>(
                      stream: partyProvider.myHostedParty,
                      builder: (context, hostedSnap) {
                        final hostsAnother = hostedSnap.data != null;
                        return _JoinLeaveButton(
                          isMember: isMember,
                          isFull: isFull,
                          hostsAnother: hostsAnother,
                          onJoin: () => _joinParty(context),
                          onLeave: () => _leaveParty(context),
                        );
                      },
                    ),
                  const SizedBox(height: 28),
                  const Text(
                    'สมาชิกใน Squad',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (isHost) ...[
                    const SizedBox(height: 4),
                    const Text(
                      'ปัดการ์ดไปทางซ้ายเพื่อเตะสมาชิกออก',
                      style: TextStyle(color: Colors.white38, fontSize: 12),
                    ),
                  ],
                  const SizedBox(height: 12),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: members.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final member = members[index];
                      return SquadMemberTile(
                        member: member,
                        canKick: isHost && !member.isLeader,
                        onKick: () => context
                            .read<PartyProvider>()
                            .removeMember(partyId, member.uid),
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

// หัวการ์ด: ไอคอนเกม + ชื่อเกม + จำนวนสมาชิก + ปุ่มลบ (host เท่านั้น)
class _SquadHeader extends StatelessWidget {
  final Party party;
  final bool isHost;
  final VoidCallback onDelete;

  const _SquadHeader({
    required this.party,
    required this.isHost,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GameIconAvatar(iconPath: party.iconPath, size: 60),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                party.game,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
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
            onPressed: onDelete,
          ),
      ],
    );
  }
}

// ส่วน description พร้อมไอคอนดินสอแก้ไข (host เท่านั้น)
class _DescriptionSection extends StatelessWidget {
  final Party party;
  final bool isHost;
  final VoidCallback onEdit;

  const _DescriptionSection({
    required this.party,
    required this.isHost,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Description',
                style: TextStyle(color: Colors.white38, fontSize: 12),
              ),
            ),
            if (isHost)
              GestureDetector(
                onTap: onEdit,
                child: const Icon(Icons.edit, color: Colors.white54, size: 18),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          party.description.isEmpty ? '-' : party.description,
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
      ],
    );
  }
}

// ปุ่มเข้าร่วม/ออกจาก Squad ของผู้ใช้ที่ไม่ใช่ host — เปลี่ยนสี/ข้อความตามสถานะ
class _JoinLeaveButton extends StatelessWidget {
  final bool isMember;
  final bool isFull;
  final bool hostsAnother;
  final VoidCallback onJoin;
  final VoidCallback onLeave;

  const _JoinLeaveButton({
    required this.isMember,
    required this.isFull,
    required this.hostsAnother,
    required this.onJoin,
    required this.onLeave,
  });

  @override
  Widget build(BuildContext context) {
    final blocked = !isMember && (isFull || hostsAnother);
    final label = isMember
        ? 'ออกจาก Squad'
        : hostsAnother
        ? 'คุณเป็นหัวปาร์ตี้แล้ว'
        : (isFull ? 'เต็มแล้ว' : 'เข้าร่วม Squad');

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isMember
              ? Colors.redAccent
              : (blocked ? Colors.white24 : AppColors.primaryButton),
        ),
        onPressed: isMember ? onLeave : (blocked ? null : onJoin),
        child: Text(label),
      ),
    );
  }
}
