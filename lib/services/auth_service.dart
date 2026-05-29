import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Handles Firebase Authentication with Google Sign-In.
///
/// Works on Android, iOS, and Web.
class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ── Google Sign-In (Android / iOS) ─────────────────────────────────────
  GoogleSignIn? _googleSignIn;

  /// Returns the currently signed-in Firebase user, or null.
  User? get currentUser => _auth.currentUser;

  /// Whether a user is currently signed in.
  bool get isSignedIn => _auth.currentUser != null;

  /// Signs in with Google via Firebase Auth.
  ///
  /// Returns the [UserCredential] on success, or throws on failure.
  Future<UserCredential> signInWithGoogle() async {
    if (kIsWeb) {
      return _signInWeb();
    }
    return _signInMobile();
  }

  /// Mobile path: GoogleSignIn → credential exchange → Firebase Auth.
  Future<UserCredential> _signInMobile() async {
    // Lazy-init GoogleSignIn (only for mobile, avoids web crash without meta tag)
    _googleSignIn ??= GoogleSignIn(scopes: ['email', 'profile']);

    // Trigger the Google account picker.
    final GoogleSignInAccount? googleUser = await _googleSignIn!.signIn();
    if (googleUser == null) {
      throw Exception('Google sign-in was cancelled by the user.');
    }

    // Obtain auth details from the selected account.
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    // Create a new credential for Firebase.
    final OAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Sign in to Firebase with the credential.
    return await _auth.signInWithCredential(credential);
  }

  /// Web path: Firebase Auth popup (no google_sign_in package on web).
  Future<UserCredential> _signInWeb() async {
    final GoogleAuthProvider provider = GoogleAuthProvider();
    provider.addScope('email');
    provider.addScope('profile');
    return await _auth.signInWithPopup(provider);
  }

  /// Signs out from both Firebase and Google.
  Future<void> signOut() async {
    await _googleSignIn?.signOut();
    await _auth.signOut();
  }
}
