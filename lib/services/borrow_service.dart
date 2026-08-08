import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/borrow_record.dart';
import 'book_service.dart';

class BorrowService {
  final CollectionReference _records =
      FirebaseFirestore.instance.collection('borrow_records');
  final BookService _bookService = BookService();

  static const loanDurationDays = 14;

  Future<void> borrowBook({
    required String bookId,
    required String bookTitle,
    required String userId,
    required String userName,
  }) async {
    await _bookService.decrementAvailability(bookId);

    final now = DateTime.now();
    final record = BorrowRecord(
      id: '',
      bookId: bookId,
      bookTitle: bookTitle,
      userId: userId,
      userName: userName,
      borrowedAt: now,
      dueAt: now.add(const Duration(days: loanDurationDays)),
      status: BorrowStatus.borrowed,
    );
    await _records.add(record.toMap());
  }
  

  Future<void> returnBook(BorrowRecord record) async {
    await _bookService.incrementAvailability(record.bookId);
    await _records.doc(record.id).update({
      'status': 'returned',
      'returnedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  Stream<List<BorrowRecord>> streamMyBorrows(String userId) {
    return _records
        .where('userId', isEqualTo: userId)
        .orderBy('borrowedAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => BorrowRecord.fromFirestore(d)).toList());
  }

  Stream<List<BorrowRecord>> streamAllBorrows() {
    return _records
        .orderBy('borrowedAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => BorrowRecord.fromFirestore(d)).toList());
  }
}
