import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io' show Platform;

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Email & Password Sign In
  static Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// Email & Password Sign Up
  static Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// Google Sign In (Mobile & Web)
  static Future<UserCredential?> signInWithGoogle() async {
    final googleProvider = GoogleAuthProvider();

    try {
      if (Platform.isAndroid || Platform.isIOS) {
        // Mobile
        return await _auth.signInWithProvider(googleProvider);
      } else {
        // Web
        return await _auth.signInWithPopup(googleProvider);
      }
    } catch (e) {
      // Unsupported platform or other errors
      print('Google Sign-In error: $e');
      return null;
    }
  }

  /// Sign Out
  static Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Send Password Reset Email
  static Future<void> sendPasswordReset(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  /// Map FirebaseAuth error codes to friendly messages
  static String getMessageFromErrorCode(String code) {
    switch (code) {
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This user has been disabled.';
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'The email is already in use by another account.';
      case 'operation-not-allowed':
        return 'This operation is not allowed.';
      case 'weak-password':
        return 'The password is too weak.';
      case 'network-request-failed':
        return 'Network Error. Check your internet.';
      case 'ERROR_ABORTED_BY_USER':
        return 'Sign in aborted by user.';
      default:
        return 'Authentication error: $code';
    }
  }
}
