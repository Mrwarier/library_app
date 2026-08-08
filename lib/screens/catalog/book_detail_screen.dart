import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/book.dart';
import '../../services/book_service.dart';
import '../../services/borrow_service.dart';
import '../../services/session.dart';

class BookDetailScreen extends StatefulWidget {
  final String bookId;
  const BookDetailScreen({super.key, required this.bookId});

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  final _bookService = BookService();
  final _borrowService = BorrowService();
  bool _borrowing = false;

  Future<void> _borrow(Book book) async {
    final session = context.read<Session>();
    final user = session.user;
    if (user == null) return;

    setState(() => _borrowing = true);
    try {
      await _borrowService.borrowBook(
        bookId: book.id,
        bookTitle: book.title,
        userId: user.uid,
        userName: session.displayName,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Borrowed "${book.title}". Due in 14 days.')),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Could not borrow: $e')));
    } finally {
      if (mounted) setState(() => _borrowing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<Session>();
    final isAdmin = session.isAdmin;
    return Scaffold(
      appBar: AppBar(title: const Text('Book Details')),
      body: FutureBuilder<Book?>(
        future: _bookService.getBook(widget.bookId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final book = snapshot.data;
          if (book == null) {
            return const Center(child: Text('Book not found.'));
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    height: 220,
                    width: 160,
                    decoration: BoxDecoration(
                      color: Colors.indigo.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.menu_book,
                        size: 64, color: Colors.indigo),
                  ),
                ),
                const SizedBox(height: 20),
                Text(book.title, style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 4),
                Text('by ${book.author}',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    Chip(label: Text(book.genre)),
                    Chip(label: Text('ISBN ${book.isbn}')),
                  ],
                ),
                const SizedBox(height: 16),
                Text(book.description.isEmpty
                    ? 'No description available.'
                    : book.description),
                const SizedBox(height: 24),
                Text(
                  '${book.availableCopies} of ${book.totalCopies} copies available',
                  style: TextStyle(
                    color: book.isAvailable ? Colors.green.shade700 : Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: (!book.isAvailable || _borrowing || isAdmin)
                        ? null
                        : () => _borrow(book),
                    child: _borrowing
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : Text(isAdmin
                            ? 'Admin cannot borrow'
                            : (book.isAvailable ? 'Borrow this book' : 'Unavailable')),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
