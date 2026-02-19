import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:googleapis_auth/googleapis_auth.dart' as auth;
import '../services/drive_service.dart';

/// Provider to manage Google authentication state
class AuthProvider extends ChangeNotifier {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'https://www.googleapis.com/auth/drive.file'],
  );

  final DriveService _driveService;

  GoogleSignInAccount? _currentUser;
  GoogleSignInAccount? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  AuthProvider(this._driveService) {
    _googleSignIn.onCurrentUserChanged.listen((account) async {
      _currentUser = account;

      // Sync Drive Service state
      if (account != null) {
        final client = await _googleSignIn.authenticatedClient();
        _driveService.updateClient(client);
      } else {
        _driveService.updateClient(null);
      }

      notifyListeners();
    });
  }

  /// Try to sign in silently on startup
  Future<void> trySilentSignIn() async {
    try {
      await _googleSignIn.signInSilently();
    } catch (e) {
      debugPrint('⚠️ Silent sign-in failed: $e');
    }
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
    try {
      await _googleSignIn.signOut();
      _currentUser = null;
      notifyListeners();
    } catch (e) {
      debugPrint('⚠️ Sign out failed: $e');
      // Force local cleanup even if remote fails
      _currentUser = null;
      _driveService.updateClient(null);
      notifyListeners();
    }
  }

  /// Get authenticated HTTP client for Google Services
  Future<auth.AuthClient?> getAuthenticatedClient() async {
    if (_currentUser == null) return null;
    return await _googleSignIn.authenticatedClient();
  }
}
