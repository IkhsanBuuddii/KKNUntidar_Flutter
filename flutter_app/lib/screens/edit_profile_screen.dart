import 'package:flutter/material.dart';
import '../services/prefs_service.dart';
import '../services/database_helper.dart';
 

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _name = TextEditingController();
  final _nim = TextEditingController();
  final _phone = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() async {
    final email = await PrefsService.getUserEmail();
    if (email != null) {
      final user = await DatabaseHelper.instance.getUserByEmail(email);
      if (user != null) {
        setState(() {
          _name.text = user.fullName;
          _nim.text = user.nim;
          _phone.text = user.phone;
        });
      }
    }
  }

  void _save() async {
    final email = await PrefsService.getUserEmail();
    if (email == null) return;
    final user = await DatabaseHelper.instance.getUserByEmail(email);
    if (user == null) return;
    user.fullName = _name.text.trim();
    user.nim = _nim.text.trim();
    user.phone = _phone.text.trim();
    await DatabaseHelper.instance.updateUser(user);
    // Update local pref name
    await PrefsService.setLogin(email, user.fullName);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profil')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Card(
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                TextField(controller: _name, decoration: const InputDecoration(labelText: 'Nama Lengkap')),
                const SizedBox(height: 10),
                TextField(controller: _nim, decoration: const InputDecoration(labelText: 'NIM')),
                const SizedBox(height: 10),
                TextField(controller: _phone, decoration: const InputDecoration(labelText: 'No. Telp')),
                const SizedBox(height: 16),
                SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _save, child: const Text('Simpan'))),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
