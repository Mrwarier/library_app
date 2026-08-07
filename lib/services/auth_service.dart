import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      return doc.exists ? doc.data() as Map<String, dynamic> : null;
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        return null;
      }
      rethrow;
    }
  }

  Future<void> _saveUserProfile(
    User user, {
    required String name,
    required String email,
    String role = 'user',
  }) async {
    await _firestore.collection('users').doc(user.uid).set({
      'uid': user.uid,
      'name': name.trim(),
      'email': email.trim().toLowerCase(),
      'role': role,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  bool _isAdminEmail(String email) {
    return email.trim().toLowerCase() == 'architacharya554@gmail.com';
  }

  Future<User> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        throw Exception('Unable to create user account');
      }

      if (name.trim().isNotEmpty) {
        await user.updateDisplayName(name.trim());
      }

      await _saveUserProfile(
        user,
        name: name,
        email: email,
        role: _isAdminEmail(email) ? 'admin' : 'user',
      );

      return user;
    } on FirebaseAuthException catch (e) {
      throw Exception('[${e.code}] ${e.message ?? 'Authentication error'}');
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<User> signIn({required String email, required String password}) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        throw Exception('Unable to sign in');
      }

      final profile = await getUserProfile(user.uid);
      if (profile == null) {
        await _saveUserProfile(
          user,
          name: user.displayName ?? '',
          email: user.email ?? email,
          role: _isAdminEmail(user.email ?? email) ? 'admin' : 'user',
        );
      }

      return user;
    } on FirebaseAuthException catch (e) {
      throw Exception('[${e.code}] ${e.message ?? 'Authentication error'}');
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> signOut() => _auth.signOut();
}
