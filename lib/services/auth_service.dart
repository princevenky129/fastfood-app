import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class UserAccount {
  final String name;
  final String email;
  final String password;

  UserAccount({
    required this.name,
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'password': password,
      };

  factory UserAccount.fromJson(Map<String, dynamic> json) => UserAccount(
        name: json['name'] ?? '',
        email: json['email'] ?? '',
        password: json['password'] ?? '',
      );
}

class AuthService {
  static const String _keyIsLoggedIn = 'auth_is_logged_in';
  static const String _keyCurrentUser = 'auth_current_user';
  static const String _keyAccounts = 'auth_registered_accounts';

  static final AuthService instance = AuthService._internal();
  AuthService._internal();

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  Future<UserAccount?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_keyCurrentUser);
    if (jsonStr == null) return null;
    try {
      return UserAccount.fromJson(jsonDecode(jsonStr));
    } catch (_) {
      return null;
    }
  }

  Future<List<UserAccount>> _getAccounts() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_keyAccounts) ?? [];
    return jsonList
        .map((str) {
          try {
            return UserAccount.fromJson(jsonDecode(str));
          } catch (_) {
            return null;
          }
        })
        .whereType<UserAccount>()
        .toList();
  }

  Future<void> _saveAccounts(List<UserAccount> accounts) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = accounts.map((acc) => jsonEncode(acc.toJson())).toList();
    await prefs.setStringList(_keyAccounts, jsonList);
  }

  Future<String?> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    final cleanEmail = email.trim().toLowerCase();
    if (cleanEmail.isEmpty || password.trim().isEmpty || name.trim().isEmpty) {
      return 'Please fill in all fields.';
    }
    if (password.length < 4) {
      return 'Password must be at least 4 characters long.';
    }

    final accounts = await _getAccounts();
    if (accounts.any((acc) => acc.email.toLowerCase() == cleanEmail)) {
      return 'An account with this email already exists. Please login.';
    }

    final newAcc = UserAccount(
      name: name.trim(),
      email: cleanEmail,
      password: password.trim(),
    );

    accounts.add(newAcc);
    await _saveAccounts(accounts);

    // Auto login after signup
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsLoggedIn, true);
    await prefs.setString(_keyCurrentUser, jsonEncode(newAcc.toJson()));

    return null; // Null means success
  }

  Future<String?> login({
    required String email,
    required String password,
  }) async {
    final cleanEmail = email.trim().toLowerCase();
    final cleanPass = password.trim();

    if (cleanEmail.isEmpty || cleanPass.isEmpty) {
      return 'Please enter email and password.';
    }

    final accounts = await _getAccounts();
    UserAccount? matchedAcc;

    try {
      matchedAcc = accounts.firstWhere(
        (acc) => acc.email.toLowerCase() == cleanEmail && acc.password == cleanPass,
      );
    } catch (_) {
      matchedAcc = null;
    }

    // Allow default admin account fallback for ease of first use
    if (matchedAcc == null && cleanEmail == 'admin@fastfood.com' && cleanPass == '1234') {
      matchedAcc = UserAccount(name: 'Admin', email: cleanEmail, password: cleanPass);
      accounts.add(matchedAcc);
      await _saveAccounts(accounts);
    }

    if (matchedAcc == null) {
      return 'Invalid email or password. Please check your credentials or Sign Up.';
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsLoggedIn, true);
    await prefs.setString(_keyCurrentUser, jsonEncode(matchedAcc.toJson()));

    return null; // Success
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsLoggedIn, false);
    await prefs.remove(_keyCurrentUser);
  }
}
