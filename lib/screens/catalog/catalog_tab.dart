import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/book.dart';
import '../../services/book_service.dart';
import '../../services/borrow_service.dart';
import '../../services/session.dart';
import '../../widgets/book_tile.dart';
import 'add_edit_book_screen.dart';
import 'book_detail_screen.dart';

class CatalogTab extends StatefulWidget {
  const CatalogTab({super.key});

  @override
  State<CatalogTab> createState() => _CatalogTabState();
}

class _CatalogTabState extends State<CatalogTab> {
  final _bookService = BookService();
  final _borrowService = BorrowService();
  final _searchController = TextEditingController();
  String _query = '';
  String? _borrowingBookId;

  Future<void> _borrowBook(Book book) async {
    final user = context.read<Session>().user;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to borrow books.')),
      );
      return;
    }

    setState(() => _borrowingBookId = book.id);
    try {
      await _borrowService.borrowBook(
        bookId: book.id,
        bookTitle: book.title,
        userId: user.uid,
        userName: context.read<Session>().displayName,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Borrowed "${book.title}".')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not borrow: $e')),
      );
    } finally {
      if (mounted) setState(() => _borrowingBookId = null);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _confirmDelete(Book book) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete book?'),
        content: Text('This removes "${book.title}" from the catalog. '
            'Existing loan history is kept.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    await _bookService.deleteBook(book.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Deleted "${book.title}".')));
  }

  Widget _buildBooks(List<Book> books) {
    if (books.isEmpty) {
      return const Center(
          child: Text('No books yet. Tap + to add one.'));
    }
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 80),
      itemCount: books.length,
      itemBuilder: (context, i) {
        final book = books[i];
        final isAdmin = context.watch<Session>().isAdmin;
        return BookTile(
          book: book,
          onTap: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => BookDetailScreen(bookId: book.id),
          )),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (book.isAvailable)
                FilledButton.icon(
                  icon: _borrowingBookId == book.id
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.shopping_cart_checkout),
                  label: const Text('Borrow'),
                  onPressed: _borrowingBookId == book.id
                      ? null
                      : () => _borrowBook(book),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(0, 36),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                ),
              if (isAdmin)
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => AddEditBookScreen(book: book),
                      ));
                    } else if (value == 'delete') {
                      _confirmDelete(book);
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(value: 'edit', child: Text('Edit')),
                    PopupMenuItem(
                      value: 'delete',
                      child: Text('Delete', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final stream = _query.isEmpty
        ? _bookService.streamBooks()
        : _bookService.streamSearch(_query);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            controller: _searchController,
            onChanged: (v) => setState(() => _query = v),
            decoration: InputDecoration(
              hintText: 'Search by title, author, or genre',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _query.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _query = '');
                      },
                    )
                  : null,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              isDense: true,
            ),
          ),
        ),
        Expanded(
          child: StreamBuilder<List<Book>>(
            stream: stream,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Could not load books from Firestore: ${snapshot.error}',
                      style: TextStyle(color: Colors.red.shade700),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final books = snapshot.data!;
              return _buildBooks(books);
            },
          ),
        ),
      ],
    );
  }
}
