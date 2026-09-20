import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../models/party_model.dart';
import '../theme/app_colors.dart';

// การ์ดสมาชิกหนึ่งคนในหน้า squad detail — ปัดซ้ายเตะออกได้ถ้า canKick
// แยกออกมาจาก squad_detail_page.dart เพื่อให้ ListView.separated ในหน้านั้นอ่านง่ายขึ้น
class SquadMemberTile extends StatelessWidget {
  final SquadMember member;
  final bool canKick;
  final VoidCallback onKick;

  const SquadMemberTile({
    super.key,
    required this.member,
    required this.canKick,
    required this.onKick,
  });

  @override
  Widget build(BuildContext context) {
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
                  onPressed: (_) => onKick(),
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
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.white12,
              backgroundImage: member.avatarUrl.isNotEmpty ? NetworkImage(member.avatarUrl) : null,
              child: member.avatarUrl.isEmpty
                  ? Text(
                      member.name.isNotEmpty ? member.name[0].toUpperCase() : '?',
                      style: const TextStyle(color: Colors.white),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(member.name, style: const TextStyle(color: Colors.white))),
            if (member.isLeader)
              const Text('หัวปาร์ตี้', style: TextStyle(color: Colors.amber, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
