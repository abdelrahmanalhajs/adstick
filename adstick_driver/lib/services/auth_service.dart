import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

// ── Singleton ────────────────────────────────────────────────
final authService = AuthService._();

class AuthService {
  AuthService._();

  final _auth = FirebaseAuth.instance;
  final _db   = FirebaseFirestore.instance;

  // ── Auth state ───────────────────────────────────────────
  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ── Sign in ──────────────────────────────────────────────
  Future<String?> signIn(String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
          email: email.trim(), password: password);
      // Verify this user is a driver
      final doc = await _db.collection('users').doc(cred.user!.uid).get();
      if (doc.exists && doc.data()?['role'] != 'driver') {
        await _auth.signOut();
        return 'This account is not a driver account.';
      }
      return null; // success
    } on FirebaseAuthException catch (e) {
      return _mapError(e.code);
    } catch (e) {
      return e.toString();
    }
  }

  // ── Register ─────────────────────────────────────────────
  Future<String?> register({
    required String email,
    required String password,
    required String name,
    required String phone,
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
          email: email.trim(), password: password);
      await cred.user!.updateDisplayName(name.trim());

      await _db.collection('users').doc(cred.user!.uid).set({
        'email':          email.trim(),
        'name':           name.trim(),
        'phone':          phone.trim(),
        'role':           'driver',
        'createdAt':      FieldValue.serverTimestamp(),
        // Driver-specific defaults
        'vehicleId':      '',
        'tier':           'bronze',
        'totalEarnings':  0.0,
        'totalWithdrawn': 0.0,
        'isActive':       false,
        'referralCode':   cred.user!.uid.substring(0, 8).toUpperCase(),
      });
      return null; // success
    } on FirebaseAuthException catch (e) {
      return _mapError(e.code);
    } catch (e) {
      return e.toString();
    }
  }

  // ── Sign out ─────────────────────────────────────────────
  Future<void> signOut() async => _auth.signOut();

  // ── Password reset ───────────────────────────────────────
  Future<String?> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return null;
    } on FirebaseAuthException catch (e) {
      return _mapError(e.code);
    }
  }

  // ── Fetch user profile ───────────────────────────────────
  Future<Map<String, dynamic>?> getProfile() async {
    final uid = currentUser?.uid;
    if (uid == null) return null;
    final doc = await _db.collection('users').doc(uid).get();
    return doc.data();
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> profileStream() {
    final uid = currentUser!.uid;
    return _db.collection('users').doc(uid).snapshots();
  }

  // ── Error mapping ────────────────────────────────────────
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
