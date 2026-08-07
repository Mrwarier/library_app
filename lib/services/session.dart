import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'auth_service.dart';

/// Holds the signed-in Firebase user for the widget tree. AuthGate listens
/// to this to decide whether to show the login screen or the catalog.
class Session extends ChangeNotifier {
  final AuthService _authService;
  User? _user;
  String _role = 'user';
  bool _loading = true;
  String? _error;

  Session(this._authService) {
    _authService.authStateChanges.listen(
      _onAuthChanged,
      onError: _onAuthError,
    );
  }

  User? get user => _user;
  String get role => _role;
  bool get loading => _loading;
  bool get isSignedIn => _user != null;
  bool get isAdmin => _role == 'admin';
  String? get error => _error;

  /// Display name for borrow records — falls back to the email's local
  /// part if the account has no display name set.
  String get displayName {
    final name = _user?.displayName;
    if (name != null && name.isNotEmpty) return name;
    return _user?.email?.split('@').first ?? 'Member';
  }

  Future<void> _loadUserRole() async {
    if (_user == null) return;
    final profile = await _authService.getUserProfile(_user!.uid);
    _role = profile?['role'] as String? ?? 'user';
  }

  Future<void> _onAuthChanged(User? firebaseUser) async {
    _user = firebaseUser;
    _error = null;
    if (_user != null) {
      try {
        await _loadUserRole();
      } catch (_) {
        _role = 'user';
      }
    } else {
      _role = 'user';
    }
    _loading = false;
    notifyListeners();
  }

  void _onAuthError(Object error) {
    _user = null;
    _role = 'user';
    _error = error.toString();
    _loading = false;
    notifyListeners();
  }

  Future<void> setUser(User user) async {
    _user = user;
    _error = null;
    await _loadUserRole();
    _loading = false;
    notifyListeners();
  }

  Future<void> signOut() => _authService.signOut();
}
