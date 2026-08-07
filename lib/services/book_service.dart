import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/book.dart';

class BookService {
  final CollectionReference _books =
      FirebaseFirestore.instance.collection('books');

  Stream<List<Book>> streamBooks() {
    return _books.orderBy('title').snapshots().map(
        (snap) => snap.docs.map((doc) => Book.fromFirestore(doc)).toList());
  }

  Stream<List<Book>> streamSearch(String query) {
    // Firestore has no full-text search; we do a client-side filter over
    // the live catalog stream, which is fine for a library-scale collection.
    final lower = query.toLowerCase();
    return streamBooks().map((books) => books
        .where((b) =>
            b.title.toLowerCase().contains(lower) ||
            b.author.toLowerCase().contains(lower) ||
            b.genre.toLowerCase().contains(lower))
        .toList());
  }

  Future<Book?> getBook(String id) async {
    final doc = await _books.doc(id).get();
    if (!doc.exists) return null;
    return Book.fromFirestore(doc);
  }

  Future<String> addBook(Book book) async {
    final doc = await _books.add(book.toMap());
    return doc.id;
  }

  Future<void> updateBook(Book book) {
    return _books.doc(book.id).update(book.toMap());
  }

  Future<void> deleteBook(String id) {
    return _books.doc(id).delete();
  }

  Future<void> decrementAvailability(String bookId) async {
    final doc = await _books.doc(bookId).get();
    final current = (doc.data() as Map<String, dynamic>)['availableCopies'] ?? 0;
    if (current <= 0) throw Exception('No copies available.');
    await _books.doc(bookId).update({'availableCopies': current - 1});
  }

  Future<void> incrementAvailability(String bookId) async {
    final doc = await _books.doc(bookId).get();
    final data = doc.data() as Map<String, dynamic>;
    final current = data['availableCopies'] ?? 0;
    final total = data['totalCopies'] ?? current + 1;
    await _books.doc(bookId).update({'availableCopies': (current + 1).clamp(0, total)});
  }
}
