import 'package:flutter/material.dart';
import '../services/database_helper.dart';
import '../theme.dart';

class ActivityDetailScreen extends StatefulWidget {
  const ActivityDetailScreen({super.key});

  @override
  State<ActivityDetailScreen> createState() => _ActivityDetailScreenState();
}

class _ActivityDetailScreenState extends State<ActivityDetailScreen> {
  Map<String, dynamic>? _data;

  void _load(int? id) async {
    if (id == null) return;
    final a = await DatabaseHelper.instance.getActivityById(id);
    if (a != null) {
      setState(() {
        _data = a.toMap();
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final id = ModalRoute.of(context)?.settings.arguments as int?;
    _load(id);
  }

  @override
  Widget build(BuildContext context) {
    if (_data == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    return Scaffold(
      appBar: AppBar(title: Text(_data?['title'] ?? 'Detail')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(_data?['title'] ?? '', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: AppTheme.primary, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  if ((_data?['photo_path'] ?? '').isNotEmpty) ...[
                    Image.network(_data?['photo_path']),
                    const SizedBox(height: 12),
                  ],
                  Text('Deskripsi', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[700])),
                  const SizedBox(height: 6),
                  Text(_data?['description'] ?? ''),
                  const SizedBox(height: 12),
                  Row(children: [
                    const Icon(Icons.calendar_today, size: 16),
                    const SizedBox(width: 8),
                    Text('${_data?['date'] ?? ''} ${_data?['time'] ?? ''}'),
                  ]),
                  const SizedBox(height: 8),
                  Row(children: [
                    const Icon(Icons.place, size: 16),
                    const SizedBox(width: 8),
                    Text(_data?['location'] ?? ''),
                  ]),
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
