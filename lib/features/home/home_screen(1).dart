
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/app_config.dart';
import '../../shared/widgets/app_scaffold.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isLocal = AppConfig.isLocalService;
    return AppScaffold(
      title: 'Home',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome to DV Photo',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isLocal
                        ? 'Ethiopia service flavor: submissions & queue coming in Part 3.'
                        : 'Global flavor: DV-ready processing is now available in Checker.',
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () => context.go('/checker'),
                    child: const Text('Open Photo Checker'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: const [
              _FeatureChip('Live Camera Overlay (Part 3)'),
              _FeatureChip('Smart Crop & Compress (Now)'),
              _FeatureChip('Photo Checker (Now)'),
              _FeatureChip('Print Sheet (Part 3)'),
              _FeatureChip('Local Queue & Payments (Part 3)'),
              _FeatureChip('Admin Dashboard (Part 3)'),
            ],
          ),
        ],
      ),
    );
  }
}

class _FeatureChip extends StatelessWidget {
  final String label;
  const _FeatureChip(this.label);

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }
}
