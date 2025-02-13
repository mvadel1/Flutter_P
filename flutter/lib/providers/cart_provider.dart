import 'package:flutter/material.dart';
import '../models/cart_item.dart';
import '../services/cart_service.dart';
import '../providers/auth_provider.dart'; // to read token?

class CartProvider extends ChangeNotifier {
  final CartService _cartService = CartService();
  List<CartItemModel> _cartItems = [];
  List<CartItemModel> get cartItems => _cartItems;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get errorMessage => _error;


  Future<void> fetchCart(String token) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _cartItems = await _cartService.fetchCart(token);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> addToCart(String token, int bookId, int quantity) async {
    try {
      _isLoading = true;
      notifyListeners();
      final newItem = await _cartService.addToCart(
        token: token,
        bookId: bookId,
        quantity: quantity,
      );

      _cartItems = await _cartService.fetchCart(token);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateCartItem(String token, int cartItemId, int quantity) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _cartService.updateCartItem(
        token: token,
        cartItemId: cartItemId,
        quantity: quantity,
      );

      _cartItems = await _cartService.fetchCart(token);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteCartItem(String token, int cartItemId) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _cartService.deleteCartItem(
        token: token,
        cartItemId: cartItemId,
      );
      _cartItems.removeWhere((item) => item.id == cartItemId);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> clearCart(String token) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _cartService.clearCart(token);
      _cartItems = [];

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }
}
