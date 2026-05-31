// ──────────────────────────────────────────────────────────────────────────
//  FIREBASE SERVICE (Future Gateway)
//  This file is the ONLY place that imports Firebase packages.
//  All other services receive data through this abstraction.
//  When Firebase is added:
//    1. Add firebase_core, cloud_firestore, firebase_auth to pubspec.yaml
//    2. Initialize Firebase in main() via Firebase.initializeApp()
//    3. Uncomment the implementation below
// ──────────────────────────────────────────────────────────────────────────

import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Central gateway to all Firebase services.
/// Keeps Firebase imports isolated to a single file.
class FirebaseService {
  // ── Firestore ────────────────────────────────────────────────────────────
  FirebaseFirestore get firestore => FirebaseFirestore.instance;

  // ── Auth ─────────────────────────────────────────────────────────────────
  FirebaseAuth get auth => FirebaseAuth.instance;

  // ── Collections ──────────────────────────────────────────────────────────
  CollectionReference get usersRef => firestore.collection('users');
  CollectionReference get productsRef => firestore.collection('products');
  CollectionReference get ordersRef => firestore.collection('orders');
  CollectionReference get wishlistRef => firestore.collection('wishlist');
  CollectionReference get paymentsRef => firestore.collection('payments');
  CollectionReference get productViewsRef => firestore.collection('product_views');
  CollectionReference get activityLogsRef => firestore.collection('activity_logs');

  // ── Initialization check ─────────────────────────────────────────────────
  bool get isInitialized => Firebase.apps.isNotEmpty;
}

/// Singleton accessor — available project-wide.
final firebaseService = FirebaseService();
