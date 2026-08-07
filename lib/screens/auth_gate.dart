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

    return session.isSignedIn ? const HomeScreen() : const LoginScreen();
  }
}
