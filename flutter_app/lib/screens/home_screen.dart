import 'package:flutter/material.dart';
import '../services/database_helper.dart';
import '../services/prefs_service.dart';
import '../theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _welcome = 'User';
  int _total = 0;
  String _last = 'Belum ada';

  @override
  void initState() {
    super.initState();
    // TODO: load actual user info from persisted preferences
    _loadDummy();
  }

  void _loadDummy() async {
    final email = await PrefsService.getUserEmail() ?? '';
    final name = await PrefsService.getUserName() ?? 'User';
    final total = await DatabaseHelper.instance.getActivitiesCountByUser(email);
    final last = await DatabaseHelper.instance.getLastActivityByUser(email) ?? 'Belum ada';
    setState(() {
      _welcome = name;
      _total = total;
      _last = last;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('KKN Untidar')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Halo,', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey[700])),
          const SizedBox(height: 6),
          Text(_welcome, style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: AppTheme.primary, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(children: [
                    Text('Total Kegiatan', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[700])),
                    const SizedBox(height: 8),
                    Text('$_total', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: AppTheme.accent, fontWeight: FontWeight.bold)),
                  ]),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(children: [
                    Text('Kegiatan Terakhir', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[700])),
                    const SizedBox(height: 8),
                    Text(_last, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.black87)),
                  ]),
                ),
              ),
            ),
          ]),
          const SizedBox(height: 20),
          SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () => Navigator.pushNamed(context, '/activities'), child: const Text('Lihat Kegiatan'))),
        ]),
      ),
    );
  }
}
