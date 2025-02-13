import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/books_provider.dart';
import '../../providers/cart_provider.dart';
import '../../models/book.dart';
import '../../config/color_scheme.dart';

class BookDetailsScreen extends StatefulWidget {
  final int bookId;
  const BookDetailsScreen({Key? key, required this.bookId}) : super(key: key);

  @override
  State<BookDetailsScreen> createState() => _BookDetailsScreenState();
}

class _BookDetailsScreenState extends State<BookDetailsScreen> {
  int _quantity = 1;

  void _incrementQuantity() => setState(() => _quantity++);
  void _decrementQuantity() {
    if (_quantity > 1) setState(() => _quantity--);
  }

  Future<void> _addToCart(BookModel book) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final token = authProvider.token;
    if (token == null) {
      _showSnackBar('Please login to add items to cart');
      Navigator.pushNamed(context, '/login');
      return;
    }
    await cartProvider.addToCart(token, book.id, _quantity);
    if (cartProvider.errorMessage != null) {
      _showSnackBar(cartProvider.errorMessage!, background: Colors.red);
    } else {
      _showSnackBar('Added to cart', background: Colors.green);
    }
  }

  void _showSnackBar(String message, {Color background = Colors.black87}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: background),
    );
  }

  Widget _buildCoverImage(BookModel book) {
    return Center(
      child: book.coverImage != null
          ? ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          book.coverImage!,
          height: 250,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) {
            return Container(
              height: 250,
              width: double.infinity,
              color: AppColors.background.withOpacity(0.1),
              child: const Icon(Icons.broken_image, size: 100, color: AppColors.textSecondary),
            );
          },
        ),
      )
          : Container(
        height: 250,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.background.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.book, size: 100, color: AppColors.textSecondary),
      ),
    );
  }

  Widget _buildQuantitySelector() {
    return Row(
      children: [
        const Text('Quantity:', style: TextStyle(fontSize: 16)),
        const SizedBox(width: 16),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.textSecondary),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.remove),
                onPressed: _quantity > 1 ? _decrementQuantity : null,
              ),
              Text('$_quantity', style: const TextStyle(fontSize: 16)),
              IconButton(icon: const Icon(Icons.add), onPressed: _incrementQuantity),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final booksProvider = context.watch<BooksProvider>();
    final authProvider = context.watch<AuthProvider>();
    final cartProvider = context.watch<CartProvider>();
    final BookModel? book = booksProvider.findBookById(widget.bookId);

    if (book == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Book Details'), backgroundColor: AppColors.primary),
        body: const Center(child: Text('Book not found!')),
      );
    }

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(book.title),
          backgroundColor: AppColors.primary,
          actions: [
            IconButton(
              onPressed: () => Navigator.pushNamed(context, '/cart'),
              icon: const Icon(Icons.shopping_cart),
              tooltip: 'View Cart',
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCoverImage(book),
              const SizedBox(height: 24),
              Text(book.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('by ${book.author}', style: const TextStyle(fontSize: 18, color: AppColors.textSecondary)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text('\$${book.price}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary)),
                  const SizedBox(width: 16),
                  Text('Stock: ${book.stockQuantity}', style: const TextStyle(fontSize: 16, color: AppColors.textSecondary)),
                ],
              ),
              const SizedBox(height: 16),
              Chip(
                label: Text(book.category, style: const TextStyle(color: Colors.white)),
                backgroundColor: AppColors.secondary,
              ),
              const SizedBox(height: 24),
              const Text('Description', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(book.description, style: const TextStyle(fontSize: 16, color: AppColors.textSecondary)),
              const SizedBox(height: 24),
              Row(
                children: [
                  _buildQuantitySelector(),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: (cartProvider.isLoading || book.stockQuantity < _quantity)
                        ? null
                        : () => _addToCart(book),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: cartProvider.isLoading
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('Add to Cart', style: TextStyle(fontSize: 16)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
