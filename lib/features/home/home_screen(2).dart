
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
                        ? 'Ethiopia service: Submit Order and Queue are enabled.'
                        : 'Global flavor: Capture, Checker, and Print are enabled.',
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      FilledButton(
                        onPressed: () => context.go('/capture'),
                        child: const Text('Live Capture'),
                      ),
                      FilledButton(
                        onPressed: () => context.go('/checker'),
                        child: const Text('Photo Checker'),
                      ),
                      FilledButton(
                        onPressed: () => context.go('/print'),
                        child: const Text('Print Sheet'),
                      ),
                      if (isLocal)
                        FilledButton.tonal(
                          onPressed: () => context.go('/et/order'),
                          child: const Text('Submit Order (ET)'),
                        ),
                      if (isLocal)
                        FilledButton.tonal(
                          onPressed: () => context.go('/et/queue'),
                          child: const Text('Queue (ET)'),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
