import 'package:flutter/material.dart';
import '../theme.dart';

class LocationScreen extends StatelessWidget {
  const LocationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lokasi')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Text('Lokasi', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: AppTheme.primary)),
                const SizedBox(height: 12),
                const Text('Location features (maps) will be added later'),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
