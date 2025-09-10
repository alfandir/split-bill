import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/friend.dart';
import '../models/menu_item.dart';
import '../models/extra_fee.dart';
import 'package:uuid/uuid.dart';

class StorageHelper {
  static late SharedPreferences _prefs;
  static const String _friendsKey = 'friends_v1';
  static const String _menuKey = 'menu_v1';
  static const String _feesKey = 'fees_v1';

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    // seed dummy data if empty
    if (!_prefs.containsKey(_friendsKey)) {
      final friends = [
        Friend(id: const Uuid().v4(), name: 'Anita'),
        Friend(id: const Uuid().v4(), name: 'Brenda'),
        Friend(id: const Uuid().v4(), name: 'Cindy'),
        Friend(id: const Uuid().v4(), name: 'Dian'),
      ];
      saveFriends(friends);
    }
    if (!_prefs.containsKey(_menuKey)) {
      final menu = [
        MenuItem(id: const Uuid().v4(), name: 'Nasi Goreng', price: 35000),
        MenuItem(id: const Uuid().v4(), name: 'Mie Ayam', price: 25000),
        MenuItem(id: const Uuid().v4(), name: 'Es Teh', price: 5000),
      ];
      saveMenu(menu);
    }
    if (!_prefs.containsKey(_feesKey)) {
      final fees = [
        ExtraFee(id: const Uuid().v4(), name: 'Service 5%', amount: 5, isPercentage: true),
        ExtraFee(id: const Uuid().v4(), name: 'Tax 10%', amount: 10, isPercentage: true),
      ];
      saveFees(fees);
    }
  }

  // Friends
  static List<Friend> getFriends() {
    final raw = _prefs.getString(_friendsKey);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List;
    return list.map((e) => Friend.fromJson(e)).toList();
  }

  static void saveFriends(List<Friend> items) {
    _prefs.setString(_friendsKey, jsonEncode(items.map((e) => e.toJson()).toList()));
  }

  // Menu
  static List<MenuItem> getMenu() {
    final raw = _prefs.getString(_menuKey);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List;
    return list.map((e) => MenuItem.fromJson(e)).toList();
  }

  static void saveMenu(List<MenuItem> items) {
    _prefs.setString(_menuKey, jsonEncode(items.map((e) => e.toJson()).toList()));
  }

  // Fees
  static List<ExtraFee> getFees() {
    final raw = _prefs.getString(_feesKey);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List;
    return list.map((e) => ExtraFee.fromJson(e)).toList();
  }

  static void saveFees(List<ExtraFee> items) {
    _prefs.setString(_feesKey, jsonEncode(items.map((e) => e.toJson()).toList()));
  }
}
