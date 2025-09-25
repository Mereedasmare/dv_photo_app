
import 'package:supabase_flutter/supabase_flutter.dart';
import 'models.dart';

class SupaOrderService {
  final SupabaseClient _supa;
  SupaOrderService(this._supa);

  Future<List<Order>> list() async {
    final res = await _supa.from('orders').select('*, dv_profiles(full_name,phone,email,kebele)').order('created_at', ascending: false);
    return (res as List)
        .map((e) => Order(
              id: e['id'],
              fullName: (e['dv_profiles']?['full_name'] ?? '') as String,
              phone: (e['dv_profiles']?['phone'] ?? '') as String,
              email: (e['dv_profiles']?['email'] ?? '') as String,
              kebele: (e['dv_profiles']?['kebele'] ?? '') as String,
              note: '', // add a column later if needed
              createdAt: DateTime.parse(e['created_at']),
            ))
        .toList();
  }

  Future<void> submitDraft(Order o) async {
    final uid = _supa.auth.currentUser?.id;
    await _supa.from('orders').insert({
      'user_id': uid,
      'status': 'queued',
      'price_cents': 0,
      'currency': 'ETB',
    });
  }
}
