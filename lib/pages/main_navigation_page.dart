import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/party_model.dart';
import '../providers/party_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/app_dialog.dart';
import '../widgets/create_party_dialog.dart';
import 'community_page.dart';
import 'home_tab_page.dart';
import 'settings_page.dart';
import 'squad_detail_page.dart';

// หน้าหลักของแอพ: คุม AppBar, bottom nav bar 4 ปุ่ม และปุ่ม + สร้าง Squad
// _selectedIndex: 0 = หน้าแรก, 1 = Squad detail, 2 = ชุมชน, 3 = ตั้งค่า
// _selectedPartyId: squad ที่กำลังดูอยู่ในแท็บ Squad detail
//   (null = ยังไม่เลือก -> fallback ไปดู squad ของตัวเอง ดู SquadDetailPageResolver)
class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _selectedIndex = 0;
  String? _selectedPartyId;

  // แตะการ์ด squad (ของตัวเองหรือของคนอื่น) แล้วพาไปแท็บ detail พร้อม partyId
  void _onViewSquad(String partyId) {
    setState(() {
      _selectedPartyId = partyId;
      _selectedIndex = 1;
    });
  }

  Widget _getSelectedPage() {
    switch (_selectedIndex) {
      case 0:
        return HomeTabPage(onViewSquad: _onViewSquad);
      case 1:
        return SquadDetailPageResolver(
          selectedPartyId: _selectedPartyId,
          onViewSquad: _onViewSquad,
        );
      case 2:
        return StreamBuilder<Party?>(
          stream: context.read<PartyProvider>().myCurrentParty,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final party = snapshot.data;
            if (party == null) {
              return const Center(
                child: Text('ต้องอยู่ใน Party ก่อนจึงจะเข้าชุมชนได้'),
              );
            }
            return CommunityPage(partyId: party.id);
          },
        );
      case 3:
        return const SettingsPage();
      default:
        return HomeTabPage(onViewSquad: _onViewSquad);
    }
  }

  // กดปุ่ม + : เช็ก hasHostedParty จาก Firestore (ไม่ใช่ provider ใน memory)
  Future<void> _onCreateSquadPressed() async {
    final partyProvider = context.read<PartyProvider>();
    final hasParty = await partyProvider.hasHostedParty();
    final isMember = await partyProvider.isMemberOfAnyParty();
    if (!mounted) return;

    if (hasParty) {
      await showInfoDialog(
        context,
        title: 'สร้าง Squad ใหม่ไม่ได้',
        message:
            'คุณสร้าง Squad ไปแล้ว กรุณาลบ Squad เก่าก่อน ถึงจะสร้างใหม่ได้',
      );
      return;
    }
    if (isMember) {
      await showInfoDialog(
        context,
        title: 'สร้าง Squad ใหม่ไม่ได้',
        message: 'คุณอยู่ใน Squad ของคนอื่นอยู่ กรุณาออกก่อน ถึงจะสร้างใหม่ได้',
      );
      return;
    }

    showCreatePartyDialog(
      context,
      onCreated: (partyId) =>
          _onViewSquad(partyId), // สร้างเสร็จ พาไปหน้า detail ทันที
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Squadify',
          style: TextStyle(
            color: Color.fromARGB(255, 192, 190, 190),
            fontWeight: FontWeight.w900,
            fontSize: 30,
          ),
        ),
        backgroundColor: AppColors.appBar,
      ),
      body: _getSelectedPage(),
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        onPressed: _onCreateSquadPressed,
        backgroundColor: const Color.fromARGB(237, 236, 238, 237),
        child: const Icon(Icons.add, color: Colors.black),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        color: AppColors.appBar,
        child: SizedBox(
          height: 20,
          child: Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                IconButton(
                  icon: const Icon(Icons.home),
                  color: _selectedIndex == 0 ? Colors.white : Colors.white54,
                  onPressed: () => setState(() => _selectedIndex = 0),
                ),
                IconButton(
                  icon: const Icon(Icons.group),
                  color: _selectedIndex == 1 ? Colors.white : Colors.white54,
                  onPressed: () => setState(() {
                    _selectedPartyId =
                        null; // แตะแท็บตรงๆ กลับไปดู squad ของตัวเอง
                    _selectedIndex = 1;
                  }),
                ),
                const SizedBox(width: 48), // เว้นที่ให้ FAB ตรงกลาง
                IconButton(
                  icon: const Icon(Icons.forum),
                  color: _selectedIndex == 2 ? Colors.white : Colors.white54,
                  onPressed: () => setState(() => _selectedIndex = 2),
                ),
                IconButton(
                  icon: const Icon(Icons.settings),
                  color: _selectedIndex == 3 ? Colors.white : Colors.white54,
                  onPressed: () => setState(() => _selectedIndex = 3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
