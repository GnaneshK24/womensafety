import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final SharedPreferences _prefs;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Keys for SharedPreferences
  static const String EMAIL_KEY = 'email';
  static const String PASSWORD_KEY = 'password';
  static const String AUTH_TYPE_KEY = 'auth_type';
  static const String AUTH_TYPE_EMAIL = 'email';
  static const String AUTH_TYPE_GOOGLE = 'google';

  AuthService(this._prefs);

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      return true;
    }

    // Try to auto-login
    try {
      final authType = _prefs.getString(AUTH_TYPE_KEY);
      
      if (authType == AUTH_TYPE_GOOGLE) {
        // Auto sign-in with Google
        final googleUser = await _googleSignIn.signInSilently();
        if (googleUser != null) {
          await _signInWithGoogle(googleUser);
          return true;
        }
      } else if (authType == AUTH_TYPE_EMAIL) {
        // Auto sign-in with email/password
        final email = _prefs.getString(EMAIL_KEY);
        final password = _prefs.getString(PASSWORD_KEY);
        
        if (email != null && password != null) {
          try {
            await _auth.signInWithEmailAndPassword(
              email: email,
              password: password,
            );
            return true;
          } catch (e) {
            print('Error auto-logging in: $e');
            return false;
          }
        }
      }
    } catch (e) {
      print('Error in auto-login: $e');
    }
    
    return false;
  }

  // Save credentials for auto-login with email/password
  Future<void> saveLoginCredentials(String email, String password) async {
    await _prefs.setString(EMAIL_KEY, email);
    await _prefs.setString(PASSWORD_KEY, password);
    await _prefs.setString(AUTH_TYPE_KEY, AUTH_TYPE_EMAIL);
  }
  
  // Save Google sign-in for auto-login
  Future<void> saveGoogleSignIn() async {
    await _prefs.setString(AUTH_TYPE_KEY, AUTH_TYPE_GOOGLE);
  }

  // Sign in with Google
  Future<UserCredential> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      throw FirebaseAuthException(
        code: 'ERROR_ABORTED_BY_USER',
        message: 'Sign in aborted by user',
      );
    }
    
    // Save Google sign-in for auto-login
    await saveGoogleSignIn();
    
    return _signInWithGoogle(googleUser);
  }
  
  // Helper method for Google sign-in
  Future<UserCredential> _signInWithGoogle(GoogleSignInAccount googleUser) async {
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    return await _auth.signInWithCredential(credential);
  }

  // Sign out
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
    await _prefs.remove(EMAIL_KEY);
    await _prefs.remove(PASSWORD_KEY);
    await _prefs.remove(AUTH_TYPE_KEY);
  }

  // Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _prefs.setBool('isLoggedIn', true);
      return result;
    } catch (e) {
      rethrow;
    }
  }

  // Register with email and password
  Future<UserCredential> registerWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _prefs.setBool('isLoggedIn', true);
      return result;
    } catch (e) {
      rethrow;
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      rethrow;
    }
  }
} 