
import 'package:flutter/material.dart';
import '../../shared/widgets/app_scaffold.dart';
import 'models.dart';
import 'local_order_service.dart';

class SubmitOrderScreen extends StatefulWidget {
  const SubmitOrderScreen({super.key});

  @override
  State<SubmitOrderScreen> createState() => _SubmitOrderScreenState();
}

class _SubmitOrderScreenState extends State<SubmitOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _kebele = TextEditingController();
  final _note = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _email.dispose();
    _kebele.dispose();
    _note.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final order = Order(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      fullName: _name.text.trim(),
      phone: _phone.text.trim(),
      email: _email.text.trim(),
      kebele: _kebele.text.trim(),
      note: _note.text.trim(),
      createdAt: DateTime.now(),
    );
    LocalOrderService.add(order);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Order submitted!')));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Submit Order (Ethiopia)',
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _name,
                decoration: const InputDecoration(labelText: 'Full Name (Latin letters)'),
                validator: (v) => (v == null || v.trim().length < 3) ? 'Enter full name' : null,
              ),
              TextFormField(
                controller: _phone,
                decoration: const InputDecoration(labelText: 'Phone'),
                keyboardType: TextInputType.phone,
                validator: (v) => (v == null || v.trim().length < 8) ? 'Enter phone' : null,
              ),
              TextFormField(
                controller: _email,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (v) => (v == null || !v.contains('@')) ? 'Enter valid email' : null,
              ),
              TextFormField(
                controller: _kebele,
                decoration: const InputDecoration(labelText: 'Kebele / ID'),
              ),
              TextFormField(
                controller: _note,
                decoration: const InputDecoration(labelText: 'Notes (optional)'),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _submit,
                child: const Text('Submit Order'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
