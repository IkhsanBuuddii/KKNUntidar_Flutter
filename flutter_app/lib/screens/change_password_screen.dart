import 'package:flutter/material.dart';
import '../services/prefs_service.dart';
import '../services/database_helper.dart';
 

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _old = TextEditingController();
  final _new = TextEditingController();
  final _confirm = TextEditingController();
  bool _loading = false;

  void _change() async {
    setState(() => _loading = true);
    final email = await PrefsService.getUserEmail();
    if (email == null) return;
    final db = DatabaseHelper.instance;
    final ok = await db.checkUser(email, _old.text.trim());
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password lama salah')));
      setState(() => _loading = false);
      return;
    }
    if (_new.text.trim() != _confirm.text.trim()) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Konfirmasi password tidak cocok')));
      setState(() => _loading = false);
      return;
    }
    await db.updateUserPassword(email, _new.text.trim());
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password berhasil diubah')));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ganti Password')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Card(
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                TextField(controller: _old, decoration: const InputDecoration(labelText: 'Password Lama'), obscureText: true),
                const SizedBox(height: 10),
                TextField(controller: _new, decoration: const InputDecoration(labelText: 'Password Baru'), obscureText: true),
                const SizedBox(height: 10),
                TextField(controller: _confirm, decoration: const InputDecoration(labelText: 'Konfirmasi Password'), obscureText: true),
                const SizedBox(height: 16),
                SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _loading ? null : _change, child: _loading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white)) : const Text('Ubah Password'))),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
