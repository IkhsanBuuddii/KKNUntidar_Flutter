import 'package:flutter/material.dart';
import 'add_activity_dialog.dart';
import '../services/database_helper.dart';
import '../models/activity.dart';
import '../services/prefs_service.dart';
import '../widgets/activity_item.dart';
import '../theme.dart';

class ActivityLogScreen extends StatefulWidget {
  const ActivityLogScreen({super.key});

  @override
  State<ActivityLogScreen> createState() => _ActivityLogScreenState();
}

class _ActivityLogScreenState extends State<ActivityLogScreen> {
  List<ActivityModel> _items = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final email = await PrefsService.getUserEmail() ?? '';
    final items = await DatabaseHelper.instance.getActivitiesByUser(email);
    setState(() => _items = items);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Log Kegiatan')),
      body: RefreshIndicator(
        onRefresh: () async => _load(),
        child: _items.isEmpty
            ? ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  SizedBox(height: 80),
                  Icon(Icons.list_alt, size: 72, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Center(child: Text('Belum ada kegiatan', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.grey[700]))),
                  const SizedBox(height: 8),
                  Center(child: Text('Tambahkan kegiatan menggunakan tombol + di bawah', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]))),
                ],
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _items.length,
                itemBuilder: (ctx, i) {
                  final a = _items[i];
                  return GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/activity_detail', arguments: a.id),
                    child: ActivityItem(
                      activity: a,
                      onEdit: () {},
                      onDelete: () async {
                        await DatabaseHelper.instance.deleteActivity(a.id ?? 0);
                        _load();
                      },
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.accent,
        onPressed: () async {
          final res = await showDialog<bool>(context: context, builder: (_) => const AddActivityDialog());
          if (res == true) await _load();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
