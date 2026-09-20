import 'package:flutter/material.dart';
import '../models/party_model.dart';
import '../theme/app_colors.dart';
import 'game_icon_avatar.dart';

class PartyCard extends StatelessWidget {
  final Party party;
  final VoidCallback? onTap; // แตะการ์ดแล้วพาไปหน้า Squad detail

  const PartyCard({super.key, required this.party, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                GameIconAvatar(iconPath: party.iconPath, size: 44),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        party.game,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '(${party.memberCount}/${party.maxMembers}) คนใน Party',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white70, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              party.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

// grid 2 คอลัมน์ของ PartyCard — ก่อนหน้านี้ home_tab_page.dart มี GridView.builder
// แบบนี้ copy อยู่ 2 จุด (squad ของฉัน / squad ที่เปิดรับ) ต่างกันแค่ list ที่ส่งเข้ามา
class PartyGrid extends StatelessWidget {
  final List<Party> parties;
  final void Function(String partyId) onViewSquad;

  const PartyGrid({super.key, required this.parties, required this.onViewSquad});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: parties.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          mainAxisExtent: 120,
        ),
        itemBuilder: (context, index) => PartyCard(
          party: parties[index],
          onTap: () => onViewSquad(parties[index].id),
        ),
      ),
    );
  }
}
