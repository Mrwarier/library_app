import 'package:flutter/material.dart';
import '../../models/book.dart';
import '../../services/book_service.dart';
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
  final _searchController = TextEditingController();
  String _query = '';

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
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final books = snapshot.data!;
              if (books.isEmpty) {
                return const Center(
                    child: Text('No books yet. Tap + to add one.'));
              }
              return ListView.builder(
                padding: const EdgeInsets.only(bottom: 80),
                itemCount: books.length,
                itemBuilder: (context, i) {
                  final book = books[i];
                  return BookTile(
                    book: book,
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => BookDetailScreen(bookId: book.id),
                    )),
                    trailing: PopupMenuButton<String>(
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
                          child:
                              Text('Delete', style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
