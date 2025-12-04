import 'package:flutter/material.dart';
import '../services/prefs_service.dart';
 
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _logout(BuildContext context) async {
    await PrefsService.clearLogin();
    Navigator.pushNamedAndRemoveUntil(context, '/', (r) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () => _logout(context), child: const Text('Logout'))),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
