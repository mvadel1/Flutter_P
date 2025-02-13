import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/book.dart';

class BookService {
  static const String BASE_URL = 'http://10.0.2.2:5000/api/books';

  Future<List<BookModel>> fetchAllBooks() async {
    final url = Uri.parse(BASE_URL);
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((jsonItem) => BookModel.fromJson(jsonItem)).toList();
    } else {
      throw Exception('Failed to load books');
    }
  }

  Future<BookModel> fetchBookById(int bookId) async {
    final url = Uri.parse('$BASE_URL/$bookId');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return BookModel.fromJson(data);
    } else {
      throw Exception('Book not found');
    }
  }
}
