import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/admin_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/book.dart';
import '../../widgets/custom_text_field.dart';
import '../../config/color_scheme.dart';

class AdminBooksScreen extends StatefulWidget {
  const AdminBooksScreen({Key? key}) : super(key: key);

  @override
  State<AdminBooksScreen> createState() => _AdminBooksScreenState();
}

class _AdminBooksScreenState extends State<AdminBooksScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<BookModel> _filteredBooks = [];

  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _isbnController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  final _categoryController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.token != null) {
      adminProvider.fetchAllBooks(authProvider.token!).then((_) {
        setState(() {
          _filteredBooks = adminProvider.allAdminBooks;
        });
      });
    }
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _titleController.dispose();
    _authorController.dispose();
    _isbnController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _categoryController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredBooks = adminProvider.allAdminBooks.where((book) {
        return book.title.toLowerCase().contains(query) ||
            book.author.toLowerCase().contains(query);
      }).toList();
    });
  }

  void _showCreateBookDialog(BuildContext context) {
    _clearBookForm();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Create Book'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              CustomTextField(controller: _titleController, label: 'Title', prefixIcon: Icons.title),
              const SizedBox(height: 8),
              CustomTextField(controller: _authorController, label: 'Author', prefixIcon: Icons.person),
              const SizedBox(height: 8),
              CustomTextField(controller: _isbnController, label: 'ISBN', prefixIcon: Icons.code),
              const SizedBox(height: 8),
              CustomTextField(controller: _priceController, label: 'Price', keyboardType: TextInputType.number, prefixIcon: Icons.attach_money),
              const SizedBox(height: 8),
              CustomTextField(controller: _stockController, label: 'Stock Quantity', keyboardType: TextInputType.number, prefixIcon: Icons.store),
              const SizedBox(height: 8),
              CustomTextField(controller: _categoryController, label: 'Category', prefixIcon: Icons.category),
              const SizedBox(height: 8),
              CustomTextField(controller: _descriptionController, label: 'Description', maxLines: 3, prefixIcon: Icons.description),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => _createBook(ctx), child: const Text('Create')),
        ],
      ),
    );
  }

  void _clearBookForm() {
    _titleController.clear();
    _authorController.clear();
    _isbnController.clear();
    _priceController.clear();
    _stockController.clear();
    _categoryController.clear();
    _descriptionController.clear();
  }

  Future<void> _createBook(BuildContext dialogCtx) async {
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;
    if (token == null) return;
    if (_titleController.text.trim().isEmpty ||
        _authorController.text.trim().isEmpty ||
        _isbnController.text.trim().isEmpty ||
        _priceController.text.trim().isEmpty ||
        _stockController.text.trim().isEmpty ||
        _categoryController.text.trim().isEmpty ||
        _descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }
    final success = await adminProvider.createBook(token, {
      'title': _titleController.text.trim(),
      'author': _authorController.text.trim(),
      'isbn': _isbnController.text.trim(),
      'price': double.tryParse(_priceController.text.trim()) ?? 0.0,
      'stock_quantity': int.tryParse(_stockController.text.trim()) ?? 0,
      'category': _categoryController.text.trim(),
      'description': _descriptionController.text.trim(),
    });
    Navigator.pop(dialogCtx);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Book created successfully')));
      adminProvider.fetchAllBooks(token).then((_) {
        setState(() {
          _filteredBooks = adminProvider.allAdminBooks;
        });
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(adminProvider.errorMessage ?? 'Error creating book')),
      );
    }
  }

  void _showEditBookDialog(BuildContext context, BookModel book) {
    _titleController.text = book.title;
    _authorController.text = book.author;
    _isbnController.text = book.isbn;
    _priceController.text = book.price.toString();
    _stockController.text = book.stockQuantity.toString();
    _categoryController.text = book.category;
    _descriptionController.text = book.description;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Update Book #${book.id}'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              CustomTextField(controller: _titleController, label: 'Title', prefixIcon: Icons.title),
              const SizedBox(height: 8),
              CustomTextField(controller: _authorController, label: 'Author', prefixIcon: Icons.person),
              const SizedBox(height: 8),
              CustomTextField(controller: _isbnController, label: 'ISBN', prefixIcon: Icons.code),
              const SizedBox(height: 8),
              CustomTextField(controller: _priceController, label: 'Price', keyboardType: TextInputType.number, prefixIcon: Icons.attach_money),
              const SizedBox(height: 8),
              CustomTextField(controller: _stockController, label: 'Stock Quantity', keyboardType: TextInputType.number, prefixIcon: Icons.store),
              const SizedBox(height: 8),
              CustomTextField(controller: _categoryController, label: 'Category', prefixIcon: Icons.category),
              const SizedBox(height: 8),
              CustomTextField(controller: _descriptionController, label: 'Description', maxLines: 3, prefixIcon: Icons.description),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => _updateBook(ctx, book.id), child: const Text('Update')),
        ],
      ),
    );
  }

  Future<void> _updateBook(BuildContext dialogCtx, int bookId) async {
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;
    if (token == null) return;
    if (_titleController.text.trim().isEmpty ||
        _authorController.text.trim().isEmpty ||
        _isbnController.text.trim().isEmpty ||
        _priceController.text.trim().isEmpty ||
        _stockController.text.trim().isEmpty ||
        _categoryController.text.trim().isEmpty ||
        _descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }
    final success = await adminProvider.updateBook(token, bookId, {
      'title': _titleController.text.trim(),
      'author': _authorController.text.trim(),
      'isbn': _isbnController.text.trim(),
      'price': double.tryParse(_priceController.text.trim()) ?? 0.0,
      'stock_quantity': int.tryParse(_stockController.text.trim()) ?? 0,
      'category': _categoryController.text.trim(),
      'description': _descriptionController.text.trim(),
    });
    Navigator.pop(dialogCtx);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Book updated successfully')));
      adminProvider.fetchAllBooks(token).then((_) {
        setState(() {
          _filteredBooks = adminProvider.allAdminBooks;
        });
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(adminProvider.errorMessage ?? 'Error updating book')),
      );
    }
  }

  void _showRestockDialog(BuildContext context, int bookId) {
    final TextEditingController amountController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Restock Book #$bookId'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomTextField(
              controller: amountController,
              label: 'Amount to Add',
              keyboardType: TextInputType.number,
              prefixIcon: Icons.add_box,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final adminProvider = Provider.of<AdminProvider>(context, listen: false);
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              final token = authProvider.token;
              if (token == null) return;
              final amount = int.tryParse(amountController.text.trim()) ?? 0;
              if (amount <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a valid amount')));
                return;
              }
              final success = await adminProvider.restockBook(token, bookId, amount, 'restock');
              Navigator.pop(ctx);
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Book restocked successfully')));
                adminProvider.fetchAllBooks(token).then((_) {
                  setState(() {
                    _filteredBooks = adminProvider.allAdminBooks;
                  });
                });
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(adminProvider.errorMessage ?? 'Error restocking')),
                );
              }
            },
            child: const Text('Restock'),
          ),
        ],
      ),
    );
  }

  void _deleteBook(int bookId) async {
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;
    if (token == null) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: const Text('Are you sure you want to delete this book?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirm != true) return;
    final success = await adminProvider.deleteBook(token, bookId);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Book deleted successfully')));
      adminProvider.fetchAllBooks(token).then((_) {
        setState(() {
          _filteredBooks = adminProvider.allAdminBooks;
        });
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(adminProvider.errorMessage ?? 'Error deleting book')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final adminProvider = context.watch<AdminProvider>();
    final authProvider = context.watch<AuthProvider>();
    final token = authProvider.token;
    if (token == null) {
      return const Scaffold(body: Center(child: Text('Not logged in as admin')));
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin - Books'),
        backgroundColor: AppColors.primary,
      ),
      body: adminProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : adminProvider.errorMessage != null
          ? Center(child: Text('Error: ${adminProvider.errorMessage}'))
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CustomTextField(
              controller: _searchController,
              label: 'Search Books',
              prefixIcon: Icons.search,
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: _filteredBooks.isEmpty
                  ? const Center(child: Text('No books found.'))
                  : ListView.builder(
                itemCount: _filteredBooks.length,
                itemBuilder: (ctx, i) {
                  final BookModel book = _filteredBooks[i];
                  return Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.primary.withOpacity(0.1),
                        child: Icon(Icons.book, color: AppColors.primary),
                      ),
                      title: Text(book.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('Author: ${book.author}\nStock: ${book.stockQuantity} | \$${book.price.toStringAsFixed(2)}'),
                      isThreeLine: true,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _showEditBookDialog(context, book),
                            tooltip: 'Edit Book',
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_box, color: Colors.green),
                            onPressed: () => _showRestockDialog(context, book.id),
                            tooltip: 'Restock Book',
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteBook(book.id),
                            tooltip: 'Delete Book',
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateBookDialog(context),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add),
        tooltip: 'Add Book',
      ),
    );
  }
}
