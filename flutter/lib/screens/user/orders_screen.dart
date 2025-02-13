import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/orders_provider.dart';
import '../../models/order.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({Key? key}) : super(key: key);

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final ordersProvider = Provider.of<OrdersProvider>(context, listen: false);
      final token = authProvider.token;
      if (token != null) {
        ordersProvider.fetchUserOrders(token);
      }
    });
  }

  Widget _buildOrderItem(OrderModel order) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        title: Text('Order #${order.id}', style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('Book ID: ${order.bookId}\nQuantity: ${order.quantity}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(order.status),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              tooltip: 'Delete Order',
              onPressed: order.status == 'processing'
                  ? () async {
                final authProvider = Provider.of<AuthProvider>(context, listen: false);
                final token = authProvider.token;
                if (token == null) return;
                final ordersProvider = Provider.of<OrdersProvider>(context, listen: false);
                final success = await ordersProvider.deleteOrder(token, order.id);
                if (!success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(ordersProvider.errorMessage ?? 'Error deleting order')),
                  );
                }
              }
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderList() {
    final ordersProvider = Provider.of<OrdersProvider>(context);
    if (ordersProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (ordersProvider.orders.isEmpty) {
      return const Center(child: Text('No orders yet'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: ordersProvider.orders.length,
      itemBuilder: (context, index) => _buildOrderItem(ordersProvider.orders[index]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final token = authProvider.token;
    if (token == null) {
      return const Scaffold(
        body: Center(child: Text('Please login to see your orders')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
      ),
      body: SafeArea(child: _buildOrderList()),
    );
  }
}
