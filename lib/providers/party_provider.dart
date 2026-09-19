import 'package:flutter/material.dart';
import '../models/party_model.dart';

// เก็บสถานะ Squad ของผู้ใช้ทั้งแอพ (global state ผ่าน package provider)
// กติกา: สร้างได้ทีละ 1 Squad เท่านั้น ถ้าจะสร้างใหม่ต้องลบอันเก่าก่อน
class PartyProvider extends ChangeNotifier {
  Party? _party;

  Party? get party => _party;
  bool get hasParty => _party != null;

  // เก็บไว้ให้หน้า Home ใช้ GridView.builder แบบเดิมได้ (จะมีได้แค่ 0 หรือ 1 ใบ)
  List<Party> get parties => _party == null ? [] : [_party!];

  // คืนค่า true ถ้าสร้างสำเร็จ, false ถ้ามี Squad อยู่แล้ว (ห้ามสร้างซ้ำ)
  bool addParty(Party party) {
    if (_party != null) return false;
    _party = party;
    notifyListeners();
    return true;
  }

  // ผู้ใช้แก้ไขได้แค่ description เท่านั้น
  void updateDescription(String newDescription) {
    if (_party == null) return;
    _party!.description = newDescription;
    notifyListeners();
  }

  void addMember(SquadMember member) {
    if (_party == null) return;
    if (_party!.members.length >= _party!.maxMembers) return;
    _party!.members.add(member);
    notifyListeners();
  }

  void removeMember(String memberId) {
    if (_party == null) return;
    _party!.members.removeWhere((m) => m.id == memberId);
    notifyListeners();
  }

  void deleteParty() {
    _party = null;
    notifyListeners();
  }
}
