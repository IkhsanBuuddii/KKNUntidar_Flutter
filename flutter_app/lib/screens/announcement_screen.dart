import 'package:flutter/material.dart';
import '../models/announcement.dart';


class AnnouncementScreen extends StatelessWidget {
  const AnnouncementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Placeholder: announcements could be loaded from DB or server
    final items = <Announcement>[
      Announcement(id: 1, title: 'Pengumuman 1', content: 'Isi pengumuman 1', date: '2025-12-04'),
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('Pengumuman')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        itemBuilder: (ctx, i) => Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            title: Text(items[i].title, style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text(items[i].date),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => showDialog(context: context, builder: (_) => AlertDialog(title: Text(items[i].title), content: Text(items[i].content))),
          ),
        ),
      ),
    );
  }
}
