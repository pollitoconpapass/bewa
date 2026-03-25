import 'package:flutter/material.dart';

import '../screens/auth/sign_in_screen.dart';
import '../widgets/bottom_menu.dart';
import '../services/authorizer.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isLoading = true;
  bool _isRegistered = false;

  @override
  void initState() {
    super.initState();
    _checkRegistration();
  }

  Future<void> _checkRegistration() async {
    final registered = await Authorizer.isUserRegistered();
    if (mounted) {
      setState(() {
        _isLoading = false;
        _isRegistered = registered;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return _isRegistered ? const BottomMenu() : const LoginScreen();
  }
}
