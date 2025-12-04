import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DebugScreen extends StatefulWidget {
  const DebugScreen({super.key});

  @override
  State<DebugScreen> createState() => _DebugScreenState();
}

class _DebugScreenState extends State<DebugScreen> {
  String _users = 'loading...';
  String _activities = 'loading...';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (!kIsWeb) {
      setState(() {
        _users = 'Debug screen intended for web (SharedPreferences-backed). Not available on native.';
        _activities = '';
      });
      return;
    }
    final p = await SharedPreferences.getInstance();
    final u = p.getString('web_users') ?? '[]';
    final a = p.getString('web_activities') ?? '[]';
    setState(() {
      _users = u;
      _activities = a;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Debug')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: SingleChildScrollView(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Stored web_users (raw JSON):', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SelectableText(_users),
            const SizedBox(height: 16),
            const Text('Stored web_activities (raw JSON):', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SelectableText(_activities),
          ]),
        ),
      ),
    );
  }
}
