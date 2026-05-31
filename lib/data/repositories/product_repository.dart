// ──────────────────────────────────────────────────────────────────────────
//  PRODUCT REPOSITORY
//  The ONLY way UI screens read product data.
//  Current source: local (app_models.dart)
//  Firebase swap: replace _local* methods with Firestore calls.
//  UI NEVER CHANGES — only this file changes.
// ──────────────────────────────────────────────────────────────────────────

import 'package:flutter_application_1/data/models/app_models.dart';
import 'package:flutter_application_1/data/services/firebase_service.dart';

class ProductRepository {
  // ── Seeding ──────────────────────────────────────────────────────────────
  Future<void> seedProductsIfEmpty() async {
    try {
      print('[PRODUCT_SEEDING] Checking if products collection is empty in Firestore...');
      final snap = await firebaseService.productsRef.limit(1).get().timeout(const Duration(seconds: 4));
      if (snap.docs.isEmpty) {
        print('[PRODUCT_SEEDING] Products collection is empty! Initiating seeding of ${allProducts.length} products...');
        final batch = firebaseService.firestore.batch();
        for (final product in allProducts) {
          final docRef = firebaseService.productsRef.doc(product.id);
          print('[PRODUCT_SEEDING] Staging product: ${product.name} (ID: ${product.id})');
          batch.set(docRef, product.toMap());
        }
        print('[PRODUCT_SEEDING] Committing batch write to Firestore...');
        await batch.commit().timeout(const Duration(seconds: 8));
        print('[PRODUCT_SEEDING] Firestore products seeded successfully!');
      } else {
        print('[PRODUCT_SEEDING] Products collection already populated. Skipping seeding.');
      }
    } catch (e, stack) {
      print('[PRODUCT_SEEDING_ERROR] Failed to check or seed products in Firestore!');
      print('[PRODUCT_SEEDING_ERROR] Exception: $e');
      print('[PRODUCT_SEEDING_ERROR] Stacktrace: $stack');
    }
  }

  // ── Fetch all products ───────────────────────────────────────────────────
  Future<List<ProductModel>> getAllProducts() async {
    try {
      await seedProductsIfEmpty();
      final snap = await firebaseService.productsRef.get().timeout(const Duration(seconds: 4));
      if (snap.docs.isNotEmpty) {
        return snap.docs.map((doc) => ProductModel.fromMap(doc.data() as Map<String, dynamic>)).toList();
      }
    } catch (e) {
      print('Firestore error fetching products, falling back to local: $e');
    }
    return allProducts; // local fallback
  }

  // ── Fetch by category ────────────────────────────────────────────────────
  Future<List<ProductModel>> getByCategory(String category) async {
    try {
      final snap = await firebaseService.productsRef
          .where('category', isEqualTo: category)
          .get()
          .timeout(const Duration(seconds: 4));
      if (snap.docs.isNotEmpty) {
        return snap.docs.map((doc) => ProductModel.fromMap(doc.data() as Map<String, dynamic>)).toList();
      }
    } catch (e) {
      print('Firestore error filtering products, falling back: $e');
    }
    return allProducts.where((p) => p.category == category).toList();
  }

  // ── Fetch by subcategory ─────────────────────────────────────────────────
  Future<List<ProductModel>> getBySubCategory(String subCategory) async {
    try {
      final snap = await firebaseService.productsRef
          .where('subCategory', isEqualTo: subCategory)
          .get()
          .timeout(const Duration(seconds: 4));
      if (snap.docs.isNotEmpty) {
        return snap.docs.map((doc) => ProductModel.fromMap(doc.data() as Map<String, dynamic>)).toList();
      }
    } catch (e) {
      print('Firestore error filtering subCategory, falling back: $e');
    }
    return allProducts.where((p) => p.subCategory == subCategory).toList();
  }

  // ── Search ───────────────────────────────────────────────────────────────
  Future<List<ProductModel>> search(String query) async {
    // Fetch all and query locally for a flawless search user experience.
    final all = await getAllProducts();
    final q = query.toLowerCase();
    return all
        .where((p) =>
            p.name.toLowerCase().contains(q) ||
            p.brand.toLowerCase().contains(q) ||
            p.subCategory.toLowerCase().contains(q))
        .toList();
  }

  // ── Fetch trending ───────────────────────────────────────────────────────
  Future<List<ProductModel>> getTrending() async {
    try {
      // Query documents where badge is either TRENDING, HOT, or BEST
      final snap = await firebaseService.productsRef
          .where('badge', whereIn: ['TRENDING', 'HOT', 'BEST', 'NEW'])
          .get()
          .timeout(const Duration(seconds: 4));
      if (snap.docs.isNotEmpty) {
        return snap.docs.map((doc) => ProductModel.fromMap(doc.data() as Map<String, dynamic>)).toList();
      }
    } catch (e) {
      print('Firestore error fetching trending, falling back: $e');
    }
    return trendingProducts;
  }

  // ── Fetch by ID ──────────────────────────────────────────────────────────
  Future<ProductModel?> getById(String id) async {
    try {
      final doc = await firebaseService.productsRef.doc(id).get().timeout(const Duration(seconds: 4));
      if (doc.exists && doc.data() != null) {
        return ProductModel.fromMap(doc.data() as Map<String, dynamic>);
      }
    } catch (e) {
      print('Firestore error fetching product by id $id: $e');
    }
    try {
      return allProducts.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  // ── Men / Women / Kids helpers ───────────────────────────────────────────
  Future<List<ProductModel>> getMenProducts() async => getByCategory('men');
  Future<List<ProductModel>> getWomenProducts() async => getByCategory('women');
  Future<List<ProductModel>> getKidsProducts() async => getByCategory('kids');
}

/// Singleton — one instance shared across the app.
final productRepository = ProductRepository();
