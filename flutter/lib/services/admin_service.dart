import 'dart:convert';
import 'package:http/http.dart' as http;

class AdminService {
  static const String ADMIN_URL = 'http://10.0.2.2:5000/api/admin';



  Future<List<dynamic>> fetchAllUsers(String token) async {
    final url = Uri.parse('$ADMIN_URL/users');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch users');
    }
  }

  Future<void> updateUserRole({
    required String token,
    required int userId,
    required String newRole,
  }) async {
    final url = Uri.parse('$ADMIN_URL/users/$userId');
    final response = await http.put(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({'role': newRole}),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update user role');
    }
  }


  Future<List<dynamic>> fetchAllBooks(String token) async {
    final url = Uri.parse('$ADMIN_URL/books');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch books (Admin)');
    }
  }

  Future<Map<String, dynamic>> createBook(String token, Map<String, dynamic> bookData) async {
    final url = Uri.parse('$ADMIN_URL/books');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(bookData),
    );
    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to create book');
    }
  }

  Future<Map<String, dynamic>> updateBook(String token, int bookId, Map<String, dynamic> updateData) async {
    final url = Uri.parse('$ADMIN_URL/books/$bookId');
    final response = await http.put(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(updateData),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to update book');
    }
  }

  Future<void> deleteBook(String token, int bookId) async {
    final url = Uri.parse('$ADMIN_URL/books/$bookId');
    final response = await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to delete book');
    }
  }

  Future<void> restockBook({
    required String token,
    required int bookId,
    required int amount,
    String reason = 'restock',
  }) async {
    final url = Uri.parse('$ADMIN_URL/books/$bookId/restock');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'amount': amount,
        'reason': reason,
      }),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to restock book');
    }
  }

  // Orders
  Future<List<dynamic>> fetchAllOrders(String token) async {
    final url = Uri.parse('$ADMIN_URL/orders');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch orders');
    }
  }

  Future<void> updateOrderStatus({
    required String token,
    required int orderId,
    required String status,
  }) async {
    final url = Uri.parse('$ADMIN_URL/orders/$orderId');
    final response = await http.put(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({'status': status}),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update order status');
    }
  }

  Future<void> deleteOrder({
    required String token,
    required int orderId,
  }) async {
    final url = Uri.parse('$ADMIN_URL/orders/$orderId');
    final response = await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to delete order');
    }
  }

  // Analytics
  Future<Map<String, dynamic>> fetchAnalytics(String token) async {
    final url = Uri.parse('$ADMIN_URL/analytics');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch analytics');
    }
  }
}
