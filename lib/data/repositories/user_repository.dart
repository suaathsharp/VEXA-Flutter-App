// ──────────────────────────────────────────────────────────────────────────
//  USER REPOSITORY
//  All user data mutations and reads go through here.
//  Current source: LocalAuthService (mock).
//  Firebase swap: inject FirebaseAuthService. UI never changes.
// ──────────────────────────────────────────────────────────────────────────

import 'package:flutter_application_1/data/models/user_model.dart';
import 'package:flutter_application_1/data/services/auth_service.dart';
import 'package:flutter_application_1/data/services/firebase_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserRepository {
  final AuthServiceInterface _authService;

  UserRepository({AuthServiceInterface? authService})
      : _authService = authService ?? FirebaseAuthService();

  // ── Auth operations ──────────────────────────────────────────────────────
  Future<UserModel?> signIn(String email, String password) =>
      _authService.signInWithEmail(email, password);

  Future<UserModel?> signInWithGoogle() => _authService.signInWithGoogle();

  Future<UserModel?> register(String name, String email, String password, {String phone = ''}) =>
      _authService.signUp(name, email, password, phone: phone);

  Future<void> signOut() => _authService.signOut();

  Future<UserModel?> getCurrentUser() async => _authService.getCurrentUser();

  bool get isSignedIn => _authService.isSignedIn;

  Future<void> verifyPhoneNumber(
    String phone, {
    required Function(String verificationId) onCodeSent,
    required Function(String error) onError,
  }) =>
      _authService.verifyPhoneNumber(phone, onCodeSent: onCodeSent, onError: onError);

  Future<UserModel?> signInWithPhoneNumber(String verificationId, String smsCode) =>
      _authService.signInWithPhoneNumber(verificationId, smsCode);

  // ── Profile update ───────────────────────────────────────────────────────
  Future<UserModel?> updateProfile({
    required UserModel current,
    String? name,
    String? email,
    String? phone,
    String? language,
    String? currency,
  }) async {
    final updated = current.copyWith(
      name: name,
      email: email,
      phone: phone,
      language: language,
      currency: currency,
    );

    // Save to Firestore if logged in
    try {
      if (current.id != 'guest') {
        print("Updating Firestore user profile...");
        await firebaseService.usersRef.doc(current.id).set(
          updated.toMap(),
          SetOptions(merge: true),
        ).timeout(const Duration(seconds: 4));
        print("User profile updated successfully in Firestore");
      }
    } catch (e) {
      print("Firestore profile update error: $e");
    }

    return updated;
  }
}

/// Singleton — swap constructor argument to change auth provider.
final userRepository = UserRepository();
