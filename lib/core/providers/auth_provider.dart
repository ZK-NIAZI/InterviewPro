import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:googleapis_auth/googleapis_auth.dart' as auth;

/// Provider to manage Google authentication state
class AuthProvider extends ChangeNotifier {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'https://www.googleapis.com/auth/drive.file'],
  );

  GoogleSignInAccount? _currentUser;
  GoogleSignInAccount? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  AuthProvider() {
    _googleSignIn.onCurrentUserChanged.listen((account) {
      _currentUser = account;
      notifyListeners();
    });
    // Try to sign in silently on startup
    _googleSignIn.signInSilently();
  }

  /// Sign in with Google
  Future<void> signIn() async {
    try {
      await _googleSignIn.signIn();
    } catch (e) {
      debugPrint('❌ Sign in failed: $e');
      rethrow;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    await _googleSignIn.disconnect();
  }

  /// Get authenticated HTTP client for Google Services
  Future<auth.AuthClient?> getAuthenticatedClient() async {
    if (_currentUser == null) return null;
    return await _googleSignIn.authenticatedClient();
  }
}
