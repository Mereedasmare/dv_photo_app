
import 'models.dart';

class LocalOrderService {
  static final List<Order> _orders = [];

  static List<Order> list() => List.unmodifiable(_orders);

  static Order add(Order o) {
    _orders.insert(0, o);
    return o;
  }
}
