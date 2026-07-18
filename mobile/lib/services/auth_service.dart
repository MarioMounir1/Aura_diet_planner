// ============================================================
//  lib/services/auth_service.dart
//  Auth state management — Google + Apple Sign-In
//  Persists session via SharedPreferences
// ============================================================

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

// ── Auth user model ────────────────────────────────────────────────
class AuraUser {
  final String id;
  final String name;
  final String email;
  final String? photoUrl;
  final String provider; // 'google' | 'apple'

  const AuraUser({
    required this.id,
    required this.name,
    required this.email,
    this.photoUrl,
    required this.provider,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'photoUrl': photoUrl,
        'provider': provider,
      };

  factory AuraUser.fromJson(Map<String, dynamic> j) => AuraUser(
        id:       j['id'] as String,
        name:     j['name'] as String,
        email:    j['email'] as String,
        photoUrl: j['photoUrl'] as String?,
        provider: j['provider'] as String,
      );
}

// ── Auth state ─────────────────────────────────────────────────────
enum AuthState { unknown, unauthenticated, loading, authenticated }

// ── Auth service singleton ─────────────────────────────────────────
class AuthService extends ChangeNotifier {
  AuthService._();
  static final AuthService instance = AuthService._();

  AuthState _state = AuthState.unknown;
  AuraUser? _user;
  String?   _error;

  AuthState get state => _state;
  AuraUser? get user  => _user;
  String?   get error => _error;
  bool get isLoggedIn => _state == AuthState.authenticated;

  static const _userKey = 'aura_user';

  final _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    // Add your OAuth 2.0 client ID here from Google Cloud Console
    // clientId: 'YOUR_CLIENT_ID.apps.googleusercontent.com',
  );

  // ── Load persisted session ────────────────────────────────────────
  Future<void> loadSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_userKey);
      if (raw != null) {
        _user  = AuraUser.fromJson(jsonDecode(raw) as Map<String, dynamic>);
        _state = AuthState.authenticated;
      } else {
        _state = AuthState.unauthenticated;
      }
    } catch (_) {
      _state = AuthState.unauthenticated;
    }
    notifyListeners();
  }

  // ── Persist session ───────────────────────────────────────────────
  Future<void> _saveSession(AuraUser user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  Future<void> _clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }

  // ── Google Sign-In ────────────────────────────────────────────────
  Future<void> signInWithGoogle() async {
    _state = AuthState.loading;
    _error = null;
    notifyListeners();

    try {
      final account = await _googleSignIn.signIn();
      if (account == null) {
        // User cancelled
        _state = AuthState.unauthenticated;
        notifyListeners();
        return;
      }

      final user = AuraUser(
        id:       account.id,
        name:     account.displayName ?? account.email.split('@').first,
        email:    account.email,
        photoUrl: account.photoUrl,
        provider: 'google',
      );

      _user  = user;
      _state = AuthState.authenticated;
      _error = null;
      await _saveSession(user);
      notifyListeners();
    } catch (e) {
      _error = 'Google sign-in failed. Please try again.';
      _state = AuthState.unauthenticated;
      notifyListeners();
    }
  }

  // ── Apple Sign-In ─────────────────────────────────────────────────
  Future<void> signInWithApple() async {
    _state = AuthState.loading;
    _error = null;
    notifyListeners();

    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final fullName =
          [credential.givenName, credential.familyName]
              .where((s) => s != null && s.isNotEmpty)
              .join(' ');

      final user = AuraUser(
        id:       credential.userIdentifier ?? 'apple-${credential.email}',
        name:     fullName.isNotEmpty ? fullName : 'Aura Member',
        email:    credential.email ?? 'apple-user@privaterelay.appleid.com',
        photoUrl: null,
        provider: 'apple',
      );

      _user  = user;
      _state = AuthState.authenticated;
      _error = null;
      await _saveSession(user);
      notifyListeners();
    } catch (e) {
      _error = 'Apple sign-in failed. Please try again.';
      _state = AuthState.unauthenticated;
      notifyListeners();
    }
  }

  // ── Email Sign-Up ──────────────────────────────────────────────────
  Future<void> signUpWithEmail(String name, String email, String password) async {
    _state = AuthState.loading;
    _error = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final usersRaw = prefs.getString('aura_local_users') ?? '{}';
      final Map<String, dynamic> users = jsonDecode(usersRaw) as Map<String, dynamic>;

      final normalizedEmail = email.trim().toLowerCase();
      if (users.containsKey(normalizedEmail)) {
        throw Exception('An account with this email already exists.');
      }

      final uid = 'email-${DateTime.now().millisecondsSinceEpoch}';
      final newUser = {
        'id': uid,
        'name': name.trim(),
        'email': normalizedEmail,
        'password': password,
      };

      users[normalizedEmail] = newUser;
      await prefs.setString('aura_local_users', jsonEncode(users));

      final user = AuraUser(
        id: uid,
        name: name.trim(),
        email: normalizedEmail,
        photoUrl: null,
        provider: 'email',
      );

      _user = user;
      _state = AuthState.authenticated;
      _error = null;
      await _saveSession(user);
      notifyListeners();
    } catch (e) {
      _error = e is Exception ? e.toString().replaceFirst('Exception: ', '') : 'Sign-up failed.';
      _state = AuthState.unauthenticated;
      notifyListeners();
    }
  }

  // ── Email Sign-In ──────────────────────────────────────────────────
  Future<void> signInWithEmail(String email, String password) async {
    _state = AuthState.loading;
    _error = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final usersRaw = prefs.getString('aura_local_users') ?? '{}';
      final Map<String, dynamic> users = jsonDecode(usersRaw) as Map<String, dynamic>;

      final normalizedEmail = email.trim().toLowerCase();
      if (!users.containsKey(normalizedEmail)) {
        throw Exception('No account found with this email.');
      }

      final userData = users[normalizedEmail] as Map<String, dynamic>;
      if (userData['password'] != password) {
        throw Exception('Incorrect password.');
      }

      final user = AuraUser(
        id: userData['id'] as String,
        name: userData['name'] as String,
        email: userData['email'] as String,
        photoUrl: null,
        provider: 'email',
      );

      _user = user;
      _state = AuthState.authenticated;
      _error = null;
      await _saveSession(user);
      notifyListeners();
    } catch (e) {
      _error = e is Exception ? e.toString().replaceFirst('Exception: ', '') : 'Sign-in failed.';
      _state = AuthState.unauthenticated;
      notifyListeners();
    }
  }

  // ── Sign out ──────────────────────────────────────────────────────
  Future<void> signOut() async {
    try {
      if (_user?.provider == 'google') {
        await _googleSignIn.signOut();
      }
    } catch (_) {}
    await _clearSession();
    _user  = null;
    _state = AuthState.unauthenticated;
    _error = null;
    notifyListeners();
  }
}
