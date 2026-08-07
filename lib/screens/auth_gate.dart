import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/session.dart';
import 'auth/login_screen.dart';
import 'catalog/home_screen.dart';

/// Root routing widget: shows a loading spinner while the initial auth
/// state resolves, then either the login screen or the catalog home.
/// Session listens to FirebaseAuth.authStateChanges internally.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.watch<Session>();

    if (session.loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (session.error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Authentication error')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.redAccent),
                const SizedBox(height: 16),
                Text(
                  session.error ?? 'Unknown auth error.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () => Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  ),
                  child: const Text('Retry sign in'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return session.isSignedIn ? const HomeScreen() : const LoginScreen();
  }
}
