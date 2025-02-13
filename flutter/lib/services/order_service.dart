import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/order.dart';

class OrderService {
  static const String BASE_URL = 'http://10.0.2.2:5000/api/orders/';

  Future<OrderModel> placeOrder({
    required String token,
    required int bookId,
    required int quantity,
  }) async {
    final url = Uri.parse(BASE_URL);
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({'book_id': bookId, 'quantity': quantity}),
    );
    if (response.statusCode == 201) {
      final data = json.decode(response.body);
      return OrderModel.fromJson(data);
    } else {

      throw Exception('Failed to place order');
    }
  }

  Future<List<OrderModel>> fetchUserOrders(String token) async {
    final url = Uri.parse(BASE_URL);
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((jsonItem) => OrderModel.fromJson(jsonItem)).toList();
    } else {
      throw Exception('Failed to load orders');
    }
  }

  Future<OrderModel> fetchSingleOrder({
    required String token,
    required int orderId,
  }) async {
    final url = Uri.parse('$BASE_URL$orderId');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return OrderModel.fromJson(data);
    } else {
      throw Exception('Order not found');
    }
  }

  Future<void> deleteOrder({
    required String token,
    required int orderId,
  }) async {
    final url = Uri.parse('$BASE_URL$orderId');
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
}
