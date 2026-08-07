import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'auth_service.dart';

/// Holds the signed-in Firebase user for the widget tree. AuthGate listens
/// to this to decide whether to show the login screen or the catalog.
class Session extends ChangeNotifier {
  final AuthService _authService;
  User? _user;
  bool _loading = true;

  Session(this._authService) {
    _authService.authStateChanges.listen(_onAuthChanged);
  }

  User? get user => _user;
  bool get loading => _loading;
  bool get isSignedIn => _user != null;

  /// Display name for borrow records — falls back to the email's local
  /// part if the account has no display name set.
  String get displayName {
    final name = _user?.displayName;
    if (name != null && name.isNotEmpty) return name;
    return _user?.email?.split('@').first ?? 'Member';
  }

  void _onAuthChanged(User? firebaseUser) {
    _user = firebaseUser;
    _loading = false;
    notifyListeners();
  }

  void setUser(User user) {
    _user = user;
    _loading = false;
    notifyListeners();
  }

  Future<void> signOut() => _authService.signOut();
}
