import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/party_provider.dart';
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
  final GlobalKey _bellKey = GlobalKey(); // ใช้หาตำแหน่งกระดิ่งบนจอ เพื่อเด้ง popup ออกจากจุดนั้น

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
        return const CommunityPage();
      case 3:
        return const SettingsPage();
      default:
        return HomeTabPage(onViewSquad: _onViewSquad);
    }
  }

  // เด้ง dialog แจ้งเตือนออกมาจากตำแหน่งกระดิ่ง (ใช้ showMenu) แทนที่จะขึ้นกลางจอ
  void _showNotificationDropdown() {
    final renderBox = _bellKey.currentContext!.findRenderObject() as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    showMenu(
      context: context,
      color: const Color(0xFF1B3A2E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      position: RelativeRect.fromLTRB(
        offset.dx - 180, // เลื่อนซ้ายหน่อยกันล้นขอบจอขวา
        offset.dy + size.height,
        offset.dx + size.width,
        0,
      ),
      items: const [
        PopupMenuItem(
          enabled: false,
          child: Text('ยังไม่มีการแจ้งเตือนใหม่', style: TextStyle(color: Colors.white70)),
        ),
      ],
    );
    // ทำกระดิ่งแจ้งเตือนจริง: สร้าง Firestore collection 'notifications'
    // (แนะนำ: subcollection users/{uid}/notifications) แล้วฟังด้วย
    // StreamBuilder ตรงนี้แทน PopupMenuItem คงที่ด้านบน — trigger เพิ่ม doc ใหม่
    // ตอน join/leave/remove เกิดขึ้นกับ squad ของ uid นั้นๆ
  }

  // กดปุ่ม + : เช็ก hasHostedParty จาก Firestore (ไม่ใช่ provider ใน memory)
  Future<void> _onCreateSquadPressed() async {
    final partyProvider = context.read<PartyProvider>();
    final hasParty = await partyProvider.hasHostedParty();
    if (!mounted) return;

    if (hasParty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('สร้าง Squad ใหม่ไม่ได้', style: TextStyle(color: Colors.white)),
          content: const Text(
            'คุณสร้าง Squad ไปแล้ว กรุณาลบ Squad เก่าก่อน ถึงจะสร้างใหม่ได้',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('เข้าใจแล้ว', style: TextStyle(color: Colors.white70)),
            ),
          ],
        ),
      );
      return;
    }

    showCreatePartyDialog(
      context,
      onCreated: (partyId) => _onViewSquad(partyId), // สร้างเสร็จ พาไปหน้า detail ทันที
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
        backgroundColor: const Color.fromARGB(248, 25, 53, 40),
        actions: [
          IconButton(
            key: _bellKey,
            onPressed: _showNotificationDropdown,
            icon: const Icon(Icons.notifications, color: Colors.white, size: 20),
          ),
        ],
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
        color: const Color.fromARGB(248, 25, 53, 40),
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
                    _selectedPartyId = null; // แตะแท็บตรงๆ กลับไปดู squad ของตัวเอง
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
