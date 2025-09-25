
import 'package:flutter/material.dart';
import '../../shared/widgets/app_scaffold.dart';
import 'local_order_service.dart';
import 'models.dart';

class QueueScreen extends StatefulWidget {
  const QueueScreen({super.key});

  @override
  State<QueueScreen> createState() => _QueueScreenState();
}

class _QueueScreenState extends State<QueueScreen> {
  List<Order> _orders = [];

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    setState(() => _orders = LocalOrderService.list());
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Queue (Ethiopia)',
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _orders.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (_, i) {
          final o = _orders[i];
          return ListTile(
            title: Text(o.fullName),
            subtitle: Text('${o.phone} • ${o.email}\n${o.kebele} • ${o.note}', maxLines: 2),
            isThreeLine: true,
            trailing: Text(
              '${o.createdAt.hour.toString().padLeft(2,'0')}:${o.createdAt.minute.toString().padLeft(2,'0')}',
              style: const TextStyle(color: Colors.grey),
            ),
          );
        },
      ),
    );
  }
}
