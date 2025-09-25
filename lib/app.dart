
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'routing/app_router.dart';
import 'shared/theme/app_theme.dart';
import 'config/app_config.dart';

class DVApp extends ConsumerWidget {
  const DVApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final theme = AppTheme.lightTheme;
    final darkTheme = AppTheme.darkTheme;
    final flavor = AppConfig.flavor;
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      title: flavor == AppFlavor.ethiopia
          ? 'DV Photo (Ethiopia)'
          : 'DV Photo',
      theme: theme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.system,
    );
  }
}
