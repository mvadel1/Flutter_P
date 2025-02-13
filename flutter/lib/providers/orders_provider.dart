import 'package:flutter/material.dart';
import '../models/order.dart';
import '../services/order_service.dart';

class OrdersProvider extends ChangeNotifier {
  final OrderService _orderService = OrderService();

  List<OrderModel> _orders = [];
  List<OrderModel> get orders => _orders;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get errorMessage => _error;

  Future<void> fetchUserOrders(String token) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _orders = await _orderService.fetchUserOrders(token);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<bool> placeOrder(String token, int bookId, int quantity) async {
    try {
      _isLoading = true;
      notifyListeners();

      final newOrder = await _orderService.placeOrder(
        token: token,
        bookId: bookId,
        quantity: quantity,
      );
      _orders.insert(0, newOrder);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteOrder(String token, int orderId) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _orderService.deleteOrder(token: token, orderId: orderId);
      _orders.removeWhere((ord) => ord.id == orderId);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
