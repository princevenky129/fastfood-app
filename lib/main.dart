import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'screens/admin/admin_home.dart';
import 'screens/auth/auth_screen.dart';
import 'screens/customer/customer_home.dart';
import 'services/auth_service.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const FastFoodApp());
}

class FastFoodApp extends StatefulWidget {
  const FastFoodApp({super.key});

  @override
  State<FastFoodApp> createState() => _FastFoodAppState();
}

class _FastFoodAppState extends State<FastFoodApp> {
  bool _isLoggedIn = false;
  bool _isCheckingAuth = true;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    if (kIsWeb) {
      // On web (Vercel deployment), customers directly browse menu and order
      setState(() {
        _isLoggedIn = true;
        _isCheckingAuth = false;
      });
      return;
    }

    final loggedIn = await AuthService.instance.isLoggedIn();
    setState(() {
      _isLoggedIn = loggedIn;
      _isCheckingAuth = false;
    });
  }

  Future<void> _handleLogout() async {
    await AuthService.instance.logout();
    setState(() {
      _isLoggedIn = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FastFood',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: _isCheckingAuth
          ? const Scaffold(
              backgroundColor: Color(0xFF0F0F13),
              body: Center(
                child: CircularProgressIndicator(color: Color(0xFFFF6B00)),
              ),
            )
          : kIsWeb
              ? const CustomerHome(
                  key: ValueKey('CustomerHomeWeb'),
                )
              : !_isLoggedIn
                  ? AuthScreen(
                      onLoginSuccess: () => setState(() => _isLoggedIn = true),
                    )
                  : AdminHome(
                      key: const ValueKey('AdminHome'),
                      onLogout: _handleLogout,
                    ),
    );
  }
}
