import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/borrow_record.dart';
import '../../services/borrow_service.dart';
import '../../services/session.dart';

class MyLoansTab extends StatefulWidget {
  const MyLoansTab({super.key});

  @override
  State<MyLoansTab> createState() => _MyLoansTabState();
}

class _MyLoansTabState extends State<MyLoansTab> {
  final _borrowService = BorrowService();
  final _dateFormat = DateFormat.yMMMd();
  String? _returningId;

  Future<void> _returnBook(BorrowRecord record) async {
    setState(() => _returningId = record.id);
    try {
      await _borrowService.returnBook(record);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Returned "${record.bookTitle}".')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Could not return: $e')));
    } finally {
      if (mounted) setState(() => _returningId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = context.watch<Session>().user?.uid;
    if (uid == null) return const SizedBox.shrink();

    return StreamBuilder<List<BorrowRecord>>(
      stream: _borrowService.streamMyBorrows(uid),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final records = snapshot.data!;
        if (records.isEmpty) {
          return const Center(child: Text("You haven't borrowed any books yet."));
        }
        return ListView.builder(
          itemCount: records.length,
          itemBuilder: (context, i) {
            final r = records[i];
            final isActive = r.status == BorrowStatus.borrowed;
            final overdue = r.isOverdue;
            return ListTile(
              leading: Icon(
                isActive
                    ? (overdue ? Icons.warning_amber : Icons.menu_book)
                    : Icons.check_circle_outline,
                color: overdue
                    ? Colors.red
                    : (isActive ? Colors.indigo : Colors.green),
              ),
              title: Text(r.bookTitle),
              subtitle: Text(isActive
                  ? '${overdue ? "Overdue since" : "Due"} ${_dateFormat.format(r.dueAt)}'
                  : 'Returned ${_dateFormat.format(r.returnedAt ?? r.dueAt)}'),
              trailing: isActive
                  ? (_returningId == r.id
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : TextButton(
                          onPressed: () => _returnBook(r),
                          child: const Text('Return'),
                        ))
                  : null,
            );
          },
        );
      },
    );
  }
}
