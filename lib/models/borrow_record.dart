import 'package:cloud_firestore/cloud_firestore.dart';

enum BorrowStatus { borrowed, returned, overdue }

class BorrowRecord {
  final String id;
  final String bookId;
  final String bookTitle;
  final String userId;
  final String userName;
  final DateTime borrowedAt;
  final DateTime dueAt;
  final DateTime? returnedAt;
  final BorrowStatus status;

  BorrowRecord({
    required this.id,
    required this.bookId,
    required this.bookTitle,
    required this.userId,
    required this.userName,
    required this.borrowedAt,
    required this.dueAt,
    this.returnedAt,
    required this.status,
  });

  bool get isOverdue =>
      status == BorrowStatus.borrowed && DateTime.now().isAfter(dueAt);

  factory BorrowRecord.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BorrowRecord(
      id: doc.id,
      bookId: data['bookId'] ?? '',
      bookTitle: data['bookTitle'] ?? '',
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      borrowedAt: (data['borrowedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      dueAt: (data['dueAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      returnedAt: (data['returnedAt'] as Timestamp?)?.toDate(),
      status: BorrowStatus.values.firstWhere(
        (s) => s.name == data['status'],
        orElse: () => BorrowStatus.borrowed,
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'bookId': bookId,
      'bookTitle': bookTitle,
      'userId': userId,
      'userName': userName,
      'borrowedAt': Timestamp.fromDate(borrowedAt),
      'dueAt': Timestamp.fromDate(dueAt),
      'returnedAt': returnedAt != null ? Timestamp.fromDate(returnedAt!) : null,
      'status': status.name,
    };
  }
}
