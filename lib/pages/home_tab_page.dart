import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/party_provider.dart';
import '../widgets/party_card.dart';

// แท็บแรก (หน้า Home) แสดง Squad ที่ผู้ใช้สร้างไว้แบบย่อ ในรูปแบบการ์ด
// onViewSquad: เรียกเมื่อผู้ใช้แตะการ์ด เพื่อพาไปหน้ารายละเอียด Squad (แท็บที่ 2)
class HomeTabPage extends StatelessWidget {
  final VoidCallback onViewSquad;
  const HomeTabPage({super.key, required this.onViewSquad});

  @override
  Widget build(BuildContext context) {
    final parties = context.watch<PartyProvider>().parties;

    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircleAvatar(
                    radius: 50,
                    backgroundImage: AssetImage(''),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Hello',
                    style: TextStyle(fontSize: 30, color: Colors.white),
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

          // Squad ที่สร้างไว้ (มีได้สูงสุด 1 ใบ)
          if (parties.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'ยังไม่มี Squad กดปุ่ม + ด้านล่างเพื่อสร้าง Squad แรกของคุณ',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white38),
              ),
            )
          else
            Padding(
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
                  onTap: onViewSquad,
                ),
              ),
            ),
          const SizedBox(height: 40), // กันปุ่ม + ลอยทับ card ล่างสุด
        ],
      ),
    );
  }
}
