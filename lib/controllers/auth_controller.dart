import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/firebase_auth_service.dart';
import '../services/firestore_service.dart';

class AuthController extends ChangeNotifier {
  final FirebaseAuthService _authService = FirebaseAuthService();
  final FirestoreService _firestoreService = FirestoreService();

  AppUser? _user;
  bool _loading = true;
  String? _error;

  AppUser? get user => _user;
  bool get loading => _loading;
  String? get error => _error;
  bool get isLoggedIn => _user != null;

  AuthController() {
    _init();
  }

  void _init() async {
    _authService.authStateChanges.handleError((_, __) {}).listen((firebaseUser) async {
      if (firebaseUser != null) {
        try {
          _user = await _firestoreService.getUser(firebaseUser.uid);
          if (_user == null && firebaseUser.email != null) {
            _user = AppUser(
              id: firebaseUser.uid,
              email: firebaseUser.email!,
              type: UserType.candidate,
              displayName: firebaseUser.displayName,
              photoUrl: firebaseUser.photoURL,
            );
          }
        } catch (_) {
          _user = AppUser(
            id: firebaseUser.uid,
            email: firebaseUser.email ?? '',
            type: UserType.candidate,
            displayName: firebaseUser.displayName,
            photoUrl: firebaseUser.photoURL,
          );
        }
      } else {
        _user = null;
      }
      _loading = false;
      notifyListeners();
    });
  }

  Future<bool> signUp(String email, String password, UserType type) async {
    _error = null;
    _loading = true;
    notifyListeners();
    try {
      final cred = await _authService.signUp(email, password);
      if (cred?.user == null) return false;
      final u = AppUser(
        id: cred!.user!.uid,
        email: cred.user!.email ?? email,
        type: type,
      );
      await _firestoreService.setUser(u);
      _user = u;
      _loading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _error = _messageForAuthCode(e.code);
      _loading = false;
      notifyListeners();
      return false;
    } on Exception catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signIn(String email, String password) async {
    _error = null;
    _loading = true;
    notifyListeners();
    try {
      final cred = await _authService.signIn(email, password);
      if (cred?.user == null) return false;
      _user = await _firestoreService.getUser(cred!.user!.uid);
      _user ??= AppUser(
        id: cred.user!.uid,
        email: cred.user!.email ?? email,
        type: UserType.candidate,
      );
      _loading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _error = _messageForAuthCode(e.code);
      _loading = false;
      notifyListeners();
      return false;
    } on Exception catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  /// Message utilisateur pour les erreurs Firebase Auth.
  static String _messageForAuthCode(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Aucun compte avec cet email. Inscrivez-vous ou vérifiez l\'email.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Mot de passe incorrect. Réessayez ou utilisez « Mot de passe oublié ».';
      case 'invalid-email':
        return 'Adresse email invalide.';
      case 'user-disabled':
        return 'Ce compte a été désactivé.';
      case 'too-many-requests':
        return 'Trop de tentatives. Réessayez plus tard.';
      case 'email-already-in-use':
        return 'Cet email est déjà utilisé. Connectez-vous ou réinitialisez le mot de passe.';
      case 'weak-password':
        return 'Le mot de passe doit contenir au moins 6 caractères.';
      case 'operation-not-allowed':
        return 'Connexion par email désactivée sur l\'application.';
      default:
        return 'Erreur de connexion. Vérifiez email et mot de passe.';
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _user = null;
    _error = null;
    notifyListeners();
  }

  Future<bool> resetPassword(String email) async {
    _error = null;
    try {
      await _authService.sendPasswordResetEmail(email);
      return true;
    } on Exception catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      return false;
    }
  }

  Future<void> refreshUser() async {
    if (_user == null) return;
    _user = await _firestoreService.getUser(_user!.id);
    notifyListeners();
  }

  Future<bool> updateProfile(AppUser updated) async {
    if (_user == null) return false;
    try {
      await _firestoreService.setUser(updated);
      _user = updated;
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
