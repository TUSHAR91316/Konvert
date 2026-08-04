import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;

  Future<User?> createUserWithEmailAndPassword(
      String email, String password) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      return cred.user;
    } catch (e) {
      log("Error creating user: $e");
      return null;
    }
  }

  Future<User?> loginUserWithEmailAndPassword(
      String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return cred.user;
    } catch (e) {
      log("Error signing in: $e");
      return null;
    }
  }

  Future<User?> signInWithGoogle() async {
    try {
      // authenticate() triggers the Google account picker (Credential Manager on Android)
      // and returns a GoogleSignInAccount directly (throws on failure/cancel in v7).
      final GoogleSignInAccount googleUser =
          await GoogleSignIn.instance.authenticate();

      // In v7, authentication is synchronous (not a Future).
      // Only idToken is available on authentication; accessToken is obtained
      // via authorizationClient if needed. Firebase only requires idToken.
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        // accessToken is optional for Firebase — only idToken is required.
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      return userCredential.user;
    } on GoogleSignInException catch (e) {
      // User cancelled — treat as null, don't show error
      if (e.code == GoogleSignInExceptionCode.canceled) return null;
      log("Google Sign-In error: ${e.code} — ${e.description}");
      rethrow;
    } catch (e) {
      log("Error executing Google Sign-In: $e");
      rethrow; // Use rethrow to let UI handle the error
    }
  }

  Future<void> signOut() async {
    await GoogleSignIn.instance.signOut();
    await _auth.signOut();
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      log("Error sending password reset email: $e");
      rethrow; // Let UI handle invalid email errors
    }
  }
}
