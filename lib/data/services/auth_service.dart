import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AuthService {
  static const _kUsersKey = 'registered_users';
  static const _kIsFirstTimeKey = 'isFirstTime';
  static const _kIsLoggedInKey = 'isLoggedIn';
  static const _kCurrentUserKey = 'currentUser';

  // ---------- Onboarding flag ----------

  Future<bool> getIsFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kIsFirstTimeKey) ?? true;
  }

  Future<void> setIsFirstTime(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kIsFirstTimeKey, value);
  }

  // ---------- Session state ----------

  Future<bool> getIsLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kIsLoggedInKey) ?? false;
  }

  Future<void> setIsLoggedIn(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kIsLoggedInKey, value);
  }

  Future<UserModel?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_kCurrentUserKey);
    if (jsonStr == null) return null;
    return UserModel.fromJson(jsonDecode(jsonStr));
  }

  Future<void> setCurrentUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kCurrentUserKey, jsonEncode(user.toJson()));
  }

  // ---------- Registered users list ----------

  Future<List<UserModel>> _getRegisteredUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_kUsersKey);
    if (jsonStr == null) return [];
    final List<dynamic> decoded = jsonDecode(jsonStr);
    return decoded.map((e) => UserModel.fromJson(e)).toList();
  }

  Future<void> _saveRegisteredUsers(List<UserModel> users) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(users.map((u) => u.toJson()).toList());
    await prefs.setString(_kUsersKey, encoded);
  }

  Future<bool> isUsernameTaken(String username) async {
    final users = await _getRegisteredUsers();
    return users.any(
      (u) => u.username.toLowerCase() == username.toLowerCase(),
    );
  }

  Future<void> registerUser(UserModel newUser) async {
    final users = await _getRegisteredUsers();
    users.add(newUser);
    await _saveRegisteredUsers(users);
  }

  Future<UserModel?> authenticate(String identifier, String password) async {
    final users = await _getRegisteredUsers();
    for (final user in users) {
      if (user.matchesIdentifier(identifier) && user.password == password) {
        return user;
      }
    }
    return null;
  }

  // ---------- Logout ----------

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kCurrentUserKey);
    await prefs.setBool(_kIsLoggedInKey, false);
  }

  // ---------- Purchase history ----------

  String _purchaseKey(String username) => 'purchased_items_$username';

  Future<List<String>> getPurchasedItemNames(String username) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_purchaseKey(username));
    if (jsonStr == null) return [];
    final List<dynamic> decoded = jsonDecode(jsonStr);
    return decoded.map((e) => e.toString()).toList();
  }

  Future<void> addPurchasedItemName(String username, String itemName) async {
    final prefs = await SharedPreferences.getInstance();
    final current = await getPurchasedItemNames(username);
    if (!current.any((n) => n.toLowerCase() == itemName.toLowerCase())) {
      current.add(itemName);
      await prefs.setString(_purchaseKey(username), jsonEncode(current));
    }
  }

  Future<void> removePurchasedItemName(String username, String itemName) async {
    final prefs = await SharedPreferences.getInstance();
    final current = await getPurchasedItemNames(username);
    current.removeWhere((n) => n.toLowerCase() == itemName.toLowerCase());
    await prefs.setString(_purchaseKey(username), jsonEncode(current));
  }
}