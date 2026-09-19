import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/party_model.dart';
import '../providers/auth_provider.dart';
import '../providers/party_provider.dart';
import '../widgets/party_card.dart';
import 'profile_page.dart';

// แท็บแรก (Home): ทักทายผู้ใช้ + "Squad ของฉัน" + "Squad ที่เปิดรับ" ของคนอื่น
// onViewSquad: แตะการ์ดแล้วพาไปแท็บ Squad detail พร้อม partyId
class HomeTabPage extends StatelessWidget {
  final void Function(String partyId) onViewSquad;
  const HomeTabPage({super.key, required this.onViewSquad});

  @override
  Widget build(BuildContext context) {
    final partyProvider = context.read<PartyProvider>();
    final authProvider = context.watch<AuthProvider>();
    final username = authProvider.username ?? '';
    final currentUid = authProvider.user?.uid;

    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const ProfilePage()),
                    ),
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white12,
                      child: Text(
                        username.isNotEmpty ? username[0].toUpperCase() : '?',
                        style: const TextStyle(color: Colors.white, fontSize: 32),
                      ),
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
          ),

          _SectionTitle('Squad ของฉัน'),
          StreamBuilder<Party?>(
            stream: partyProvider.myHostedParty,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (snapshot.hasError) {
                return const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Text('โหลด Squad ไม่สำเร็จ', style: TextStyle(color: Colors.redAccent)),
                );
              }
              final party = snapshot.data;
              if (party == null) {
                return const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'ยังไม่มี Squad กดปุ่ม + ด้านล่างเพื่อสร้าง Squad แรกของคุณ',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white38),
                  ),
                );
              }
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 1,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    mainAxisExtent: 120,
                  ),
                  itemBuilder: (context, index) => PartyCard(
                    party: party,
                    onTap: () => onViewSquad(party.id),
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 24),
          _SectionTitle('Squad ที่เปิดรับ'),
          StreamBuilder<List<Party>>(
            stream: partyProvider.allOpenParties,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (snapshot.hasError) {
                return const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Text('โหลด Squad ไม่สำเร็จ', style: TextStyle(color: Colors.redAccent)),
                );
              }
              // ตัด squad ของตัวเองออก จะได้ไม่ซ้ำกับ section บน
              final parties = (snapshot.data ?? []).where((p) => p.hostId != currentUid).toList();
              if (parties.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'ยังไม่มี Squad ที่เปิดรับตอนนี้',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white38),
                  ),
                );
              }
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
            },
          ),
          const SizedBox(height: 40), // กันปุ่ม + ลอยทับ card ล่างสุด
        ],
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
          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
