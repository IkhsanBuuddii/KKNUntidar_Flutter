import 'package:flutter/material.dart';
import '../services/database_helper.dart';
import '../models/user.dart';
import '../theme.dart';

// Redesigned Register screen aligned with app theme

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _name = TextEditingController();
  final _nim = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _pass = TextEditingController();
  final _db = DatabaseHelper.instance;
  bool _loading = false;

  void _register() async {
    setState(() => _loading = true);
    final name = _name.text.trim();
    final nim = _nim.text.trim();
    final email = _email.text.trim();
    final phone = _phone.text.trim();
    final pass = _pass.text.trim();
    if ([name, nim, email, pass].any((s) => s.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mohon isi semua field')));
      setState(() => _loading = false);
      return;
    }
    final exists = await _db.checkUserExists(email);
    if (exists) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Email sudah terdaftar')));
      setState(() => _loading = false);
      return;
    }
    final user = User(fullName: name, nim: nim, email: email, phone: phone, password: pass);
    await _db.addUser(user);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Registrasi berhasil, silakan login')));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.light.scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('Daftar')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Card(
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: _name, decoration: const InputDecoration(labelText: 'Nama Lengkap')),
                  const SizedBox(height: 10),
                  TextField(controller: _nim, decoration: const InputDecoration(labelText: 'NIM')),
                  const SizedBox(height: 10),
                  TextField(controller: _email, decoration: const InputDecoration(labelText: 'Email'), keyboardType: TextInputType.emailAddress),
                  const SizedBox(height: 10),
                  TextField(controller: _phone, decoration: const InputDecoration(labelText: 'No. Telp'), keyboardType: TextInputType.phone),
                  const SizedBox(height: 10),
                  TextField(controller: _pass, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
                  const SizedBox(height: 16),
                  SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _loading ? null : _register, child: _loading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white)) : const Text('Daftar'))),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
