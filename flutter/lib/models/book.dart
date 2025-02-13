class BookModel {
  final int id;
  final String title;
  final String author;
  final String isbn;
  final double price;
  final int stockQuantity;
  final String description;
  final String category;
  final String coverImage;

  BookModel({
    required this.id,
    required this.title,
    required this.author,
    required this.isbn,
    required this.price,
    required this.stockQuantity,
    required this.description,
    required this.category,
    required this.coverImage,
  });

  factory BookModel.fromJson(Map<String, dynamic> json) {
    return BookModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      author: json['author'] ?? '',
      isbn: json['isbn'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      stockQuantity: json['stock_quantity'] ?? 0,
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      coverImage: json['cover_image'] ?? '',
    );
  }
}
