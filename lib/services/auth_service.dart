import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<void> _saveUserProfile(User user, {required String name, required String email}) async {
    await _firestore.collection('users').doc(user.uid).set({
      'uid': user.uid,
      'name': name.trim(),
      'email': email.trim().toLowerCase(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
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

      await _saveUserProfile(user, name: name, email: email);
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

      await _saveUserProfile(
        user,
        name: user.displayName ?? '',
        email: user.email ?? email,
      );
      return user;
    } on FirebaseAuthException catch (e) {
      throw Exception('[${e.code}] ${e.message ?? 'Authentication error'}');
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> signOut() => _auth.signOut();
}
