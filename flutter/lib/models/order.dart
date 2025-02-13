class OrderModel {
  final int id;
  final int userId;
  final int bookId;
  final int quantity;
  final String status;

  OrderModel({
    required this.id,
    required this.userId,
    required this.bookId,
    required this.quantity,
    required this.status,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      bookId: json['book_id'] ?? 0,
      quantity: json['quantity'] ?? 1,
      status: json['status'] ?? 'processing',
    );
  }
}
