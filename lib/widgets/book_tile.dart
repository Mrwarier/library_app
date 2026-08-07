import 'package:flutter/material.dart';
import '../models/book.dart';

class BookTile extends StatelessWidget {
  final Book book;
  final VoidCallback? onTap;
  final Widget? trailing;

  const BookTile({super.key, required this.book, this.onTap, this.trailing});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 48,
        height: 64,
        decoration: BoxDecoration(
          color: Colors.indigo.shade50,
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Icon(Icons.menu_book, color: Colors.indigo),
      ),
      title: Text(book.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text('${book.author} · ${book.genre}',
          maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: trailing ??
          Chip(
            label: Text(book.isAvailable
                ? '${book.availableCopies} available'
                : 'Unavailable'),
            backgroundColor:
                book.isAvailable ? Colors.green.shade100 : Colors.red.shade100,
          ),
    );
  }
}
