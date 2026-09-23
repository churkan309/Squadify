import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/game_catalog.dart';
import '../models/party_model.dart';
import '../providers/auth_provider.dart';
import '../providers/party_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/async_stream_section.dart';
import '../widgets/party_card.dart';
import 'profile_page.dart';

// แท็บแรก (Home): ทักทายผู้ใช้ + "Squad ของฉัน" + "Squad ที่เปิดรับ" ของคนอื่น
// onViewSquad: แตะการ์ดแล้วพาไปแท็บ Squad detail พร้อม partyId
class HomeTabPage extends StatefulWidget {
  final void Function(String partyId) onViewSquad;
  const HomeTabPage({super.key, required this.onViewSquad});

  @override
  State<HomeTabPage> createState() => _HomeTabPageState();
}

class _HomeTabPageState extends State<HomeTabPage> {
  String? _selectedGame;

  List<Party> _filterPartiesByGame(List<Party> parties) {
    final selectedGame = _selectedGame;
    if (selectedGame == null) return parties;
    return parties.where((party) => party.game == selectedGame).toList();
  }

  @override
  Widget build(BuildContext context) {
    final partyProvider = context.read<PartyProvider>();
    final authProvider = context.watch<AuthProvider>();
    final username = authProvider.username ?? '';
    final currentUid = authProvider.user?.uid;

    return SingleChildScrollView(
      child: Column(
        children: [
          FutureBuilder<String>(
            future: authProvider.currentUsername(),
            builder: (context, snapshot) =>
                _ProfileHeader(username: snapshot.data ?? username),
          ),

          const _SectionTitle('Squad ของฉัน'),
          AsyncStreamSection<Party?>(
            stream: partyProvider.myCurrentParty,
            emptyMessage:
                'ยังไม่มี Squad กดปุ่ม + ด้านล่างเพื่อสร้าง Squad แรกของคุณ',
            errorMessage: 'โหลด Squad ไม่สำเร็จ',
            builder: (context, party) =>
                PartyGrid(parties: [party!], onViewSquad: widget.onViewSquad),
          ),

          const SizedBox(height: 24),
          const _SectionTitle('Squad ที่เปิดรับ'),
          SizedBox(
            height: 42,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              scrollDirection: Axis.horizontal,
              itemCount: gameCatalog.length + 1,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final game = index == 0
                    ? null
                    : gameCatalog.keys.elementAt(index - 1);
                return FilterChip(
                  label: Text(
                    game ?? 'All',
                    style: TextStyle(
                      color: _selectedGame == game
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  selected: _selectedGame == game,
                  backgroundColor: AppColors.surface,
                  selectedColor: AppColors.appBar,
                  checkmarkColor: AppColors.textPrimary,
                  side: BorderSide(
                    color: _selectedGame == game
                        ? AppColors.appBar
                        : AppColors.border,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  onSelected: (_) => setState(() => _selectedGame = game),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          AsyncStreamSection<List<Party>>(
            // ตัด squad ของตัวเองออก จะได้ไม่ซ้ำกับ section บน
            stream: partyProvider.allOpenParties.map(
              (parties) => _filterPartiesByGame(
                parties.where((p) => p.hostId != currentUid).toList(),
              ),
            ),
            isEmpty: (parties) => parties.isEmpty,
            emptyMessage: 'ยังไม่มี Squad ที่เปิดรับตอนนี้',
            errorMessage: 'โหลด Squad ไม่สำเร็จ',
            builder: (context, parties) =>
                PartyGrid(parties: parties, onViewSquad: widget.onViewSquad),
          ),
          const SizedBox(height: 40), // กันปุ่ม + ลอยทับ card ล่างสุด
        ],
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final String username;
  const _ProfileHeader({required this.username});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const ProfilePage()),
              ),
              child: Icon(
                Icons.account_circle,
                size: 150,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              username.isEmpty ? 'Hello' : 'Hello, $username',
              style: const TextStyle(fontSize: 30, color: Colors.white),
            ),
            const Text(
              'Which squad you want to LOCK IN ?',
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
