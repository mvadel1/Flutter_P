import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/books_provider.dart';
import 'book_details_screen.dart';
import '../../models/book.dart';
import '../../config/color_scheme.dart';
import '../../widgets/custom_text_field.dart';
import '../auth/login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<BookModel> _filteredBooks = [];

  @override
  void initState() {
    super.initState();
    final booksProvider = Provider.of<BooksProvider>(context, listen: false);
    booksProvider.fetchBooks().then((_) {
      setState(() {
        _filteredBooks = booksProvider.allBooks;
      });
    });
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final booksProvider = Provider.of<BooksProvider>(context, listen: false);
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredBooks = booksProvider.allBooks.where((book) {
        return book.title.toLowerCase().contains(query) ||
            book.author.toLowerCase().contains(query) ||
            book.category.toLowerCase().contains(query);
      }).toList();
    });
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: CustomTextField(
        controller: _searchController,
        label: 'Search by title, author, or category',
        prefixIcon: Icons.search,
        keyboardType: TextInputType.text,
      ),
    );
  }

  Widget _buildBookGrid() {
    if (_filteredBooks.isEmpty) {
      return const Center(child: Text('No books found.'));
    }
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.6,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _filteredBooks.length,
      itemBuilder: (ctx, i) {
        final BookModel book = _filteredBooks[i];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => BookDetailsScreen(bookId: book.id)),
            );
          },
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Book Cover
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                    child: book.coverImage != null
                        ? Image.network(
                      book.coverImage!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) {
                        return Container(
                          color: AppColors.background.withOpacity(0.1),
                          child: const Icon(Icons.broken_image, size: 50, color: AppColors.textSecondary),
                        );
                      },
                    )
                        : Container(
                      color: AppColors.background.withOpacity(0.1),
                      child: const Icon(Icons.book, size: 50, color: AppColors.textSecondary),
                    ),
                  ),
                ),
                // Book Info
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        book.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'by ${book.author}',
                        style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '\$${book.price.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 16, color: AppColors.primary, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => BookDetailsScreen(bookId: book.id)),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondary,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('Details', style: TextStyle(fontSize: 14)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    if (authProvider.token == null) return const LoginScreen();

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Books'),
        backgroundColor: AppColors.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            tooltip: 'Profile',
            onPressed: () => Navigator.pushNamed(context, '/profile'),
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            tooltip: 'View Cart',
            onPressed: () => Navigator.pushNamed(context, '/cart'),
          ),
          IconButton(
            icon: const Icon(Icons.receipt_long),
            tooltip: 'My Orders',
            onPressed: () => Navigator.pushNamed(context, '/orders'),
          ),
        ],
      ),

      body: SafeArea(
        child: Column(
          children: [
            _buildSearchBar(),
            Expanded(child: _buildBookGrid()),
          ],
        ),
      ),
    );
  }
}
