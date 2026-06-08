import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

final authService = AuthService._();

class AuthService {
  AuthService._();

  final _auth = FirebaseAuth.instance;
  final _db   = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Admin sign-in — verifies role == 'admin' in Firestore.
  /// Admin accounts must be created manually in Firebase console +
  /// a Firestore document /users/{uid} with role: 'admin'.
  Future<String?> signIn(String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
          email: email.trim(), password: password);
      final doc = await _db.collection('users').doc(cred.user!.uid).get();
      if (!doc.exists || doc.data()?['role'] != 'admin') {
        await _auth.signOut();
        return 'Access denied — admin accounts only.';
      }
      return null;
    } on FirebaseAuthException catch (e) {
      return _mapError(e.code);
    } catch (e) {
      return e.toString();
    }
  }

  Future<void> signOut() async => _auth.signOut();

  Future<String?> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return null;
    } on FirebaseAuthException catch (e) {
      return _mapError(e.code);
    }
  }

  Future<Map<String, dynamic>?> getProfile() async {
    final uid = currentUser?.uid;
    if (uid == null) return null;
    final doc = await _db.collection('users').doc(uid).get();
    return doc.data();
  }

  String _mapError(String code) {
    if (kDebugMode) debugPrint('FirebaseAuth error: $code');
    switch (code) {
      case 'user-not-found':       return 'No account found with this email.';
      case 'wrong-password':       return 'Incorrect password.';
      case 'invalid-credential':   return 'Invalid email or password.';
      case 'too-many-requests':    return 'Too many attempts. Try again later.';
      case 'network-request-failed': return 'Network error.';
      default:                     return 'Sign-in failed. Please try again.';
    }
  }
}
