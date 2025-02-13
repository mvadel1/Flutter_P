import 'package:flutter/material.dart';
import '../models/book.dart';
import '../services/book_service.dart';

class BooksProvider extends ChangeNotifier {
  final BookService _bookService = BookService();

  List<BookModel> _allBooks = [];
  List<BookModel> get allBooks => _allBooks;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get errorMessage => _error;

  Future<void> fetchBooks() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _allBooks = await _bookService.fetchAllBooks();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  BookModel? findBookById(int bookId) {
    try {
      return _allBooks.firstWhere((book) => book.id == bookId);
    } catch (e) {
      return null;
    }
  }
}
