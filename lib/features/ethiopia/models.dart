
class Order {
  final String id;
  final String fullName;
  final String phone;
  final String email;
  final String kebele;
  final String note;
  final DateTime createdAt;
  Order({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.email,
    required this.kebele,
    required this.note,
    required this.createdAt,
  });
}
