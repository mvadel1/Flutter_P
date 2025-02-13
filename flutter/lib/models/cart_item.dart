class CartItemModel {
  final int id;
  final int userId;
  final int bookId;
  final int quantity;

  CartItemModel({
    required this.id,
    required this.userId,
    required this.bookId,
    required this.quantity,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      bookId: json['book_id'] ?? 0,
      quantity: json['quantity'] ?? 1,
    );
  }
}
