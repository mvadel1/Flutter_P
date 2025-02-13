import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/cart_item.dart';

class CartService {
  static const String BASE_URL = 'http://10.0.2.2:5000/api/cart/';

  Future<List<CartItemModel>> fetchCart(String token) async {
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
      return data.map((jsonItem) => CartItemModel.fromJson(jsonItem)).toList();
    } else {
      throw Exception('Failed to load cart');
    }
  }

  Future<CartItemModel> addToCart({
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
      body: json.encode({
        'book_id': bookId,
        'quantity': quantity,
      }),
    );
    if (response.statusCode == 201 || response.statusCode == 200) {
      final data = json.decode(response.body);
      return CartItemModel.fromJson(data);
    } else {

      throw Exception('Failed to add to cart');
    }
  }

  Future<CartItemModel> updateCartItem({
    required String token,
    required int cartItemId,
    required int quantity,
  }) async {
    final url = Uri.parse('$BASE_URL$cartItemId');
    final response = await http.put(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({'quantity': quantity}),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return CartItemModel.fromJson(data);
    } else {
      throw Exception('Failed to update cart item');
    }
  }

  Future<void> deleteCartItem({
    required String token,
    required int cartItemId,
  }) async {
    final url = Uri.parse('$BASE_URL$cartItemId');
    final response = await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to delete cart item');
    }
  }

  Future<void> clearCart(String token) async {
    final url = Uri.parse('$BASE_URL/clear');
    final response = await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to clear cart');
    }
  }
}
