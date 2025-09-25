
import 'package:flutter/material.dart';
import '../../config/app_config.dart';

class AppScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  const AppScaffold({super.key, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    final isLocal = AppConfig.isLocalService;
    return Scaffold(
      appBar: AppBar(
        title: Text('$title${isLocal ? " — Ethiopia" : ""}'),
      ),
      body: body,
    );
  }
}
