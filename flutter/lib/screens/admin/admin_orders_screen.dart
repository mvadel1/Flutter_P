// lib/screens/admin/admin_orders_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/admin_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/order.dart';
import '../../widgets/custom_text_field.dart';
import '../../config/color_scheme.dart';

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({Key? key}) : super(key: key);

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<OrderModel> _filteredOrders = [];
  final List<String> _orderStatuses = [
    'pending',
    'processing',
    'delivered',
    'completed',
    'cancelled',
  ];

  @override
  void initState() {
    super.initState();
    _fetchOrders();
    _searchController.addListener(_filterOrders);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _fetchOrders() {
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;
    if (token != null) {
      adminProvider.fetchAllOrders(token).then((_) {
        setState(() {
          _filteredOrders = adminProvider.allOrders;
        });
      });
    }
  }

  void _filterOrders() {
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredOrders = adminProvider.allOrders.where((order) {
        return order.id.toString().contains(query) ||
            order.userId.toString().contains(query);
      }).toList();
    });
  }

  String _capitalize(String s) => s[0].toUpperCase() + s.substring(1);

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'processing':
        return Colors.blue;
      case 'delivered':
        return Colors.green;
      case 'completed':
        return Colors.purple;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Future<void> _updateStatus(OrderModel order, String newStatus) async {
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;
    if (token == null) return;

    final success = await adminProvider.updateOrderStatus(token, order.id, newStatus);
    if (success) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Order status updated')));
      _fetchOrders();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(adminProvider.errorMessage ?? 'Error updating status')),
      );
    }
  }

  Future<void> _deleteOrder(int orderId) async {
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;
    if (token == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: const Text('Are you sure you want to delete this order?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    final success = await adminProvider.deleteOrder(token, orderId);
    if (success) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Order deleted successfully')));
      _fetchOrders();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(adminProvider.errorMessage ?? 'Error deleting order')),
      );
    }
  }

  Widget _buildOrderItem(OrderModel order) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withOpacity(0.1),
          child: Icon(Icons.shopping_bag, color: AppColors.primary),
        ),
        title: Text(
          'Order #${order.id}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'User ID: ${order.userId}\nBook ID: ${order.bookId}\nQuantity: ${order.quantity}',
        ),
        isThreeLine: true,
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            DropdownButton<String>(
              value: _orderStatuses.contains(order.status) ? order.status : null,
              hint: order.status.isNotEmpty
                  ? Text(
                _capitalize(order.status),
                style: TextStyle(
                  color: _getStatusColor(order.status),
                  fontWeight: FontWeight.bold,
                ),
              )
                  : const Text('Select'),
              items: _orderStatuses
                  .map((status) => DropdownMenuItem(
                value: status,
                child: Text(_capitalize(status)),
              ))
                  .toList(),
              onChanged: (newStatus) {
                if (newStatus != null) {
                  _updateStatus(order, newStatus);
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              tooltip: 'Delete Order',
              onPressed: () => _deleteOrder(order.id),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final adminProvider = context.watch<AdminProvider>();
    final authProvider = context.watch<AuthProvider>();
    final token = authProvider.token;
    if (token == null) {
      return const Scaffold(
        body: Center(child: Text('Not logged in as admin')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin - Orders'),
        backgroundColor: AppColors.primary,
      ),

      body: SafeArea(
        child: adminProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : adminProvider.errorMessage != null
            ? Center(child: Text('Error: ${adminProvider.errorMessage}'))
            : Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              CustomTextField(
                controller: _searchController,
                label: 'Search Orders by ID or User ID',
                prefixIcon: Icons.search,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _filteredOrders.isEmpty
                    ? const Center(child: Text('No orders found.'))
                    : ListView.builder(
                  itemCount: _filteredOrders.length,
                  itemBuilder: (ctx, index) => _buildOrderItem(_filteredOrders[index]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
