import 'package:flutter/material.dart';
import '../services/database_helper.dart';
import '../services/prefs_service.dart';
 
import '../theme.dart';

// Redesigned Login Screen using centralized theme and improved UX

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _db = DatabaseHelper.instance;

  bool _loading = false;

  void _localLogin() async {
    setState(() => _loading = true);
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text.trim();
    if (email.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mohon isi semua field')));
      setState(() => _loading = false);
      return;
    }
    final ok = await _db.checkUser(email, pass);
    if (ok) {
      final user = await _db.getUserByEmail(email);
      await PrefsService.setLogin(email, user?.fullName ?? '');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Login berhasil! Selamat datang ${user?.fullName ?? ''}')));
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Email atau password salah')));
    }
    setState(() => _loading = false);
  }

  void _serverLogin() async {
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.light.scaffoldBackgroundColor,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Card(
            elevation: 6,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset('drawable/logo_untidar.png', width: 96, height: 96),
                  const SizedBox(height: 12),
                  Text('Selamat Datang', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: AppTheme.primary, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  Text('KKN Track Universitas Tidar', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[700])),
                  const SizedBox(height: 20),

                  TextField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: 'Email', hintText: 'nama@domain.com'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _passCtrl,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Password', hintText: 'Masukkan password'),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fitur lupa password akan tersedia'))), child: const Text('Lupa password?')),
                      TextButton(onPressed: () => Navigator.pushNamed(context, '/register'), child: const Text('Daftar', style: TextStyle(color: AppTheme.accent))),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(onPressed: _loading ? null : _localLogin, child: _loading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white)) : const Text('Masuk')),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
