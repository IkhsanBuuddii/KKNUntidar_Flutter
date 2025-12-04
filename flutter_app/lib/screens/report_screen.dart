import 'package:flutter/material.dart';
import '../theme.dart';

class ReportScreen extends StatelessWidget {
  const ReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Laporan')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Text('Laporan', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: AppTheme.primary)),
                const SizedBox(height: 12),
                const Text('Report screen placeholder'),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
