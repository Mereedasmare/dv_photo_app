
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/splash/splash_screen.dart';
import '../features/home/home_screen.dart';
import '../features/checker/photo_checker_screen.dart';
import '../features/capture/capture_screen.dart';
import '../features/print/print_sheet_screen.dart';
import '../features/ethiopia/submit_order_screen.dart';
import '../features/ethiopia/queue_screen.dart';
import '../config/app_config.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'splash',
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: SplashScreen()),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: HomeScreen()),
      ),
      GoRoute(
        path: '/checker',
        name: 'checker',
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: PhotoCheckerScreen()),
      ),
      GoRoute(
        path: '/capture',
        name: 'capture',
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: CaptureScreen()),
      ),
      GoRoute(
        path: '/print',
        name: 'print',
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: PrintSheetScreen()),
      ),
      GoRoute(
        path: '/et/order',
        name: 'submit_order',
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: SubmitOrderScreen()),
      ),
      GoRoute(
        path: '/et/queue',
        name: 'queue',
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: QueueScreen()),
      ),
    ],
    redirect: (context, state) {
      final isLocal = AppConfig.isLocalService;
      // Prevent Ethiopia routes in global flavor
      final loc = state.uri.toString();
      if (!isLocal && (loc.startsWith('/et/'))) return '/home';
      return null;
    },
  );
});
