import 'package:flutter/material.dart';
import '../models/activity.dart';

class ActivityItem extends StatelessWidget {
  final ActivityModel activity;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ActivityItem({super.key, required this.activity, this.onEdit, this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(activity.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0B3D91))),
              const SizedBox(height: 8),
              Text(activity.description, style: const TextStyle(color: Colors.grey), maxLines: 2, overflow: TextOverflow.ellipsis),
            ])),
            Row(children: [
              IconButton(icon: const Icon(Icons.edit), onPressed: onEdit),
              IconButton(icon: const Icon(Icons.delete), onPressed: onDelete),
            ])
          ]),
          const SizedBox(height: 12),
          Row(children: [
            const Text('📅 '),
            Expanded(child: Text(activity.date, style: const TextStyle(color: Color(0xFFFF8A00)))),
            const Text('🕐 '),
            Text(activity.time, style: const TextStyle(color: Color(0xFFFF8A00))),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            const Text('📍 '),
            Text(activity.location, style: const TextStyle(color: Color(0xFFCB2B2B))),
          ])
        ]),
      ),
    );
  }
}
