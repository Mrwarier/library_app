import 'package:cloud_firestore/cloud_firestore.dart';

class Book {
  final String id;
  final String title;
  final String author;
  final String isbn;
  final String genre;
  final String description;
  final int totalCopies;
  final int availableCopies;
  final DateTime addedAt;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.isbn,
    required this.genre,
    required this.description,
    required this.totalCopies,
    required this.availableCopies,
    required this.addedAt,
  });

  bool get isAvailable => availableCopies > 0;

  factory Book.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Book(
      id: doc.id,
      title: data['title'] ?? '',
      author: data['author'] ?? '',
      isbn: data['isbn'] ?? '',
      genre: data['genre'] ?? '',
      description: data['description'] ?? '',
      totalCopies: data['totalCopies'] ?? 0,
      availableCopies: data['availableCopies'] ?? 0,
      addedAt: (data['addedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'author': author,
      'isbn': isbn,
      'genre': genre,
      'description': description,
      'totalCopies': totalCopies,
      'availableCopies': availableCopies,
      'addedAt': Timestamp.fromDate(addedAt),
    };
  }
}
