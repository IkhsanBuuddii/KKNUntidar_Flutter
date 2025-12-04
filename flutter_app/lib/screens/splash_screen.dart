import 'package:flutter/material.dart';
import '../services/prefs_service.dart';
import '../theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _check();
  }

  void _check() async {
    await Future.delayed(const Duration(seconds: 1));
    final logged = await PrefsService.isLoggedIn();
    if (logged) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      Navigator.pushReplacementNamed(context, '/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.light.scaffoldBackgroundColor,
      body: const Center(child: CircularProgressIndicator()),
    );
  }
}
