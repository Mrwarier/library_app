import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/session.dart';
import 'add_edit_book_screen.dart';
import 'catalog_tab.dart';
import 'my_loans_tab.dart';

/// Single home screen for every signed-in user — there is no separate
/// admin view. Anyone can browse the catalog, add/edit/delete books, and
/// track their own loans.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final session = context.watch<Session>();
    final pages = [const CatalogTab(), const MyLoansTab()];

    return Scaffold(
      appBar: AppBar(
        title: Text(_index == 0 ? 'Catalog' : 'My Loans'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign out',
            onPressed: () => session.signOut(),
          ),
        ],
      ),
      body: pages[_index],
      floatingActionButton: _index == 0
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => const AddEditBookScreen(),
              )),
              icon: const Icon(Icons.add),
              label: const Text('Add Book'),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.book_outlined), label: 'Catalog'),
          NavigationDestination(icon: Icon(Icons.history), label: 'My Loans'),
        ],
      ),
    );
  }
}
