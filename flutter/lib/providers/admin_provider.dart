import 'package:flutter/material.dart';

import '../services/admin_service.dart';
import '../models/book.dart';
import '../models/order.dart';
import '../models/user.dart';

class AdminProvider extends ChangeNotifier {
  final AdminService _adminService = AdminService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get errorMessage => _error;

  List<UserModel> _allUsers = [];
  List<UserModel> get allUsers => _allUsers;

  List<BookModel> _allAdminBooks = [];
  List<BookModel> get allAdminBooks => _allAdminBooks;

  List<OrderModel> _allOrders = [];
  List<OrderModel> get allOrders => _allOrders;

  Map<String, dynamic>? _analytics;
  Map<String, dynamic>? get analytics => _analytics;


  Future<void> fetchAllUsers(String token) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final data = await _adminService.fetchAllUsers(token);
      _allUsers = data.map((u) => UserModel.fromJson(u)).toList().cast<UserModel>();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateUserRole(String token, int userId, String newRole) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _adminService.updateUserRole(
        token: token,
        userId: userId,
        newRole: newRole,
      );

      final index = _allUsers.indexWhere((u) => u.id == userId.toString());
      if (index != -1) {
        final oldUser = _allUsers[index];
        _allUsers[index] = UserModel(
          id: oldUser.id,
          name: oldUser.name,
          phoneNumber: oldUser.phoneNumber,
          role: newRole,
          isVerified: oldUser.isVerified,
        );
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }


  Future<void> fetchAllBooks(String token) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final data = await _adminService.fetchAllBooks(token);
      _allAdminBooks = data.map((b) => BookModel.fromJson(b)).toList().cast<BookModel>();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<bool> createBook(String token, Map<String, dynamic> bookData) async {
    try {
      _isLoading = true;
      notifyListeners();
      final newBookJson = await _adminService.createBook(token, bookData);
      final newBook = BookModel.fromJson(newBookJson);
      _allAdminBooks.insert(0, newBook);
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

  Future<bool> updateBook(String token, int bookId, Map<String, dynamic> updateData) async {
    try {
      _isLoading = true;
      notifyListeners();
      final updatedJson = await _adminService.updateBook(token, bookId, updateData);
      final updatedBook = BookModel.fromJson(updatedJson);

      final index = _allAdminBooks.indexWhere((b) => b.id == bookId);
      if (index != -1) {
        _allAdminBooks[index] = updatedBook;
      }

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

  Future<bool> deleteBook(String token, int bookId) async {
    try {
      _isLoading = true;
      notifyListeners();
      await _adminService.deleteBook(token, bookId);
      _allAdminBooks.removeWhere((b) => b.id == bookId);
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

  Future<bool> restockBook(String token, int bookId, int amount, String reason) async {
    try {
      _isLoading = true;
      notifyListeners();
      await _adminService.restockBook(token: token, bookId: bookId, amount: amount, reason: reason);
      final idx = _allAdminBooks.indexWhere((b) => b.id == bookId);
      if (idx != -1) {
        final oldBook = _allAdminBooks[idx];
        _allAdminBooks[idx] = BookModel(
          id: oldBook.id,
          title: oldBook.title,
          author: oldBook.author,
          isbn: oldBook.isbn,
          price: oldBook.price,
          stockQuantity: oldBook.stockQuantity + amount,
          description: oldBook.description,
          category: oldBook.category,
          coverImage: oldBook.coverImage,
        );
      }
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

  // Orders
  Future<void> fetchAllOrders(String token) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final data = await _adminService.fetchAllOrders(token);
      _allOrders = data.map((o) => OrderModel.fromJson(o)).toList().cast<OrderModel>();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<bool> updateOrderStatus(String token, int orderId, String status) async {
    try {
      _isLoading = true;
      notifyListeners();
      await _adminService.updateOrderStatus(token: token, orderId: orderId, status: status);

      final idx = _allOrders.indexWhere((o) => o.id == orderId);
      if (idx != -1) {
        final oldOrder = _allOrders[idx];
        _allOrders[idx] = OrderModel(
          id: oldOrder.id,
          userId: oldOrder.userId,
          bookId: oldOrder.bookId,
          quantity: oldOrder.quantity,
          status: status,
        );
      }
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
      await _adminService.deleteOrder(token: token, orderId: orderId);
      _allOrders.removeWhere((o) => o.id == orderId);
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

  Future<void> fetchAnalytics(String token) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _analytics = await _adminService.fetchAnalytics(token);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }
}
