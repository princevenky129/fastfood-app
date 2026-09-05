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

  // Exclusive single Owner / Admin account
  static const String adminEmail = 'venkyvenkyy129@gmail.com';
  static const String adminPassword = 'Venky@129';
  static const String adminName = 'Venkatesh (Owner)';

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

  Future<String?> login({
    required String email,
    required String password,
  }) async {
    final cleanEmail = email.trim().toLowerCase();
    final cleanPass = password.trim();

    if (cleanEmail.isEmpty || cleanPass.isEmpty) {
      return 'Please enter your Admin email and password.';
    }

    if (cleanEmail == adminEmail.toLowerCase() && cleanPass == adminPassword) {
      final adminAccount = UserAccount(
        name: adminName,
        email: adminEmail,
        password: adminPassword,
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyIsLoggedIn, true);
      await prefs.setString(_keyCurrentUser, jsonEncode(adminAccount.toJson()));

      return null; // Login Success
    }

    return 'Unauthorized: Invalid Admin credentials.';
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsLoggedIn, false);
    await prefs.remove(_keyCurrentUser);
  }
}
