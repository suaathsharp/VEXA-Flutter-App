// ──────────────────────────────────────────────────────────────────────────
//  AUTH SERVICE — Interface & Implementations
//  Abstracts all authentication logic.
// ──────────────────────────────────────────────────────────────────────────

import 'package:flutter_application_1/data/models/user_model.dart';
import 'package:flutter_application_1/data/services/firebase_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_application_1/data/services/activity_log_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// ── Firebase Web Client ID for Google Sign-In ─────────────────────────────
// Replace this with the "Web client ID" from your Firebase Console
// (Firebase Console > Authentication > Sign-in method > Google > Web SDK configuration)
const String googleServerClientId = '291288879208-om3r33q6t21hsgk2q0dghk2n2m6t8vfe.apps.googleusercontent.com';

abstract class AuthServiceInterface {
  Future<UserModel?> signInWithEmail(String email, String password);
  Future<UserModel?> signInWithGoogle();
  Future<UserModel?> signUp(String name, String email, String password, {String phone = ''});
  Future<void> signOut();
  Future<UserModel?> getCurrentUser();
  bool get isSignedIn;
  Future<void> verifyPhoneNumber(String phone, {required Function(String verificationId) onCodeSent, required Function(String error) onError});
  Future<UserModel?> signInWithPhoneNumber(String verificationId, String smsCode);
}

// ──────────────────────────────────────────────────────────────────────────
//  FIREBASE AUTH SERVICE
//  ─────────────────────────────────────────────────────────────────────────
class FirebaseAuthService implements AuthServiceInterface {
  final _firebase = firebaseService;

  @override
  Future<UserModel?> signInWithEmail(String email, String password) async {
    try {
      final credential = await _firebase.auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user;
      if (user == null) return null;
      
      UserModel userModel;
      // Load user profile details from Firestore
      try {
        final doc = await _firebase.usersRef.doc(user.uid).get().timeout(const Duration(seconds: 4));
        if (doc.exists && doc.data() != null) {
          userModel = UserModel.fromMap(doc.data() as Map<String, dynamic>);
        } else {
          userModel = UserModel(
            id: user.uid,
            name: user.displayName ?? 'Customer',
            email: user.email ?? email.trim(),
          );
        }
      } catch (e) {
        print('Firestore Sync Warning: $e');
        userModel = UserModel(
          id: user.uid,
          name: user.displayName ?? 'Customer',
          email: user.email ?? email.trim(),
        );
      }
      
      // Update lastLoginAt and loginHistory in Firestore
      final nowStr = DateTime.now().toIso8601String();
      try {
        await _firebase.usersRef.doc(user.uid).set({
          'lastLoginAt': nowStr,
          'loginHistory': FieldValue.arrayUnion([nowStr]),
        }, SetOptions(merge: true));
      } catch (dbError) {
        print('Firestore lastLoginAt Sync Warning: $dbError');
      }

      // Record Login Activity
      await activityLogService.logActivity(
        userId: user.uid,
        activityType: 'Login',
        details: {'provider': 'email', 'email': userModel.email},
      );
      
      return userModel;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e, stack) {
      print('Login general error: $e');
      print(stack);
      throw 'An unexpected error occurred during login: $e';
    }
  }

  @override
  Future<UserModel?> signInWithGoogle() async {
    try {
      await GoogleSignIn.instance.initialize(
        serverClientId: googleServerClientId,
      );
      final googleUser = await GoogleSignIn.instance.authenticate();
      
      final googleAuth = googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      final userCredential = await _firebase.auth.signInWithCredential(credential);
      final user = userCredential.user;
      if (user == null) return null;

      // Check if user already exists in Firestore, otherwise create new document
      UserModel userModel;
      try {
        final doc = await _firebase.usersRef.doc(user.uid).get().timeout(const Duration(seconds: 4));
        if (doc.exists && doc.data() != null) {
          userModel = UserModel.fromMap(doc.data() as Map<String, dynamic>);
        } else {
          userModel = UserModel(
            id: user.uid,
            name: user.displayName ?? googleUser.displayName ?? 'Google User',
            email: user.email ?? googleUser.email,
            phone: '',
            language: 'English',
            currency: 'LKR',
            orderCount: 0,
            wishlistCount: 0,
            reviewCount: 0,
          );
          await _firebase.usersRef.doc(user.uid).set(userModel.toMap()).timeout(const Duration(seconds: 4));
        }
      } catch (dbError) {
        print('Firestore Google Auth Sync Warning: $dbError');
        userModel = UserModel(
          id: user.uid,
          name: user.displayName ?? googleUser.displayName ?? 'Google User',
          email: user.email ?? googleUser.email,
          phone: '',
          language: 'English',
          currency: 'LKR',
          orderCount: 0,
          wishlistCount: 0,
          reviewCount: 0,
        );
      }

      // Update lastLoginAt and loginHistory in Firestore
      final nowStr = DateTime.now().toIso8601String();
      try {
        await _firebase.usersRef.doc(user.uid).set({
          'lastLoginAt': nowStr,
          'loginHistory': FieldValue.arrayUnion([nowStr]),
        }, SetOptions(merge: true));
      } catch (dbError) {
        print('Firestore Google Auth lastLoginAt Sync Warning: $dbError');
      }

      // Record Login Activity
      await activityLogService.logActivity(
        userId: user.uid,
        activityType: 'Login',
        details: {'provider': 'google', 'email': userModel.email},
      );

      return userModel;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      print('Google sign-in error: $e');
      throw 'Google Sign-In failed: $e';
    }
  }

  @override
  Future<UserModel?> signUp(String name, String email, String password, {String phone = ''}) async {
    try {
      print('[USER_CREATION] Triggered registration for: $email');
      final credential = await _firebase.auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        print('[USER_CREATION] Failed to create credentials (User was null).');
        return null;
      }
      print('[USER_CREATION] Firebase Authentication success. Created User UID: ${user.uid}');

      // Update Firebase Auth profile display name
      try {
        await user.updateDisplayName(name);
        print('[USER_CREATION] Display name successfully set to: $name');
      } catch (e) {
        print('[USER_CREATION] Warning: Failed to update display name in Auth: $e');
      }

      // Create new user model
      final newUser = UserModel(
        id: user.uid,
        name: name,
        email: email.trim(),
        phone: phone,
        language: 'English',
        currency: 'LKR',
        orderCount: 0,
        wishlistCount: 0,
        reviewCount: 0,
      );

      // Save to Cloud Firestore users collection
      try {
        print('[USER_CREATION] Initiating Firestore write to users/${user.uid}...');
        await _firebase.usersRef.doc(user.uid).set(newUser.toMap()).timeout(const Duration(seconds: 4));
        print('[USER_CREATION] Firestore write succeeded. Document created for users/${user.uid}!');
      } catch (firestoreError, stack) {
        print('[USER_CREATION_ERROR] Firestore write FAILED for users/${user.uid}!');
        print('[USER_CREATION_ERROR] Exception: $firestoreError');
        print('[USER_CREATION_ERROR] Stacktrace: $stack');
      }

      // REQUIRED FLOW: Sign out the newly created user immediately
      try {
        print('[USER_CREATION] Signing out newly registered user session to require manual login...');
        await _firebase.auth.signOut();
        print('[USER_CREATION] Session signed out successfully.');
      } catch (signOutError) {
        print('[USER_CREATION] Warning: Failed to sign out user after registration: $signOutError');
      }

      return newUser;
    } on FirebaseAuthException catch (e) {
      print('[USER_CREATION_ERROR] FirebaseAuthException [${e.code}]: ${e.message}');
      throw _handleAuthException(e);
    } catch (e, stack) {
      print('[USER_CREATION_ERROR] Unexpected error during registration: $e');
      print(stack);
      throw 'An unexpected error occurred during registration: $e';
    }
  }

  @override
  Future<void> signOut() async {
    final uid = _firebase.auth.currentUser?.uid;
    if (uid != null) {
      try {
        await activityLogService.logActivity(
          userId: uid,
          activityType: 'Logout',
        );
      } catch (e) {
        print('Error logging logout activity: $e');
      }
    }
    await _firebase.auth.signOut();
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final user = _firebase.auth.currentUser;
    if (user == null) return null;

    try {
      final doc = await _firebase.usersRef.doc(user.uid).get().timeout(const Duration(seconds: 4));
      if (doc.exists && doc.data() != null) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }
    } catch (e) {
      // Ignore reading errors on init, fallback below
    }

    return UserModel(
      id: user.uid,
      name: user.displayName ?? 'User',
      email: user.email ?? '',
    );
  }

  @override
  bool get isSignedIn => _firebase.auth.currentUser != null;

  @override
  Future<void> verifyPhoneNumber(
    String phone, {
    required Function(String verificationId) onCodeSent,
    required Function(String error) onError,
  }) async {
    try {
      print('[PHONE_AUTH] Initiating verification for: $phone');
      await _firebase.auth.verifyPhoneNumber(
        phoneNumber: phone.trim(),
        verificationCompleted: (PhoneAuthCredential credential) async {
          print('[PHONE_AUTH] Auto-verification completed.');
        },
        verificationFailed: (FirebaseAuthException e) {
          print('[PHONE_AUTH_ERROR] Verification failed: ${e.message}');
          onError(e.message ?? 'Verification failed.');
        },
        codeSent: (String verificationId, int? resendToken) {
          print('[PHONE_AUTH] SMS code sent. Verification ID: $verificationId');
          onCodeSent(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          print('[PHONE_AUTH] Code auto-retrieval timeout.');
        },
        timeout: const Duration(seconds: 60),
      );
    } catch (e) {
      print('[PHONE_AUTH_ERROR] Unexpected error: $e');
      onError(e.toString());
    }
  }

  @override
  Future<UserModel?> signInWithPhoneNumber(String verificationId, String smsCode) async {
    try {
      print('[PHONE_AUTH] Attempting to sign in with SMS Code: $smsCode');
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode.trim(),
      );
      final userCredential = await _firebase.auth.signInWithCredential(credential);
      final user = userCredential.user;
      if (user == null) return null;

      print('[PHONE_AUTH] Sign-in succeeded. UID: ${user.uid}');

      // Create/update Firestore user document
      UserModel userModel;
      try {
        print('[USER_CREATION] Checking Firestore for phone user: ${user.uid}');
        final doc = await _firebase.usersRef.doc(user.uid).get().timeout(const Duration(seconds: 4));
        if (doc.exists && doc.data() != null) {
          print('[USER_CREATION] User document exists for users/${user.uid}.');
          userModel = UserModel.fromMap(doc.data() as Map<String, dynamic>);
        } else {
          print('[USER_CREATION] Creating new Firestore document for phone user: ${user.uid}');
          userModel = UserModel(
            id: user.uid,
            name: 'Phone User',
            email: '',
            phone: user.phoneNumber ?? '',
            language: 'English',
            currency: 'LKR',
            orderCount: 0,
            wishlistCount: 0,
            reviewCount: 0,
          );
          print("Creating Firestore user...");
          await _firebase.usersRef.doc(user.uid).set(userModel.toMap()).timeout(const Duration(seconds: 4));
          print("User created successfully");
        }
      } catch (dbError) {
        print("Firestore error: $dbError");
        userModel = UserModel(
          id: user.uid,
          name: 'Phone User',
          email: '',
          phone: user.phoneNumber ?? '',
        );
      }

      // Update lastLoginAt and loginHistory in Firestore
      final nowStr = DateTime.now().toIso8601String();
      try {
        await _firebase.usersRef.doc(user.uid).set({
          'lastLoginAt': nowStr,
          'loginHistory': FieldValue.arrayUnion([nowStr]),
        }, SetOptions(merge: true));
      } catch (dbError) {
        print('Firestore Phone Auth lastLoginAt Sync Warning: $dbError');
      }

      // Record Login Activity
      await activityLogService.logActivity(
        userId: user.uid,
        activityType: 'Login',
        details: {'provider': 'phone', 'phone': userModel.phone},
      );

      return userModel;
    } on FirebaseAuthException catch (e) {
      print('[PHONE_AUTH_ERROR] FirebaseAuthException [${e.code}]: ${e.message}');
      throw _handleAuthException(e);
    } catch (e, stack) {
      print('[PHONE_AUTH_ERROR] General error during verification: $e');
      print(stack);
      throw 'An unexpected error occurred during verification: $e';
    }
  }

  // ── Error Handling Helper ────────────────────────────────────────────────
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'The email address is badly formatted.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'user-not-found':
        return 'No account found with this email. Please sign up!';
      case 'wrong-password':
        return 'Wrong password. Please try again.';
      case 'email-already-in-use':
        return 'An account already exists for this email.';
      case 'operation-not-allowed':
        return 'Email/password sign-in is not enabled in Firebase Console.';
      case 'weak-password':
        return 'The password is too weak. Please use at least 6 characters.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection and try again.';
      default:
        return e.message ?? 'An error occurred during authentication.';
    }
  }
}

// ──────────────────────────────────────────────────────────────────────────
//  LOCAL AUTH SERVICE (Mock — kept for compatibility or fallback)
// ──────────────────────────────────────────────────────────────────────────
class LocalAuthService implements AuthServiceInterface {
  UserModel? _currentUser;

  @override
  Future<UserModel?> signInWithEmail(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (email.isNotEmpty && password.length >= 6) {
      _currentUser = UserModel.guest.copyWith(email: email);
      return _currentUser;
    }
    return null;
  }

  @override
  Future<UserModel?> signInWithGoogle() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _currentUser = UserModel.guest;
    return _currentUser;
  }

  @override
  Future<UserModel?> signUp(String name, String email, String password, {String phone = ''}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _currentUser = UserModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      email: email,
      phone: phone,
    );
    return _currentUser;
  }

  @override
  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _currentUser = null;
  }

  @override
  Future<UserModel?> getCurrentUser() async => _currentUser;

  @override
  bool get isSignedIn => _currentUser != null;

  @override
  Future<void> verifyPhoneNumber(
    String phone, {
    required Function(String verificationId) onCodeSent,
    required Function(String error) onError,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    onCodeSent('mock_verification_id');
  }

  @override
  Future<UserModel?> signInWithPhoneNumber(String verificationId, String smsCode) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _currentUser = UserModel(
      id: 'mock_phone_user_id',
      name: 'Mock Phone User',
      email: '',
      phone: '+94771234567',
    );
    return _currentUser;
  }
}
