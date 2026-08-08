import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/session.dart';
import '../auth/login_screen.dart';
import 'add_edit_book_screen.dart';
import 'catalog_tab.dart';
import 'my_loans_tab.dart';

/// Home screen for every signed-in user.
/// The UI shows the current user profile and role, and admin users get
/// elevated management controls where applicable.
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

    final loansLabel = session.isAdmin ? 'All Loans' : 'My Loans';
    return Scaffold(
      appBar: AppBar(
        title: Text(_index == 0 ? 'Catalog' : loansLabel),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign out',
            onPressed: () async {
              await session.signOut();
              if (!context.mounted) return;
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: Colors.indigo.shade50,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                const Icon(Icons.person, color: Colors.indigo),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        session.displayName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(session.user?.email ?? '',
                          style: const TextStyle(fontSize: 14)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Chip(
                            label: Text(session.role.toUpperCase()),
                            backgroundColor: session.isAdmin
                                ? Colors.indigo.shade100
                                : Colors.grey.shade200,
                          ),
                          if (session.isAdmin) ...[
                            const SizedBox(width: 8),
                            const Icon(Icons.star, size: 16, color: Colors.amber),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: pages[_index]),
        ],
      ),
      floatingActionButton: _index == 0 && session.isSignedIn
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
        destinations: [
          const NavigationDestination(
              icon: Icon(Icons.book_outlined), label: 'Catalog'),
          NavigationDestination(
              icon: const Icon(Icons.history), label: loansLabel),
        ],
      ),
    );
  }
}
