import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/cart_item.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/orders_provider.dart';
import '../../providers/books_provider.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      final token = authProvider.token;
      if (token != null) {
        cartProvider.fetchCart(token);
      }
    });
  }

  Future<void> _placeOrderFromCart() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final ordersProvider = Provider.of<OrdersProvider>(context, listen: false);
    final token = authProvider.token;
    if (token == null) return;

    for (final CartItemModel item in cartProvider.cartItems) {
      final success = await ordersProvider.placeOrder(token, item.bookId, item.quantity);
      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to place order for cart item ${item.id}')),
        );
        return;
      }
    }

    await cartProvider.clearCart(token);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Order(s) placed successfully!')),
    );
  }

  Widget _buildCartList() {
    final cartProvider = Provider.of<CartProvider>(context);
    final booksProvider = Provider.of<BooksProvider>(context);
    final token = Provider.of<AuthProvider>(context, listen: false).token;

    if (cartProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (cartProvider.cartItems.isEmpty) {
      return const Center(child: Text('Cart is empty'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: cartProvider.cartItems.length,
      itemBuilder: (context, index) {
        final item = cartProvider.cartItems[index];
        final book = booksProvider.findBookById(item.bookId);
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: ListTile(
            title: Text(
              book?.title ?? 'Book #${item.bookId}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('Quantity: ${item.quantity}'),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () async {
                await cartProvider.deleteCartItem(token!, item.id);
                if (cartProvider.errorMessage != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(cartProvider.errorMessage!)),
                  );
                }
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final token = authProvider.token;
    if (token == null) {
      return const Scaffold(
        body: Center(child: Text('Please login first')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('My Cart')),
      body: _buildCartList(),
      bottomNavigationBar: Consumer<CartProvider>(
        builder: (context, cartProvider, child) {
          if (cartProvider.cartItems.isEmpty) return const SizedBox.shrink();
          return Container(
            padding: const EdgeInsets.all(12),
            height: 70,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: cartProvider.isLoading ? null : _placeOrderFromCart,
              child: cartProvider.isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Checkout', style: TextStyle(fontSize: 18)),
            ),
          );
        },
      ),
    );
  }
}
