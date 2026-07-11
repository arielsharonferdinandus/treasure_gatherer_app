import 'package:flutter/material.dart';
import '../data/models/user_model.dart';
import '../data/services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool isFirstTime = true;
  bool isLoggedIn = false;
  UserModel? currentUser;

  bool isLoading = false;
  String? errorMessage;

  List<String> purchasedItemNames = [];

  Future<void> loadInitialState() async {
    isFirstTime = await _authService.getIsFirstTime();
    isLoggedIn = await _authService.getIsLoggedIn();
    if (isLoggedIn) {
      currentUser = await _authService.getCurrentUser();
      if (currentUser != null) {
        purchasedItemNames =
            await _authService.getPurchasedItemNames(currentUser!.username);
      }
    }
    notifyListeners();
  }

  Future<void> completeOnboarding() async {
    await _authService.setIsFirstTime(false);
    isFirstTime = false;
    notifyListeners();
  }

  Future<bool> login(String identifier, String password) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    final user = await _authService.authenticate(identifier, password);

    if (user != null) {
      currentUser = user;
      isLoggedIn = true;
      await _authService.setIsLoggedIn(true);
      await _authService.setCurrentUser(user);
      purchasedItemNames = await _authService.getPurchasedItemNames(user.username);
      isLoading = false;
      notifyListeners();
      return true;
    } else {
      errorMessage = "Email/Username atau Password salah";
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String username,
    required String email,
    required String phone,
    required String password,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    final usernameTaken = await _authService.isUsernameTaken(username);
    if (usernameTaken) {
      errorMessage = "Username sudah terdaftar. Silakan gunakan username lain.";
      isLoading = false;
      notifyListeners();
      return false;
    }

    final newUser = UserModel(
      username: username,
      email: email,
      phone: phone,
      password: password,
    );

    await _authService.registerUser(newUser);
    isLoading = false;
    notifyListeners();
    return true;
  }

  Future<void> logout() async {
    currentUser = null;
    isLoggedIn = false;
    purchasedItemNames = [];
    await _authService.setIsLoggedIn(false);
    notifyListeners();
  }

  // ---------- Purchase history ----------

  bool hasPurchasedByName(String name) {
    if (name.trim().isEmpty) return false;
    return purchasedItemNames.any((n) => n.toLowerCase() == name.trim().toLowerCase());
  }

  Future<void> recordPurchase(String itemName) async {
    if (currentUser == null) return;
    await _authService.addPurchasedItemName(currentUser!.username, itemName);
    if (!hasPurchasedByName(itemName)) {
      purchasedItemNames.add(itemName);
      notifyListeners();
    }
  }

  Future<void> consumePurchaseByName(String itemName) async {
    if (currentUser == null) return;
    await _authService.removePurchasedItemName(currentUser!.username, itemName);
    purchasedItemNames.removeWhere((n) => n.toLowerCase() == itemName.toLowerCase());
    notifyListeners();
  }
}