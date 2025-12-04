import 'package:flutter/material.dart';
import '../services/prefs_service.dart';
import '../services/database_helper.dart';
import 'edit_profile_screen.dart';
import '../theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _email = '';
  String _name = '';
  String _nim = '';
  String _phone = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() async {
    final email = await PrefsService.getUserEmail();
    final name = await PrefsService.getUserName();
    if (email != null) {
      final user = await DatabaseHelper.instance.getUserByEmail(email);
      setState(() {
        _email = user?.email ?? email;
        _name = user?.fullName ?? (name ?? '');
        _nim = user?.nim ?? '';
        _phone = user?.phone ?? '';
      });
    }
  }

  void _edit() async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen()));
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Card(
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                Text(_name, style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: AppTheme.primary, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('NIM: $_nim', style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 4),
                Text('Email: $_email', style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 4),
                Text('Phone: $_phone', style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 16),
                Align(alignment: Alignment.centerRight, child: ElevatedButton(onPressed: _edit, child: const Text('Edit Profil'))),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
