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

  Future<String?> signIn(String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
          email: email.trim(), password: password);
      final doc = await _db.collection('users').doc(cred.user!.uid).get();
      if (doc.exists && doc.data()?['role'] != 'advertiser') {
        await _auth.signOut();
        return 'This account is not an advertiser account.';
      }
      return null;
    } on FirebaseAuthException catch (e) {
      return _mapError(e.code);
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> register({
    required String email,
    required String password,
    required String name,
    required String company,
    required String phone,
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
          email: email.trim(), password: password);
      await cred.user!.updateDisplayName(name.trim());
      await _db.collection('users').doc(cred.user!.uid).set({
        'email':       email.trim(),
        'name':        name.trim(),
        'phone':       phone.trim(),
        'companyName': company.trim(),
        'role':        'advertiser',
        'createdAt':   FieldValue.serverTimestamp(),
        'totalBudget': 0.0,
        'activeAds':   0,
      });
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

  Stream<DocumentSnapshot<Map<String, dynamic>>> profileStream() {
    return _db.collection('users').doc(currentUser!.uid).snapshots();
  }

  String _mapError(String code) {
    if (kDebugMode) debugPrint('FirebaseAuth error: $code');
    switch (code) {
      case 'user-not-found':       return 'No account found with this email.';
      case 'wrong-password':       return 'Incorrect password. Please try again.';
      case 'invalid-credential':   return 'Invalid email or password.';
      case 'email-already-in-use': return 'This email is already registered.';
      case 'weak-password':        return 'Password must be at least 6 characters.';
      case 'invalid-email':        return 'Please enter a valid email address.';
      case 'too-many-requests':    return 'Too many attempts. Please try again later.';
      case 'network-request-failed': return 'Network error. Check your connection.';
      default:                     return 'An error occurred. Please try again.';
    }
  }
}
